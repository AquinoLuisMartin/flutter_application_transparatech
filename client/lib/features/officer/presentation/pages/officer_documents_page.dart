import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';
import 'package:flutter_application_transparatech/features/officer/data/models/officer_models.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_document_details_page.dart';
import 'dart:async';

class OfficerDocumentsPage extends StatefulWidget {
  const OfficerDocumentsPage({super.key});

  @override
  State<OfficerDocumentsPage> createState() => _OfficerDocumentsPageState();
}

class _OfficerDocumentsPageState extends State<OfficerDocumentsPage> {
  static const Color primaryBlue = Color(0xFF3B48F6);
  static const Color navyDark = Color(0xFF132A42);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF64748B);
  static const Color bgSoft = Color(0xFFF8FAFC);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final officerProvider = Provider.of<OfficerProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        officerProvider.fetchDocuments(token, search: query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final officerProvider = Provider.of<OfficerProvider>(context);
    final docs = officerProvider.documents;

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Document Repository',
          style: GoogleFonts.inter(
            color: textMain,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: textMain),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final token = authProvider.token;
              if (token != null) {
                officerProvider.fetchDocuments(token, search: _searchController.text);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: officerProvider.isLoading && docs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : docs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No documents found',
                              style: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          Color statusColor = Colors.orange;
                          if (doc.status == 'APPROVED') statusColor = Colors.green;
                          if (doc.status == 'REJECTED') statusColor = Colors.red;
                          if (doc.status == 'ARCHIVED') statusColor = Colors.grey;
                          if (doc.status == 'DRAFT') statusColor = Colors.blueGrey;

                          String dateStr = '${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}';

                          return _buildDocItem(doc, dateStr, statusColor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bgSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search by title or description...',
            hintStyle: GoogleFonts.inter(color: textLight, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: textLight, size: 20),
            suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDocItem(OfficerDocument doc, String date, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfficerDocumentDetailsPage(documentId: doc.id),
            ),
          );
          if (result == true) {
            // Refresh if document was archived
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final token = authProvider.token;
            if (token != null) {
              officerProvider.fetchDocuments(token, search: _searchController.text);
              officerProvider.fetchStats(token);
            }
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: navyDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getIconForFile(doc.title),
                color: navyDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Modified $date',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
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
    );
  }

  IconData _getIconForFile(String name) {
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (name.endsWith('.xlsx')) return Icons.table_chart_rounded;
    if (name.endsWith('.zip')) return Icons.folder_zip_rounded;
    return Icons.insert_drive_file_rounded;
  }
}

