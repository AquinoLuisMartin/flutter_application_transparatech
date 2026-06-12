import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/document_analysis/presentation/providers/document_provider.dart';

/// Screen for uploading financial documents, categorized by document type
class UploadPage extends StatefulWidget {
  /// Selected category name (e.g. 'Expense Report', 'Budget Proposal')
  final String category;

  /// Constructor for UploadPage
  const UploadPage({
    super.key,
    required this.category,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgController = TextEditingController();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  
  String? _selectedFileName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _orgController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _simulateFileUpload() {
    setState(() {
      _selectedFileName = 'Q4_2025_Expenses_Receipts.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected file: Q4_2025_Expenses_Receipts.pdf (14.2 MB)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeFile() {
    setState(() {
      _selectedFileName = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or upload a document first.'),
            backgroundColor: VeriFiColors.error,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final docProvider = Provider.of<DocumentProvider>(context, listen: false);

      final token = authProvider.token;
      if (token == null) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: VeriFiColors.error,
          ),
        );
        return;
      }

      final success = await docProvider.uploadDocument(
        token: token,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        filePath: _selectedFileName!,
        fileSize: 1024 * 142, // default simulated file size
        fileType: 'application/pdf',
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.category} successfully submitted to audit trail!'),
              backgroundColor: VeriFiColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(docProvider.errorMessage ?? 'Failed to submit document.'),
              backgroundColor: VeriFiColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeriFiColors.background,
      body: Column(
        children: [
          // Header (Dark blue banner with custom back circle button)
          Container(
            width: double.infinity,
            color: const Color(0xFF132A42),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Upload Financial Documents',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Heading
                    Text(
                      widget.category,
                      style: VeriFiTypography.sectionTitle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Upload Document section
                    Text(
                      'Upload Document *',
                      style: VeriFiTypography.label.copyWith(
                        color: VeriFiColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    GestureDetector(
                      onTap: _selectedFileName == null ? _simulateFileUpload : null,
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: const Color(0xFFDCDCE6),
                          borderRadius: 20,
                          strokeWidth: 1.5,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _selectedFileName != null
                              ? Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: VeriFiColors.secondaryEE,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.picture_as_pdf,
                                        color: VeriFiColors.primary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedFileName!,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: VeriFiColors.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '14.2 MB • Ready to submit',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: VeriFiColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: VeriFiColors.error),
                                      onPressed: _removeFile,
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Custom grey box holding upload icon
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            color: Color(0xFF7C8BA1),
                                            size: 32,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tap to upload',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF7C8BA1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Upload Document or Take Photo',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '.pdf, .docs (Max 100mb)',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form fields
                    CustomTextFormField(
                      label: 'Organization *',
                      hintText: 'e.g. ISITE',
                      controller: _orgController,
                      validator: (value) => value == null || value.isEmpty ? 'Organization is required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextFormField(
                      label: 'Proposal Title *',
                      hintText: 'e.g. 2026 Expense Report',
                      controller: _titleController,
                      validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextFormField(
                      label: 'Proposed Amount *',
                      hintText: 'e.g. ISITE',
                      controller: _amountController,
                      validator: (value) => value == null || value.isEmpty ? 'Amount is required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextFormField(
                      label: 'Description *',
                      hintText: 'Provide a brief explanation of this document',
                      maxLines: 4,
                      controller: _descController,
                      validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit button
                    PrimaryButton(
                      label: 'Submit',
                      onPressed: _handleSubmit,
                      isLoading: _isSubmitting,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for drawing rounded dashed borders
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1,
    this.gap = 4,
    this.dashLength = 6,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final Path dashPath = Path();
    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
