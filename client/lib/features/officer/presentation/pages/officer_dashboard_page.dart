import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_home_page.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_documents_page.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_report_page.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_profile_page.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_submission_page.dart';

class OfficerDashboardPage extends StatefulWidget {
  const OfficerDashboardPage({super.key});

  @override
  State<OfficerDashboardPage> createState() => _OfficerDashboardPageState();
}

class _OfficerDashboardPageState extends State<OfficerDashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final officerProvider = Provider.of<OfficerProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      officerProvider.fetchStats(token);
      officerProvider.fetchDocuments(token);
    }
  }

  static const Color primaryBlue = Color(0xFF3B48F6);
  static const Color navyDark = Color(0xFF132A42);
  static const Color textLight = Color(0xFF64748B);

  final List<Widget> _pages = [
    const OfficerHomePage(),
    const OfficerDocumentsPage(),
    const OfficerSubmissionPage(), // Secondary page, main access via FAB
    const OfficerReportPage(),
    const OfficerProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Refresh data on tab change to home, docs or insights
    if (index == 0 || index == 1 || index == 3) {
      _loadData();
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Submit New Document',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: navyDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred submission method',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textLight,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildUploadOption(Icons.camera_enhance_rounded, 'Camera', Colors.blue, () => _handleUpload('Camera')),
                  _buildUploadOption(Icons.file_copy_rounded, 'File Manager', Colors.purple, () => _handleUpload('File Manager')),
                  _buildUploadOption(Icons.cloud_upload_rounded, 'Cloud Sync', Colors.indigo, () => _handleUpload('Cloud Sync')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: navyDark,
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpload(String method) async {
    Navigator.pop(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final officerProvider = Provider.of<OfficerProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading via $method...')),
    );

    final success = await officerProvider.uploadDocument(token, {
      'title': 'New Document (${DateTime.now().hour}:${DateTime.now().minute})',
      'description': 'Uploaded via $method',
      'filePath': 'uploads/temp_${DateTime.now().millisecondsSinceEpoch}.pdf',
      'fileSize': 1024,
      'fileType': 'PDF',
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document submitted successfully!'), backgroundColor: Colors.green),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(officerProvider.errorMessage ?? 'Upload failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          onPressed: _showUploadOptions,
          backgroundColor: primaryBlue,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          notchMargin: 12,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                _buildNavItem(1, Icons.folder_copy_rounded, 'Vault'),
                const SizedBox(width: 48), // Space for FAB
                _buildNavItem(3, Icons.analytics_rounded, 'Insights'),
                _buildNavItem(4, Icons.account_circle_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryBlue : textLight.withOpacity(0.5),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? primaryBlue : textLight.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

