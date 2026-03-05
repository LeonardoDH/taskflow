import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/task_model.dart';
import '../../state/task_controller.dart';
import '../pages/task_form_page.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TaskController>();

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red.shade300,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => controller.deleteTask(task.id),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFC5AEE8),
          border: Border(
            top: BorderSide(color: Colors.white54, width: 2),
            left: BorderSide(color: Colors.white54, width: 2),
            bottom: BorderSide(color: Colors.black38, width: 2),
            right: BorderSide(color: Colors.black38, width: 2),
          ),
        ),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => controller.toggleCompleted(task),
          ),
          title: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.black45 : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  if (task.dueDate != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.black54),
                    const SizedBox(width: 2),
                    Text(
                      DateFormat('dd/MM/yy').format(task.dueDate!),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDDDDD),
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1),
                      left: BorderSide(color: Colors.white, width: 1),
                      bottom: BorderSide(color: Colors.black38, width: 1),
                      right: BorderSide(color: Colors.black38, width: 1),
                    ),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () async {
                  final confirm = await _confirmDelete(context);
                  if (confirm == true) controller.deleteTask(task.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDDDDD),
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1),
                      left: BorderSide(color: Colors.white, width: 1),
                      bottom: BorderSide(color: Colors.black38, width: 1),
                      right: BorderSide(color: Colors.black38, width: 1),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.red),
                ),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content:
            const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
