import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasksRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future<void> createTask(String uid, TaskModel task) {
    final id = _uuid.v4();
    return _tasksRef(uid).doc(id).set(task.toJson());
  }

  Future<void> updateTask(String uid, TaskModel task) {
    return _tasksRef(uid).doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String uid, String taskId) {
    return _tasksRef(uid).doc(taskId).delete();
  }
}
