import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';

/// A premium, reusable profile header widget for the VeriFi Design System.
/// Supports two modes:
/// 1. Dashboard Style: Horizontal layout, dark blue background, title/greeting, notifications, avatar, and optional bottom content.
/// 2. Profile Style: Centered layout, large avatar with status ring, name, email, and role badge.
class VeriFiProfileHeader extends StatelessWidget {
  /// The user's full name to display
  final String name;
  
  /// The user's role: 'Student', 'Officer', or 'Admin'
  final String role;
  
  /// Subtitle details like email, organizations, etc.
  final String? subtitle;
  
  /// Image URL for the profile picture
  final String? avatarUrl;
  
  /// Optional initials to display instead of name-extracted initials if avatar is not loaded
  final String? initials;
  
  /// Determines whether to render in dashboard-appbar style or profile details style
  final bool isDashboardStyle;
  
  /// Greeting text (e.g. "Good morning"). Auto-generated if null in dashboard style.
  final String? greeting;
  
  /// Callback when notification bell is tapped. If null, notification bell is hidden.
  final VoidCallback? onNotificationTap;
  
  /// Unread notification count for badge overlay
  final int notificationCount;
  
  /// Optional additional widget placed at the bottom of the dashboard header
  final Widget? bottomContent;
  
  /// Whether the dashboard header container should have rounded bottom corners
  final bool roundedBottom;
  
  /// Background color override for dashboard style
  final Color? backgroundColor;

  /// Constructor for VeriFiProfileHeader
  const VeriFiProfileHeader({
    super.key,
    required this.name,
    required this.role,
    this.subtitle,
    this.avatarUrl,
    this.initials,
    this.isDashboardStyle = true,
    this.greeting,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.bottomContent,
    this.roundedBottom = true,
    this.backgroundColor,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return 'VF';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final last = parts[parts.length - 1].isNotEmpty ? parts[parts.length - 1][0] : '';
      return '$first$last'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'VF';
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    final String greetingLabel = role == 'Student' ? 'Iskolar' : role;
    return '$timeGreeting, $greetingLabel';
  }

  @override
  Widget build(BuildContext context) {
    final displayInitials = initials ?? _getInitials(name);

    if (isDashboardStyle) {
      return _buildDashboardHeader(context, displayInitials);
    } else {
      return _buildProfileHeader(context, displayInitials);
    }
  }

  Widget _buildDashboardHeader(BuildContext context, String initialsText) {
    final Color bg = backgroundColor ?? const Color(0xFF132A42);
    final String finalGreeting = greeting ?? _getGreetingText();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: roundedBottom
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
            : null,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20, 
        left: 24, 
        right: 24, 
        bottom: roundedBottom ? 32 : 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finalGreeting,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  // Notification bell
                  if (onNotificationTap != null) ...[
                    GestureDetector(
                      onTap: onNotificationTap,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$notificationCount',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // User Avatar
                  _buildAvatarWidget(44, initialsText),
                ],
              ),
            ],
          ),
          if (bottomContent != null) ...[
            const SizedBox(height: 20),
            bottomContent!,
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String initialsText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatarWidget(80, initialsText, hasGradientBorder: true),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: VeriFiColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: VeriFiColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        // Role Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == 'Student' ? Icons.shield_outlined : Icons.verified_user, 
              color: role == 'Student' ? VeriFiColors.primary : VeriFiColors.success, 
              size: 16
            ),
            const SizedBox(width: 4),
            Text(
              role == 'Student' ? 'Authorized Member' : 'Authorized Officer',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: role == 'Student' ? VeriFiColors.primary : VeriFiColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarWidget(double size, String initialsText, {bool hasGradientBorder = false}) {
    final double radius = size / 2;
    
    Widget avatarChild;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarChild = CircleAvatar(
        radius: hasGradientBorder ? radius - 3 : radius,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: Colors.transparent,
      );
    } else {
      avatarChild = CircleAvatar(
        radius: hasGradientBorder ? radius - 3 : radius,
        backgroundColor: const Color(0xFF1E293B),
        child: Text(
          initialsText,
          style: GoogleFonts.inter(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (hasGradientBorder) {
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [VeriFiColors.primary, Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: avatarChild,
      );
    } else {
      return avatarChild;
    }
  }
}
