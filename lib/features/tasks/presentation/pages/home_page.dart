import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../auth/state/auth_controller.dart';
import '../../state/task_controller.dart';
import '../widgets/task_card.dart';
import 'task_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final tasks = taskController.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: context.read<AuthController>().logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(),
          Expanded(
            child: taskController.isLoading && tasks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? EmptyState(
                    icon: Icons.task_outlined,
                    message: _emptyMessage(taskController.filter),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => TaskCard(task: tasks[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  String _emptyMessage(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.pending => 'Nenhuma tarefa pendente.\nQue organizado!',
      TaskFilter.completed => 'Nenhuma tarefa concluída ainda.',
      TaskFilter.all => 'Nenhuma tarefa criada.\nToque em + para começar!',
    };
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _Chip(
            label: 'Todas',
            filter: TaskFilter.all,
            current: controller.filter,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Pendentes',
            filter: TaskFilter.pending,
            current: controller.filter,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Concluídas',
            filter: TaskFilter.completed,
            current: controller.filter,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final TaskFilter filter;
  final TaskFilter current;

  const _Chip({
    required this.label,
    required this.filter,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: filter == current,
      onSelected: (_) => context.read<TaskController>().setFilter(filter),
    );
  }
}
