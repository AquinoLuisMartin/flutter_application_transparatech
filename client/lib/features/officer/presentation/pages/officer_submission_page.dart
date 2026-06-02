import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';

class OfficerSubmissionPage extends StatefulWidget {
  const OfficerSubmissionPage({super.key});

  @override
  State<OfficerSubmissionPage> createState() => _OfficerSubmissionPageState();
}

class _OfficerSubmissionPageState extends State<OfficerSubmissionPage> {
  bool _isScanning = false;
  bool _scanComplete = false;
  String? _scannedTitle;

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // Simulate AI Scanning
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanComplete = true;
          _scannedTitle = 'Maintenance Report - ${DateTime.now().month}/${DateTime.now().year}';
        });
      }
    });
  }

  Future<void> _submitDocument() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final officerProvider = Provider.of<OfficerProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    final success = await officerProvider.uploadDocument(token, {
      'title': _scannedTitle ?? 'Manual Submission',
      'description': 'AI Scanned financial document',
      'filePath': 'uploads/financial_doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
      'fileSize': 2048,
      'fileType': 'application/pdf',
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document submitted for verification'), backgroundColor: Colors.green),
        );
        setState(() {
          _scanComplete = false;
          _scannedTitle = null;
        });
        // Optionally navigate back to home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(officerProvider.errorMessage ?? 'Submission failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officerProvider = Provider.of<OfficerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submit Document',
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: officerProvider.isLoading && !_isScanning
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Financial Document',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI will automatically scan and extract data from your document for faster verification.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Upload Area
                  GestureDetector(
                    onTap: _isScanning || _scanComplete ? null : _startScanning,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF3B48F6).withOpacity(0.3),
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isScanning && !_scanComplete) ...[
                            const Icon(Icons.cloud_upload_outlined, size: 48, color: Color(0xFF3B48F6)),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to select a file',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B48F6),
                              ),
                            ),
                            Text(
                              'PDF, PNG, JPG up to 10MB',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ] else if (_isScanning) ...[
                            const CircularProgressIndicator(color: Color(0xFF3B48F6)),
                            const SizedBox(height: 24),
                            Text(
                              'AI Scanning in progress...',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B48F6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48.0),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.blue.shade100,
                                color: const Color(0xFF3B48F6),
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.check_circle, size: 48, color: Colors.green),
                            const SizedBox(height: 16),
                            Text(
                              'Scan Complete!',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Data extracted successfully',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_scanComplete) ...[
                    Text(
                      'Extracted Data Preview',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDataRow('Document Title', _scannedTitle ?? 'Q1 Maintenance Report'),
                    _buildDataRow('Total Amount', 'P15,450.00'),
                    _buildDataRow('Date', 'March 15, 2026'),
                    _buildDataRow('Category', 'Maintenance'),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B48F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Confirm and Submit',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
