import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
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

    final success =
        _isEditing ? await controller.updateTask(task) : await controller.createTask(task);

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
        title: Text(_isEditing ? 'Editar tarefa' : 'Nova tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Título',
                controller: _titleController,
                validator: (v) => Validators.required(v, label: 'Título'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Descrição (opcional)',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Priority>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: const [
                  DropdownMenuItem(value: Priority.high, child: Text('Alta')),
                  DropdownMenuItem(
                      value: Priority.medium, child: Text('Média')),
                  DropdownMenuItem(value: Priority.low, child: Text('Baixa')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _dueDate == null
                      ? 'Data limite (opcional)'
                      : 'Vence em ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                ),
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      )
                    : null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: _isEditing ? 'Salvar alterações' : 'Criar tarefa',
                onPressed: _submit,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
