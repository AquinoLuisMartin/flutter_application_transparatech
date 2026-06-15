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
  final List<StudentNotificationItem> _notifications = [
    StudentNotificationItem(
      id: '1',
      message: 'Document Verified: Q4 2025 Expense Report has been verified by the COSC Society auditor.',
      time: '2h ago',
      isRead: false,
    ),
    StudentNotificationItem(
      id: '2',
      message: 'New Submission: Maria Reyes submitted Tech Summit 2026 Budget Proposal for review.',
      time: '5h ago',
      isRead: false,
    ),
    StudentNotificationItem(
      id: '3',
      message: 'Audit Reminder: Monthly financial audit for COSC Society is due on March 30, 2026.',
      time: '1d ago',
      isRead: true,
    ),
    StudentNotificationItem(
      id: '4',
      message: 'Hash Integrity Alert: SSC-COSC Sponsorship Agreement flagged for hash mismatch. Manual review required.',
      time: '2d ago',
      isRead: false,
    ),
  ];

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
