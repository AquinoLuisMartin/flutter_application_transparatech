import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_queue_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_notification_provider.dart';

class AdminNotificationBell extends StatelessWidget {
  const AdminNotificationBell({super.key});

  void _showPopOver(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return NotificationPopOver(
          triggerOffset: offset,
          triggerSize: size,
          onDismiss: () {
            overlayEntry.remove();
          },
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<AdminNotificationProvider>(context);
    final int unreadCount = notificationProvider.unreadCount;

    return GestureDetector(
      onTap: () => _showPopOver(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Solid system red numeric badge
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F2547), width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  '$unreadCount',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationPopOver extends StatelessWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final VoidCallback onDismiss;

  const NotificationPopOver({
    super.key,
    required this.triggerOffset,
    required this.triggerSize,
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
                            Provider.of<AdminNotificationProvider>(context, listen: false).markAllAsRead();
                          },
                          child: Text(
                            'Mark all as read',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3B48F6), // system blue
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                  // Unified Chronological Activity Feed Schema
                  Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: Consumer<AdminNotificationProvider>(
                      builder: (context, provider, child) {
                        final list = provider.notifications;
                        return ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: list.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return _buildActivityItem(context, item, provider);
                          },
                        );
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

  Widget _buildActivityItem(
    BuildContext context, 
    NotificationItem item, 
    AdminNotificationProvider provider
  ) {
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
        provider.markAsRead(item.id);
        onDismiss(); // instantly dismisses the active pop-over dropdown panel smoothly

        // Real-time router deep-linking
        final queueProvider = Provider.of<AdminQueueProvider>(context, listen: false);
        if (item.type == 'QUEUE') {
          // Type "QUEUE": Transitions app workspace to Queue tab view (1), updates status filter to PENDING
          queueProvider.setSelectedStatusFilter('PENDING');
          if (item.deepLinkData?['highlightQuery'] != null) {
            queueProvider.setSearchQuery(item.deepLinkData!['highlightQuery']);
          }
          provider.performNavigation(1);
        } else if (item.type == 'ORG') {
          // Type "ORG": Transitions app workspace to Organization tab view (3), filters focus on targeted acronym
          final orgAcronym = item.deepLinkData?['orgFilter'] ?? '';
          provider.performNavigation(3, orgFilter: orgAcronym);
        } else if (item.type == 'USER') {
          // Type "USER": Transitions app workspace to Users tab view (4), auto-applies role filter parameter
          final roleFilter = item.deepLinkData?['roleFilter'] ?? 'Officers';
          provider.performNavigation(4, roleFilter: roleFilter);
        }
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
