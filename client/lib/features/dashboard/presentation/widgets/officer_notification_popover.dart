import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfficerNotificationItem {
  final String id;
  final String message;
  final String time;
  bool isRead;

  OfficerNotificationItem({
    required this.id,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class OfficerNotificationPopOver extends StatelessWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final List<OfficerNotificationItem> notifications;
  final void Function(String id) onMarkAsRead;
  final VoidCallback onMarkAllAsRead;
  final VoidCallback onDismiss;

  const OfficerNotificationPopOver({
    super.key,
    required this.triggerOffset,
    required this.triggerSize,
    required this.notifications,
    required this.onMarkAsRead,
    required this.onMarkAllAsRead,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = 320;

    // Position card directly below trigger element aligned to its right boundary edge
    final double topPosition = triggerOffset.dy + triggerSize.height + 8;
    final double rightPosition = size.width - (triggerOffset.dx + triggerSize.width);

    return Stack(
      children: [
        // 1. Transparent Backdrop Barrier (Locks parent interaction, does not dim background)
        GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),

        // 2. Pop-over dropdown container card
        Positioned(
          top: topPosition,
          right: rightPosition,
          width: cardWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Solid white container
                borderRadius: BorderRadius.circular(12), // smoothly rounded (12px)
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08), // thin light gray outer border track
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8), // deep ambient drop shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pop-over Internal Header Layout (No Filter Tabs)
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onMarkAllAsRead();
                          },
                          child: Text(
                            'Mark all as read',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.normal, // regular-weight
                              color: const Color(0xFF3B48F6), // system blue
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                  // Unified Chronological Activity Feed Schema (Sorted newest to oldest)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: notifications.length,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF3F4F6),
                      ),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _buildActivityItem(context, item);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, OfficerNotificationItem item) {
    const Color activeBlue = Color(0xFF3B48F6);

    // Cell Interaction States & Styling:
    final Color cellBackground = item.isRead
        ? Colors.transparent
        : activeBlue.withValues(alpha: 0.05); // soft 5% blue tint

    final Color messageTextColor = item.isRead
        ? const Color(0xFF9CA3AF) // neutral muted gray text
        : const Color(0xFF374151); // standard dark text

    final Color timeTextColor = item.isRead
        ? const Color(0xFFD1D5DB)
        : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: () {
        onMarkAsRead(item.id);
        onDismiss(); // instantly dismisses the active pop-over dropdown panel smoothly
      },
      child: Container(
        color: cellBackground,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left margin status indicator (blue dot for unread, spacer for read)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: BoxDecoration(
                color: item.isRead ? Colors.transparent : activeBlue, // small solid blue status dot
                shape: BoxShape.circle,
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.w500,
                      color: messageTextColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.time,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: timeTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
