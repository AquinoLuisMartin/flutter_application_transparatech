import 'package:flutter/material.dart';
import 'package:flutter_application_transparatech/core/network/http_client.dart';

class UserItem {
  String fullName;
  String email;
  String role; // 'Admin', 'Officers', or 'Student'
  String organization; // 'JPIA', 'iSITE', 'ACES', 'AFT', 'CEM', 'HMSOC'
  String lastLogin;
  bool isActive;
  String systemFlag; // 'ACTIVE' or 'ARCHIVED'

  UserItem({
    required this.fullName,
    required this.email,
    required this.role,
    required this.organization,
    this.lastLogin = 'Last login: April 23, 2025',
    this.isActive = true,
    this.systemFlag = 'ACTIVE',
  });
}

/// Local model for submissions in the admin queue
class QueueSubmission {
  final String id;
  final String title;
  final String organization; // e.g., "COSC"
  final String senderName;
  final String documentType; // e.g., "Budget Proposal"
  final DateTime uploadDate;
  final String fileSize;
  final String description;
  final double accuracy;
  final List<String> flags;
  String status; // 'PENDING', 'APPROVED', 'REJECTED'

  QueueSubmission({
    required this.id,
    required this.title,
    required this.organization,
    required this.senderName,
    required this.documentType,
    required this.uploadDate,
    required this.fileSize,
    required this.description,
    required this.accuracy,
    required this.flags,
    this.status = 'PENDING',
  });
}

class AdminQueueProvider extends ChangeNotifier {
  final HttpClient _httpClient = ApiClient();
  late List<QueueSubmission> _submissions;
  late List<UserItem> _allUsers;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String _selectedStatusFilter = 'PENDING'; // 'PENDING', 'APPROVED', or 'REJECTED'
  bool _isLoading = false;
  String? _errorMessage;

  AdminQueueProvider() {
    _submissions = [];
    _allUsers = [];
    fetchAllData();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch Users
      final usersResponse = await _httpClient.get('/api/admin/users');
      if (usersResponse.isSuccess) {
        final List<dynamic> usersData = usersResponse.data ?? [];
        _allUsers = usersData.map((u) => UserItem(
          fullName: u['fullName'] ?? '',
          email: u['email'] ?? '',
          role: u['role'] ?? '',
          organization: u['organization'] ?? '',
          lastLogin: u['lastLogin'] ?? '',
          isActive: u['isActive'] ?? true,
          systemFlag: u['systemFlag'] ?? 'ACTIVE',
        )).toList();
      }

      // 2. Fetch Submissions
      final docsResponse = await _httpClient.get('/api/admin/documents');
      if (docsResponse.isSuccess) {
        final List<dynamic> docsData = docsResponse.data ?? [];
        _submissions = docsData.map((d) => QueueSubmission(
          id: d['id'] ?? '',
          title: d['title'] ?? '',
          organization: d['organization'] ?? '',
          senderName: d['senderName'] ?? '',
          documentType: d['documentType'] ?? '',
          uploadDate: d['uploadDate'] != null ? DateTime.parse(d['uploadDate']) : DateTime.now(),
          fileSize: d['fileSize'] ?? '',
          description: d['description'] ?? '',
          accuracy: d['accuracy'] != null ? (d['accuracy'] as num).toDouble() : 100.0,
          flags: d['flags'] != null ? List<String>.from(d['flags']) : [],
          status: d['status'] ?? 'PENDING',
        )).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


  // Getters
  List<QueueSubmission> get submissions => _submissions;
  String get searchQuery => _searchQuery;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  String get selectedStatusFilter => _selectedStatusFilter;

  List<UserItem> get rawUsers => _allUsers;
  List<UserItem> get activeUsers => _allUsers.where((u) => u.systemFlag == 'ACTIVE').toList();
  List<UserItem> get archivedUsers => _allUsers.where((u) => u.systemFlag == 'ARCHIVED').toList();

  void archiveUser(UserItem user) {
    user.systemFlag = 'ARCHIVED';
    user.isActive = false;
    notifyListeners();
  }

  void restoreUser(UserItem user) {
    user.systemFlag = 'ACTIVE';
    user.isActive = true;
    notifyListeners();
  }

  void addUser(UserItem user) {
    _allUsers.add(user);
    notifyListeners();
  }

  void updateUser(int index, UserItem user) {
    _allUsers[index] = user;
    notifyListeners();
  }

  // Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setSelectedStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  Future<void> updateSubmissionStatus(String id, String newStatus) async {
    final index = _submissions.indexWhere((element) => element.id == id);
    if (index != -1) {
      final oldStatus = _submissions[index].status;
      _submissions[index].status = newStatus;
      notifyListeners();

      try {
        final response = await _httpClient.put('/api/admin/documents/$id/status', body: {
          'status': newStatus,
        });
        if (!response.isSuccess) {
          // Rollback
          _submissions[index].status = oldStatus;
          notifyListeners();
        }
      } catch (e) {
        _submissions[index].status = oldStatus;
        notifyListeners();
      }
    }
  }

  // Get list of filtered submissions
  List<QueueSubmission> getFilteredSubmissions({String? forceStatusFilter}) {
    final targetStatus = forceStatusFilter ?? _selectedStatusFilter;
    return _submissions.where((s) {
      // 1. Status Filter
      if (s.status != targetStatus) return false;

      // 2. Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = s.title.toLowerCase().contains(query);
        final matchesOrg = s.organization.toLowerCase().contains(query);
        final matchesSender = s.senderName.toLowerCase().contains(query);
        final matchesDocType = s.documentType.toLowerCase().contains(query);
        if (!matchesTitle && !matchesOrg && !matchesSender && !matchesDocType) {
          return false;
        }
      }

      // 3. Date range filter
      if (_selectedDateRange != null) {
        final uploadDate = s.uploadDate;
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
        if (uploadDate.isBefore(start) || uploadDate.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
