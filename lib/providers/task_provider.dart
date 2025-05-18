import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../utils/datetime_utils.dart';
import '../utils/notification_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  
  // Görev listesini getir
  List<Task> get tasks => [..._tasks];

  // Tamamlanmamış görevleri getir
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();

  // Tamamlanmış görevleri getir
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  // Belirli bir kategorideki görevleri getir
  List<Task> getTasksByCategory(String category) {
    return _tasks
        .where((task) => task.category == category && !task.isCompleted)
        .toList();
  }

  // Belirli bir tarihteki görevleri getir
  List<Task> getTasksByDate(DateTime date) {
    return _tasks
        .where((task) => 
            DateTimeUtils.isSameDay(task.date, date) && !task.isCompleted)
        .toList();
  }

  // Verileri SharedPreferences'dan yükle
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    
    _tasks = tasksJson
        .map((taskJson) => Task.fromJson(jsonDecode(taskJson)))
        .toList();
    
    _tasks.sort((a, b) => a.combinedDateTime.compareTo(b.combinedDateTime));
    notifyListeners();
  }

  // Verileri SharedPreferences'a kaydet
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    
    await prefs.setStringList('tasks', tasksJson);
  }

  // Yeni görev ekle
  Future<bool> addTask(Task newTask) async {
    // Aynı zaman aralığında başka bir görev var mı kontrol et
    final hasConflict = _tasks.any((existingTask) => 
      !existingTask.isCompleted && 
      DateTimeUtils.isTimeConflict(existingTask.combinedDateTime, newTask.combinedDateTime)
    );

    if (hasConflict) {
      return false; // Çakışma var, görevi ekleme
    }

    _tasks.add(newTask);
    _tasks.sort((a, b) => a.combinedDateTime.compareTo(b.combinedDateTime));
    
    // Görev bildirimi oluştur
    await NotificationHelper.scheduleTaskNotification(newTask);
    
    // Değişiklikleri kaydet
    await saveTasks();
    notifyListeners();
    return true;
  }

  // Görevi güncelle
  Future<bool> updateTask(Task updatedTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    
    if (taskIndex < 0) {
      return false; // Görev bulunamadı
    }

    // Güncellenen görevin zamanı diğer görevlerle çakışıyor mu kontrol et
    final hasConflict = _tasks.any((existingTask) => 
      existingTask.id != updatedTask.id && 
      !existingTask.isCompleted && 
      DateTimeUtils.isTimeConflict(existingTask.combinedDateTime, updatedTask.combinedDateTime)
    );

    if (hasConflict) {
      return false; // Çakışma var, görevi güncelleme
    }

    // Eski görevin bildirimini iptal et
    await NotificationHelper.cancelTaskNotification(_tasks[taskIndex]);
    
    // Görevi güncelle
    _tasks[taskIndex] = updatedTask;
    _tasks.sort((a, b) => a.combinedDateTime.compareTo(b.combinedDateTime));
    
    // Yeni görev bildirimi oluştur (tamamlanmamışsa)
    if (!updatedTask.isCompleted) {
      await NotificationHelper.scheduleTaskNotification(updatedTask);
    }
    
    // Değişiklikleri kaydet
    await saveTasks();
    notifyListeners();
    return true;
  }

  // Görev tamamlama durumunu değiştir
  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    
    if (taskIndex < 0) {
      return; // Görev bulunamadı
    }

    final task = _tasks[taskIndex];
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    
    // Görevi güncelle
    _tasks[taskIndex] = updatedTask;
    
    // Görev tamamlandıysa bildirimini iptal et
    if (updatedTask.isCompleted) {
      await NotificationHelper.cancelTaskNotification(updatedTask);
    } else {
      // Görev tekrar aktifleştirildiyse ve zamanı gelmediyse bildirim ekle
      if (updatedTask.combinedDateTime.isAfter(DateTime.now())) {
        await NotificationHelper.scheduleTaskNotification(updatedTask);
      }
    }
    
    // Değişiklikleri kaydet
    await saveTasks();
    notifyListeners();
  }

  // Görevi sil
  Future<void> deleteTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    
    if (taskIndex < 0) {
      return; // Görev bulunamadı
    }

    // Görevin bildirimini iptal et
    await NotificationHelper.cancelTaskNotification(_tasks[taskIndex]);
    
    // Görevi listeden kaldır
    _tasks.removeAt(taskIndex);
    
    // Değişiklikleri kaydet
    await saveTasks();
    notifyListeners();
  }
}