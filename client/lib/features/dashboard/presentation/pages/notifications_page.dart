import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0F2547),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications Yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Notifications will appear here when there are updates.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
