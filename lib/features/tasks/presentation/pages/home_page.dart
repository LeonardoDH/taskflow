import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
        backgroundColor: const Color(0xFFDDDDDD),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.black38, width: 2),
        ),
        title: Text(
          'Hatsune Task',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: const Color(0xFF0040FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: context.read<AuthController>().logout,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFCCCCCC),
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 2),
                    left: BorderSide(color: Colors.white, width: 2),
                    bottom: BorderSide(color: Colors.black54, width: 2),
                    right: BorderSide(color: Colors.black54, width: 2),
                  ),
                ),
                child: const Icon(Icons.logout, size: 18, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Hatsune Miku.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
          Column(
            children: [
              _FilterChips(),
              Expanded(
                child: taskController.isLoading && tasks.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : tasks.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => TaskCard(task: tasks[i]),
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormPage()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDDDDDD),
            border: const Border(
              top: BorderSide(color: Colors.white, width: 2),
              left: BorderSide(color: Colors.white, width: 2),
              bottom: BorderSide(color: Colors.black54, width: 2),
              right: BorderSide(color: Colors.black54, width: 2),
            ),
          ),
          child: Text(
            '+ Nova tarefa',
            style: GoogleFonts.pressStart2p(
              color: const Color(0xFF0040FF),
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
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

  Color get _textColor => switch (filter) {
    TaskFilter.all => const Color(0xFF57B8FF),
    TaskFilter.pending => const Color(0xFF00CFCF),
    TaskFilter.completed => const Color(0xFF0040FF),
  };

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == current;

    return GestureDetector(
      onTap: () => context.read<TaskController>().setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCCCCCC) : const Color(0xFFEEEEEE),
          border: Border(
            top: BorderSide(
              color: isSelected ? Colors.black54 : Colors.white,
              width: 2,
            ),
            left: BorderSide(
              color: isSelected ? Colors.black54 : Colors.white,
              width: 2,
            ),
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.black54,
              width: 2,
            ),
            right: BorderSide(
              color: isSelected ? Colors.white : Colors.black54,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
