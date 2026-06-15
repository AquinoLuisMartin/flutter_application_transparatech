import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  
  final _amountFocusNode = FocusNode();
  String? _selectedOrg;
  String? _selectedFileName;
  int? _selectedFileSize;
  String? _selectedFileType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(_onAmountFocusChange);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountFocusNode.removeListener(_onAmountFocusChange);
    _amountFocusNode.dispose();
    _amountController.removeListener(_onAmountChanged);
    _orgController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onAmountFocusChange() {
    if (_amountFocusNode.hasFocus) {
      if (_amountController.text.isEmpty) {
        _amountController.text = '₱ ';
        _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length),
        );
      }
    } else {
      if (_amountController.text.trim() == '₱' || _amountController.text.trim().isEmpty) {
        _amountController.clear();
      } else {
        final cleanText = _amountController.text.replaceAll(RegExp(r'[^\d.]'), '');
        final doubleValue = double.tryParse(cleanText);
        if (doubleValue != null) {
          _amountController.text = '₱ ${doubleValue.toStringAsFixed(2)}';
        }
      }
    }
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    if (_amountFocusNode.hasFocus) {
      String cleanText = text.replaceAll('₱', '').trim();
      cleanText = cleanText.replaceAll(RegExp(r'[^\d.]'), '');
      
      final parts = cleanText.split('.');
      if (parts.length > 2) {
        cleanText = '${parts[0]}.${parts.sublist(1).join('')}';
      }
      
      final newText = '₱ $cleanText';
      if (text != newText) {
        _amountController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          ),
        );
      }
    }
  }

  String get _titleLabel {
    if (widget.category == 'Receipt / Invoice') {
      return 'Associated Event Title *';
    } else if (widget.category == 'Audit Certificate') {
      return 'Audit Period / Title *';
    } else {
      return 'Proposal Title *';
    }
  }

  String get _titleHint {
    if (widget.category == 'Receipt / Invoice') {
      return 'e.g. Year-End General Assembly';
    } else if (widget.category == 'Audit Certificate') {
      return 'e.g. AY 2025-2026 Year-End';
    } else {
      return 'e.g. 2026 Expense Report';
    }
  }

  String get _amountLabel {
    if (widget.category == 'Receipt / Invoice') {
      return 'Total Amount Spent *';
    } else if (widget.category == 'Audit Certificate') {
      return 'Ending Balance *';
    } else {
      return 'Proposed Amount *';
    }
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      if (widget.category == 'Receipt / Invoice') {
        return 'Associated Event Title is required';
      } else if (widget.category == 'Audit Certificate') {
        return 'Audit Period / Title is required';
      } else {
        return 'Proposal Title is required';
      }
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty || value.trim() == '₱') {
      if (widget.category == 'Receipt / Invoice') {
        return 'Total Amount Spent is required';
      } else if (widget.category == 'Audit Certificate') {
        return 'Ending Balance is required';
      } else {
        return 'Proposed Amount is required';
      }
    }
    final cleanText = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleanText.isEmpty) {
      return 'Please enter a valid number';
    }
    final parsed = double.tryParse(cleanText);
    if (parsed == null || parsed <= 0) {
      return 'Please enter an amount greater than zero';
    }
    return null;
  }

  Future<void> _pickDocument() async {
    try {
      final selection = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Document Source',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF3B48F6)),
                  title: const Text('Browse Files (PDF, Docs, Images)'),
                  onTap: () => Navigator.pop(context, 'file'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
                  title: const Text('Take Photo of Receipt / Document'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
              ],
            ),
          );
        },
      );

      if (selection == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            _selectedFileName = file.name;
            _selectedFileSize = file.size;
            _selectedFileType = file.extension != null ? 'application/${file.extension}' : 'application/octet-stream';
          });
        }
      } else if (selection == 'camera') {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);

        if (image != null) {
          final size = await image.length();
          setState(() {
            _selectedFileName = image.name;
            _selectedFileSize = size;
            _selectedFileType = 'image/jpeg';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileSize = null;
      _selectedFileType = null;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
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

      final orgVal = _selectedOrg ?? '';
      final amountVal = _amountController.text.trim();
      final userDesc = _descController.text.trim();

      final descriptionBuffer = StringBuffer();
      descriptionBuffer.writeln(userDesc);
      descriptionBuffer.writeln();
      descriptionBuffer.writeln('Organization: $orgVal');
      
      if (widget.category == 'Expense Report' || widget.category == 'Budget Proposal') {
        descriptionBuffer.writeln('Proposed Amount: $amountVal');
      } else if (widget.category == 'Receipt / Invoice') {
        descriptionBuffer.writeln('Total Amount Spent: $amountVal');
      } else if (widget.category == 'Audit Certificate') {
        descriptionBuffer.writeln('Ending Balance: $amountVal');
      }

      final payloadDescription = descriptionBuffer.toString().trim();

      final success = await docProvider.uploadDocument(
        token: token,
        title: _titleController.text.trim(),
        description: payloadDescription,
        filePath: _selectedFileName!,
        fileSize: _selectedFileSize ?? 0,
        fileType: _selectedFileType ?? 'application/pdf',
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
                Expanded(
                  child: Text(
                    'Upload Financial Documents',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      onTap: _selectedFileName == null ? _pickDocument : null,
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
                                            '${_formatBytes(_selectedFileSize ?? 0)} • Ready to submit',
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
                    CustomDropdownField<String>(
                      label: 'Organization *',
                      value: _selectedOrg,
                      hintText: 'e.g. iSITE',
                      fontSize: 12,
                      items: const [
                        DropdownMenuItem(value: 'ACES', child: Text('Alliance of Computer Engineering Students (ACES)')),
                        DropdownMenuItem(value: 'iSITE', child: Text('Integrated Students in Information Technology Education (iSITE)')),
                        DropdownMenuItem(value: 'AFT', child: Text('Association of Future Teachers (AFT)')),
                        DropdownMenuItem(value: 'HMSOC', child: Text('Hospitality Management Society (HMSOC)')),
                        DropdownMenuItem(value: 'CEM', child: Text('Chamber of Entrepreneurs and Managers (CEM)')),
                        DropdownMenuItem(value: 'JPIA', child: Text('Junior Philippine Institute of Accountancy - Sta Maria (JPIA)')),
                        DropdownMenuItem(value: 'DOMT', child: Text('Diploma in Office Management SY-Quest (DOMT)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOrg = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Organization is required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextFormField(
                      label: _titleLabel,
                      hintText: _titleHint,
                      controller: _titleController,
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextFormField(
                      label: _amountLabel,
                      hintText: 'e.g. 0,000.00',
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      inputType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateAmount,
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
