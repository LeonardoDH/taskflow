import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/task_model.dart';
import '../../state/task_controller.dart';

class TaskFormPage extends StatefulWidget {
  final TaskModel? task;

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late Priority _priority;
  DateTime? _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? Priority.medium;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<TaskController>();
    final now = DateTime.now();

    final task = _isEditing
        ? widget.task!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            dueDate: _dueDate,
            clearDueDate: _dueDate == null,
          )
        : TaskModel(
            id: '',
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            dueDate: _dueDate,
            createdAt: now,
            updatedAt: now,
          );

    final success = _isEditing
        ? await controller.updateTask(task)
        : await controller.createTask(task);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Erro ao salvar tarefa.'),
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskController>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar tarefa' : 'Nova tarefa',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RetroTextField(
                    controller: _titleController,
                    hint: 'Título',
                    hintColor: const Color(0xFF57B8FF),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Título obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _RetroTextField(
                    controller: _descriptionController,
                    hint: 'Descrição',
                    hintColor: const Color(0xFF00CFCF),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _RetroPriorityDropdown(
                    value: _priority,
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                  const SizedBox(height: 12),
                  _RetroDateRow(
                    dueDate: _dueDate,
                    onTap: _pickDate,
                    onClear: () => setState(() => _dueDate = null),
                  ),
                  const SizedBox(height: 32),
                  _RetroSubmitButton(
                    label: _isEditing ? 'Salvar alterações' : 'Criar tarefa',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Componentes retro ──────────────────────────────────────────────────────────

class _RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final String? hint;
  final Color hintColor;

  const _RetroTextField({
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.hint,
    this.hintColor = Colors.black38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide(color: Colors.black38, width: 2),
          left: BorderSide(color: Colors.black38, width: 2),
          bottom: BorderSide(color: Colors.white, width: 2),
          right: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: hintColor,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}

class _RetroPriorityDropdown extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority?> onChanged;

  const _RetroPriorityDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide(color: Colors.black38, width: 2),
          left: BorderSide(color: Colors.black38, width: 2),
          bottom: BorderSide(color: Colors.white, width: 2),
          right: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Priority>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: Colors.black87,
          ),
          items: const [
            DropdownMenuItem(value: Priority.high, child: Text('Alta')),
            DropdownMenuItem(value: Priority.medium, child: Text('Média')),
            DropdownMenuItem(value: Priority.low, child: Text('Baixa')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RetroDateRow extends StatelessWidget {
  final DateTime? dueDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _RetroDateRow({
    required this.dueDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          border: Border(
            top: BorderSide(color: Colors.black38, width: 2),
            left: BorderSide(color: Colors.black38, width: 2),
            bottom: BorderSide(color: Colors.white, width: 2),
            right: BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                border: Border(
                  top: BorderSide(color: Colors.black38, width: 1),
                  left: BorderSide(color: Colors.black38, width: 1),
                  bottom: BorderSide(color: Colors.white, width: 1),
                  right: BorderSide(color: Colors.white, width: 1),
                ),
              ),
              child: dueDate != null
                  ? const Icon(Icons.check, size: 12, color: Color(0xFF00CFCF))
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dueDate == null
                    ? 'Data limite (opcional)'
                    : 'Vence em ${DateFormat('dd/MM/yyyy').format(dueDate!)}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
            if (dueDate != null)
              GestureDetector(
                onTap: onClear,
                child: const Text(
                  'x',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RetroSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _RetroSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFDDDDDD),
          border: Border(
            top: BorderSide(color: Colors.white, width: 2),
            left: BorderSide(color: Colors.white, width: 2),
            bottom: BorderSide(color: Colors.black54, width: 2),
            right: BorderSide(color: Colors.black54, width: 2),
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0040FF),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0040FF),
                  ),
                ),
        ),
      ),
    );
  }
}
