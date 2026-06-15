import 'package:flutter/material.dart';

class StudentNotificationItem {
  final String id;
  final String message;
  final String time;
  bool isRead;

  StudentNotificationItem({
    required this.id,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class StudentNotificationProvider with ChangeNotifier {
  // Notifications - to be fetched from server when notifications API is implemented
  final List<StudentNotificationItem> _notifications = [];

  List<StudentNotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }
}
