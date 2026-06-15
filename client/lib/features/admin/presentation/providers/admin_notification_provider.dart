import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String message;
  final String time;
  final String type; // 'QUEUE', 'ORG', 'USER'
  bool isRead;
  final Map<String, dynamic>? deepLinkData;

  NotificationItem({
    required this.id,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.deepLinkData,
  });
}

class AdminNotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      message: 'ACES submitted Q1 2026 Audit Report.',
      time: '2 mins ago',
      type: 'QUEUE',
      isRead: false,
      deepLinkData: {'statusFilter': 'PENDING', 'highlightQuery': 'ACES Q1 2026 Audit Report'},
    ),
    NotificationItem(
      id: '2',
      message: 'iSITE roster updated: Total registered members have grown to 409 users.',
      time: '2 hours ago',
      type: 'ORG',
      isRead: true,
      deepLinkData: {'orgFilter': 'iSITE'},
    ),
    NotificationItem(
      id: '3',
      message: "New Organization Request: 'CS Cup Sports Committee' has submitted an application dossier.",
      time: '5 hours ago',
      type: 'ORG',
      isRead: true,
      deepLinkData: {'orgFilter': 'CS Cup'},
    ),
    NotificationItem(
      id: '4',
      message: 'Access Request: Ellayssa Aguilar requested promotion to Officer for iSITE.',
      time: '1 day ago',
      type: 'USER',
      isRead: true,
      deepLinkData: {'roleFilter': 'Officers'},
    ),
    NotificationItem(
      id: '5',
      message: 'System Action: Profile record for Princess Dianne Pastrana successfully moved to Activity Logs Archive.',
      time: '2 days ago',
      type: 'USER',
      isRead: true,
      deepLinkData: {'roleFilter': 'Officers'},
    ),
  ];

  int? _navigateToTab;
  String? _orgFilter;
  String? _roleFilter;

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  int? get navigateToTab => _navigateToTab;
  String? get orgFilter => _orgFilter;
  String? get roleFilter => _roleFilter;

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

  void performNavigation(int tabIndex, {String? orgFilter, String? roleFilter}) {
    _navigateToTab = tabIndex;
    _orgFilter = orgFilter;
    _roleFilter = roleFilter;
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToTab = null;
    _orgFilter = null;
    _roleFilter = null;
  }
}
