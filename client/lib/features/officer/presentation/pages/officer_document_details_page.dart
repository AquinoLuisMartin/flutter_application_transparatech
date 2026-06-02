import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';
import 'package:flutter_application_transparatech/features/officer/data/models/officer_models.dart';

class OfficerDocumentDetailsPage extends StatefulWidget {
  final int documentId;

  const OfficerDocumentDetailsPage({super.key, required this.documentId});

  @override
  State<OfficerDocumentDetailsPage> createState() => _OfficerDocumentDetailsPageState();
}

class _OfficerDocumentDetailsPageState extends State<OfficerDocumentDetailsPage> {
  static const Color navyDark = Color(0xFF132A42);
  static const Color primaryBlue = Color(0xFF3B48F6);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF64748B);
  static const Color bgSoft = Color(0xFFF8FAFC);

  OfficerDocument? _document;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final officerProvider = Provider.of<OfficerProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      final doc = await officerProvider.fetchDocumentDetails(token, widget.documentId);
      if (mounted) {
        setState(() {
          _document = doc;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _archiveDocument() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final officerProvider = Provider.of<OfficerProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      final success = await officerProvider.archiveDocument(token, widget.documentId);
      if (mounted && success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document archived successfully'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(officerProvider.errorMessage ?? 'Failed to archive document'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Document Details',
          style: GoogleFonts.inter(
            color: textMain,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_document != null)
            IconButton(
              icon: const Icon(Icons.archive_outlined, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Archive Document'),
                    content: const Text('Are you sure you want to archive this document? it will be removed from your active list.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _archiveDocument();
                        },
                        child: const Text('Archive', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _document == null
              ? Center(child: Text('Document not found', style: GoogleFonts.inter(color: textLight)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(_document!),
                      const SizedBox(height: 32),
                      _buildSectionTitle('General Information'),
                      const SizedBox(height: 16),
                      _buildInfoRow('Description', _document!.description ?? 'No description provided'),
                      _buildInfoRow('File Type', _document!.fileType ?? 'Unknown'),
                      _buildInfoRow('File Size', '${((_document!.fileSize ?? 0) / 1024).toStringAsFixed(2)} KB'),
                      _buildInfoRow('Created At', '${_document!.createdAt.day}/${_document!.createdAt.month}/${_document!.createdAt.year}'),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Security & Verification'),
                      const SizedBox(height: 16),
                      _buildSecurityStatus(),
                      const SizedBox(height: 40),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(OfficerDocument doc) {
    Color statusColor = Colors.orange;
    if (doc.status == 'APPROVED') statusColor = Colors.green;
    if (doc.status == 'REJECTED') statusColor = Colors.red;
    if (doc.status == 'ARCHIVED') statusColor = Colors.grey;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: navyDark.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _getIconForFile(doc.title),
            color: navyDark,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  doc.status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textMain,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textMain,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHA-256 Integrity Verified',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textMain,
                  ),
                ),
                Text(
                  'The document hash matches the blockchain record.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: bgSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: textMain),
            onPressed: () {},
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  IconData _getIconForFile(String name) {
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (name.endsWith('.xlsx')) return Icons.table_chart_rounded;
    if (name.endsWith('.zip')) return Icons.folder_zip_rounded;
    return Icons.insert_drive_file_rounded;
  }
}
