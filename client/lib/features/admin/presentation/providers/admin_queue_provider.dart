import 'package:flutter/material.dart';

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
  late List<QueueSubmission> _submissions;
  late List<UserItem> _allUsers;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String _selectedStatusFilter = 'PENDING'; // 'PENDING', 'APPROVED', or 'REJECTED'

  AdminQueueProvider() {
    // Initialize mock users
    _allUsers = [
      UserItem(fullName: 'Princess Dianne Pastrana', email: 'princesspastrana@gmail.com', role: 'Officers', organization: 'JPIA'),
      UserItem(fullName: 'Ellayssa Aguilar', email: 'ellayssaaguilar@gmail.com', role: 'Officers', organization: 'iSITE'),
      UserItem(fullName: 'Bob Johnson', email: 'bobjohnson@gmail.com', role: 'Officers', organization: 'CEM'),
      UserItem(fullName: 'Emily Davis', email: 'emilydavis@gmail.com', role: 'Officers', organization: 'iSITE'),
      UserItem(fullName: 'John Doe', email: 'johndoe@gmail.com', role: 'Admin', organization: 'ACES'),
      UserItem(fullName: 'Alice Williams', email: 'alicewilliams@gmail.com', role: 'Admin', organization: 'HMSOC'),
      UserItem(fullName: 'Jane Smith', email: 'janesmith@gmail.com', role: 'Student', organization: 'AFT'),
      UserItem(fullName: 'Michael Brown', email: 'michaelbrown@gmail.com', role: 'Student', organization: 'JPIA'),
      UserItem(fullName: 'David Miller', email: 'davidmiller@gmail.com', role: 'Student', organization: 'ACES'),
      UserItem(fullName: 'Sarah Wilson', email: 'sarahwilson@gmail.com', role: 'Student', organization: 'AFT'),
      UserItem(fullName: 'James Taylor', email: 'jamestaylor@gmail.com', role: 'Student', organization: 'CEM'),
      UserItem(fullName: 'Jessica Thomas', email: 'jessicathomas@gmail.com', role: 'Student', organization: 'HMSOC'),
      UserItem(fullName: 'Robert Anderson', email: 'robertanderson@gmail.com', role: 'Student', organization: 'JPIA'),
      UserItem(fullName: 'Jennifer Jackson', email: 'jenniferjackson@gmail.com', role: 'Student', organization: 'iSITE'),
      UserItem(fullName: 'William White', email: 'williamwhite@gmail.com', role: 'Student', organization: 'ACES'),
      UserItem(fullName: 'Linda Harris', email: 'lindaharris@gmail.com', role: 'Student', organization: 'AFT'),
      UserItem(fullName: 'Richard Martin', email: 'richardmartin@gmail.com', role: 'Student', organization: 'CEM'),
      UserItem(fullName: 'Patricia Garcia', email: 'patriciagarcia@gmail.com', role: 'Student', organization: 'HMSOC'),
    ];
    // Initialize mock data
    _submissions = [
      QueueSubmission(
        id: '1',
        title: 'Tech Summit 2026 Event Budget',
        organization: 'ISITE',
        senderName: 'Maria Reyes',
        documentType: 'Budget Proposal',
        uploadDate: DateTime(2026, 6, 12, 10, 30),
        fileSize: '2.4 MB',
        description: 'Detailed budget proposal for the upcoming national IT Tech Summit 2026. Covers venue cost, food catering, speaker honorariums, and marketing assets.',
        accuracy: 94.5,
        flags: ['Mismatched food package totals', 'Incomplete speaker profile details'],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '2',
        title: 'COSC Society Q1 2026 Audit',
        organization: 'COSC',
        senderName: 'John Doe',
        documentType: 'Audit Report',
        uploadDate: DateTime(2026, 6, 11, 14, 15),
        fileSize: '4.1 MB',
        description: 'Quarterly financial audit for the first quarter of the academic year 2026. Includes balance sheets, receipts, and bank reconciliation statements.',
        accuracy: 98.2,
        flags: [],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '3',
        title: 'JPCS Membership Fee Report',
        organization: 'JPCS',
        senderName: 'Alicia Keys',
        documentType: 'Financial Report',
        uploadDate: DateTime(2026, 6, 10, 9, 0),
        fileSize: '1.8 MB',
        description: 'Report showing membership fees collected from 340 active student members. Contains a list of payees, receipt numbers, and deposit vouchers.',
        accuracy: 91.0,
        flags: ['Missing 3 official transaction receipt attachments'],
        status: 'APPROVED',
      ),
      QueueSubmission(
        id: '4',
        title: 'COSC Society Q4 2025 Expense',
        organization: 'COSC',
        senderName: 'Juan Santos',
        documentType: 'Budget Proposal',
        uploadDate: DateTime(2026, 6, 9, 16, 45),
        fileSize: '3.2 MB',
        description: 'Expenses incurred during the end-of-year general assembly and student awards ceremony held in December 2025.',
        accuracy: 95.0,
        flags: [],
        status: 'APPROVED',
      ),
      QueueSubmission(
        id: '5',
        title: 'WebDev Club Hosting Invoice',
        organization: 'WEBDEV',
        senderName: 'Liam Martinez',
        documentType: 'Invoice',
        uploadDate: DateTime(2026, 6, 8, 11, 20),
        fileSize: '780 KB',
        description: 'Billing invoice for domain names and shared cloud hosting subscriptions of the club\'s portfolio website.',
        accuracy: 89.4,
        flags: ['Unverified vendor bank details', 'Due date listed is in the past'],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '6',
        title: 'CS Cup 2026 Sports Fest Proposal',
        organization: 'COSC',
        senderName: 'Diana Prince',
        documentType: 'Sponsorship Proposal',
        uploadDate: DateTime(2026, 6, 7, 15, 30),
        fileSize: '5.5 MB',
        description: 'Sports equipment procurement and tournament venue booking proposals for the upcoming college sports festival.',
        accuracy: 97.6,
        flags: [],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '7',
        title: 'PUP Hackathon Sponsorship Proposal',
        organization: 'ISITE',
        senderName: 'Peter Parker',
        documentType: 'Sponsorship Proposal',
        uploadDate: DateTime(2026, 6, 5, 8, 45),
        fileSize: '6.1 MB',
        description: 'Proposals seeking external corporate sponsorships from tech companies for the annual university-wide hackathon.',
        accuracy: 84.1,
        flags: ['Missing signatures from organization advisers', 'High risk of budget overrun'],
        status: 'REJECTED',
      ),
      QueueSubmission(
        id: '8',
        title: 'Data Science Club Workshop Budget',
        organization: 'DSC',
        senderName: 'Jane Foster',
        documentType: 'Budget Proposal',
        uploadDate: DateTime(2026, 6, 4, 13, 10),
        fileSize: '2.9 MB',
        description: 'Funds required for purchasing learning certificates and hosting an external speaker for a Python Data Science workshop.',
        accuracy: 96.0,
        flags: [],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '9',
        title: 'JPMAP Annual Conference Fee Reimbursement',
        organization: 'JPMAP',
        senderName: 'Bruce Wayne',
        documentType: 'Expense Report',
        uploadDate: DateTime(2026, 5, 28, 10, 15),
        fileSize: '1.5 MB',
        description: 'Travel expenses, accommodation, and ticket registrations for JPMAP delegates who attended the national convention.',
        accuracy: 93.8,
        flags: ['Incomplete food allowance receipts'],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '10',
        title: 'AITS Society Technical BootCamp Budget',
        organization: 'AITS',
        senderName: 'Clark Kent',
        documentType: 'Budget Proposal',
        uploadDate: DateTime(2026, 5, 25, 11, 40),
        fileSize: '3.8 MB',
        description: 'Detailed proposal for classroom reservations, networking equipment hardware rentals, and certificate printing costs.',
        accuracy: 99.1,
        flags: [],
        status: 'PENDING',
      ),
      QueueSubmission(
        id: '11',
        title: 'GDSC PUP App Dev Hackathon Prizes',
        organization: 'GDSC',
        senderName: 'Barry Allen',
        documentType: 'Budget Proposal',
        uploadDate: DateTime(2026, 5, 20, 14, 50),
        fileSize: '2.1 MB',
        description: 'Cash awards procurement and physical trophy engraving requests for top three team submissions.',
        accuracy: 97.4,
        flags: [],
        status: 'APPROVED',
      ),
      QueueSubmission(
        id: '12',
        title: 'Math Society Q4 Seminar Funds',
        organization: 'MATHSOC',
        senderName: 'Selina Kyle',
        documentType: 'Budget Proposal',
        uploadDate: DateTime(2026, 5, 15, 16, 20),
        fileSize: '1.7 MB',
        description: 'Detailed logistics budget for hosting the regional math seminar. Cover honorarium for guest professors.',
        accuracy: 88.5,
        flags: ['Incorrect tax calculation for guest honorariums'],
        status: 'REJECTED',
      ),
    ];
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

  void updateSubmissionStatus(String id, String newStatus) {
    final index = _submissions.indexWhere((element) => element.id == id);
    if (index != -1) {
      _submissions[index].status = newStatus;
      notifyListeners();
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
