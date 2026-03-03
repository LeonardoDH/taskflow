import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/task_model.dart';
import '../data/task_repository.dart';

enum TaskFilter { all, pending, completed }

class TaskController extends ChangeNotifier {
  final TaskRepository _repository;

  List<TaskModel> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<TaskModel>>? _subscription;
  String? _uid;

  TaskController(this._repository);

  List<TaskModel> get tasks {
    return switch (_filter) {
      TaskFilter.pending => _tasks.where((t) => !t.isCompleted).toList(),
      TaskFilter.completed => _tasks.where((t) => t.isCompleted).toList(),
      TaskFilter.all => _tasks,
    };
  }

  TaskFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadTasks(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = _repository.watchTasks(uid).listen(
      (tasks) {
        _tasks = tasks;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Erro ao carregar tarefas.';
        notifyListeners();
      },
    );
  }

  void clearTasks() {
    _subscription?.cancel();
    _subscription = null;
    _uid = null;
    _tasks = [];
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<bool> createTask(TaskModel task) =>
      _runAction(() => _repository.createTask(_uid!, task));

  Future<bool> updateTask(TaskModel task) =>
      _runAction(() => _repository.updateTask(_uid!, task));

  Future<bool> toggleCompleted(TaskModel task) => _runAction(
        () => _repository.updateTask(
          _uid!,
          task.copyWith(isCompleted: !task.isCompleted),
        ),
      );

  Future<bool> deleteTask(String taskId) =>
      _runAction(() => _repository.deleteTask(_uid!, taskId));

  Future<bool> _runAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      _errorMessage = 'Operação falhou. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
