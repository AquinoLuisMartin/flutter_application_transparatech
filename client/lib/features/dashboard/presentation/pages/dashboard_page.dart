import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/document_analysis/presentation/providers/document_provider.dart';
import 'package:flutter_application_transparatech/features/document_analysis/data/models/document_model.dart';
import 'package:flutter_application_transparatech/features/document_analysis/data/models/officer_stats_model.dart';
import 'package:flutter_application_transparatech/features/document_analysis/data/models/organization_model.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'activity_history_page.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_application_transparatech/features/document_submission/presentation/pages/upload_page.dart';
import 'package:flutter_application_transparatech/features/dashboard/presentation/widgets/officer_notification_popover.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int? _overrideRoleId; // Developer role override for dashboard UI testing

  Map<String, double> _calculateMonthlyExpenses(List<Document> documents) {
    final Map<String, double> monthlyMap = {
      'Oct': 0.0,
      'Nov': 0.0,
      'Dec': 0.0,
      'Jan': 0.0,
      'Feb': 0.0,
      'Mar': 0.0,
    };
    
    final RegExp amountRegExp = RegExp(r'(?:Total Amount Spent|Proposed|Ending Balance):\s*([0-9.,]+)');
    
    for (var doc in documents) {
      if (doc.documentDescription != null) {
        final match = amountRegExp.firstMatch(doc.documentDescription!);
        if (match != null) {
          final cleanStr = match.group(1)!.replaceAll(',', '');
          final amount = double.tryParse(cleanStr) ?? 0.0;
          
          final date = doc.submissionDate;
          String? monthLabel;
          switch (date.month) {
            case 10: monthLabel = 'Oct'; break;
            case 11: monthLabel = 'Nov'; break;
            case 12: monthLabel = 'Dec'; break;
            case 1: monthLabel = 'Jan'; break;
            case 2: monthLabel = 'Feb'; break;
            case 3: monthLabel = 'Mar'; break;
          }
          if (monthLabel != null) {
            monthlyMap[monthLabel] = (monthlyMap[monthLabel] ?? 0.0) + amount;
          }
        }
      }
    }
    return monthlyMap;
  }

  List<Widget> _buildDynamicBars(BuildContext context, List<Document> documents, double totalBudget) {
    final monthlyExpenses = _calculateMonthlyExpenses(documents);
    final double monthlyBudget = totalBudget / 6.0;
    
    double maxVal = monthlyBudget;
    for (var val in monthlyExpenses.values) {
      if (val > maxVal) {
        maxVal = val;
      }
    }
    maxVal = maxVal > 0 ? maxVal * 1.2 : 10000.0;
    
    final months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
    return months.map((month) {
      final expVal = monthlyExpenses[month] ?? 0.0;
      final expRatio = expVal / maxVal;
      final budgetRatio = monthlyBudget / maxVal;
      return _buildBar(context, expRatio.clamp(0.01, 1.0), budgetRatio.clamp(0.01, 1.0), month);
    }).toList();
  }

  bool _isNotificationPopOverOpen = false;
  OverlayEntry? _officerNotificationOverlayEntry;

  final List<OfficerNotificationItem> _officerNotifications = [
    OfficerNotificationItem(
      id: '1',
      message: 'ACES submitted Q1 2026 Audit Report.',
      time: '2 mins ago',
      isRead: false,
    ),
    OfficerNotificationItem(
      id: '2',
      message: 'iSITE roster updated: Total registered members have grown to 409 users.',
      time: '2 hours ago',
      isRead: false,
    ),
    OfficerNotificationItem(
      id: '3',
      message: "New Organization Request: 'CS Cup Sports Committee' has submitted an application dossier.",
      time: '5 hours ago',
      isRead: false,
    ),
    OfficerNotificationItem(
      id: '4',
      message: 'Access Request: Ellayssa Aguilar requested promotion to Officer for iSITE.',
      time: '1 day ago',
      isRead: true,
    ),
    OfficerNotificationItem(
      id: '5',
      message: 'System Action: Profile record for Princess Dianne Pastrana successfully moved to Activity Logs Archive.',
      time: '2 days ago',
      isRead: true,
    ),
  ];

  void _showOfficerNotificationPopOver(BuildContext bellContext) {
    if (_officerNotificationOverlayEntry != null) {
      _officerNotificationOverlayEntry!.remove();
      _officerNotificationOverlayEntry = null;
      setState(() {
        _isNotificationPopOverOpen = false;
      });
      return;
    }

    final RenderBox renderBox = bellContext.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    setState(() {
      _isNotificationPopOverOpen = true;
    });

    _officerNotificationOverlayEntry = OverlayEntry(
      builder: (context) {
        return OfficerNotificationPopOver(
          triggerOffset: offset,
          triggerSize: size,
          notifications: _officerNotifications,
          onMarkAsRead: (id) {
            setState(() {
              final idx = _officerNotifications.indexWhere((n) => n.id == id);
              if (idx != -1) {
                _officerNotifications[idx].isRead = true;
              }
            });
          },
          onMarkAllAsRead: () {
            setState(() {
              for (var n in _officerNotifications) {
                n.isRead = true;
              }
            });
          },
          onDismiss: () {
            if (_officerNotificationOverlayEntry != null) {
              _officerNotificationOverlayEntry!.remove();
              _officerNotificationOverlayEntry = null;
              setState(() {
                _isNotificationPopOverOpen = false;
              });
            }
          },
        );
      },
    );

    Overlay.of(context).insert(_officerNotificationOverlayEntry!);
  }

  @override
  void dispose() {
    if (_officerNotificationOverlayEntry != null) {
      _officerNotificationOverlayEntry!.remove();
      _officerNotificationOverlayEntry = null;
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<DocumentProvider>(context, listen: false)
            .fetchDocuments(authProvider.token!);
      }
    });
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required String title,
    required String date,
    required String hash,
    bool isNew = false,
    bool showChevron = false,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return VeriFiCard(
      icon: const Icon(Icons.description_outlined),
      title: title,
      description: 'Hash: ${hash.length > 15 ? "${hash.substring(0, 15)}..." : hash}',
      status: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : VeriFiColors.textLight,
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF152238) : VeriFiColors.secondaryEE,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'New',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: VeriFiColors.success,
                ),
              ),
            ),
          ],
        ],
      ),
      action: showChevron ? Icon(Icons.chevron_right, color: isDark ? const Color(0xFF94A3B8) : VeriFiColors.textLight) : null,
    );
  }

  Widget _buildBar(BuildContext context, double expensesHeight, double budgetHeight, String label) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 120, // Max height of the bar area
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expenses Bar (Green)
              Container(
                width: 12,
                height: 120 * expensesHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399), // Emerald
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 4),
              // Budget Bar (Blue)
              Container(
                width: 12,
                height: 120 * budgetHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFF60A5FA), // Blue
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {bool roundedBottom = true, Widget? bottomContent}) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'Juan Santos';
    final int activeRoleId = _overrideRoleId ?? user?.roleId ?? 2;
    final String roleName = _getRoleName(activeRoleId);
    final bool isOfficer = activeRoleId == 3;

    return VeriFiProfileHeader(
      name: fullName,
      role: roleName,
      isDashboardStyle: true,
      onNotificationTap: isOfficer
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
      onNotificationTapWithContext: isOfficer
          ? (bellContext) {
              _showOfficerNotificationPopOver(bellContext);
            }
          : null,
      onHistoryTap: isOfficer
          ? () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (innerContext) => ChangeNotifierProvider<ThemeProvider>.value(
                    value: themeProvider,
                    child: const ActivityHistoryPage(),
                  ),
                ),
              );
            }
          : null,
      notificationCount: isOfficer
          ? _officerNotifications.where((n) => !n.isRead).length
          : 3,
      avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=0D8ABC&color=fff',
      roundedBottom: roundedBottom,
      bottomContent: bottomContent,
    );
  }

  Widget _buildHomeTab() {
    final docProvider = Provider.of<DocumentProvider>(context);
    final docsList = docProvider.documents;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(context, roundedBottom: true),

          // Main Content Area
          Transform.translate(
              offset: const Offset(0, -20), // Pull banner up slightly over header
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transparency Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.blue.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Transparency Dashboard',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Access verified financial documents, audit reports, and organizational transparency metrics',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Documents Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Recent Documents',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          child: Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B48F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Documents List
                    if (docsList.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No recent documents available',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ...docsList.take(3).map((doc) => _buildDocumentCard(
                        context,
                        title: doc.documentTitle,
                        date: _formatDate(doc.submissionDate),
                        hash: _getHash(doc),
                      )),
                    ],
                    const SizedBox(height: 32),

                    // Financial Overview Header
                    Text(
                      'Financial Overview',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest 6 months',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Financial Chart Setup (Custom Built to avoid dependencies)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Custom Bar Chart Area
                          SizedBox(
                            height: 160, // Chart overall height
                            child: Stack(
                              children: [
                                // Grid Lines
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (index) {
                                    final labels = ['100k', '80k', '60k', '40k', '20k', '0'];
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            labels[index],
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey.shade100,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                                // Bars
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0), // offset for Y-axis labels
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: _buildDynamicBars(
                                      context,
                                      docsList,
                                      docProvider.stats?.budget?.total ?? 150000.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 8, height: 8, color: const Color(0xFF34D399)),
                              const SizedBox(width: 6),
                              Text('Expenses', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(width: 24),
                              Container(width: 8, height: 8, color: const Color(0xFF60A5FA)),
                              const SizedBox(width: 6),
                              Text('Budget', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  String _getRoleName(int roleId) {
    switch (roleId) {
      case 1:
        return 'Admin';
      case 2:
        return 'Student';
      case 3:
        return 'Officer';
      default:
        return 'Student';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Widget _buildCardAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upload Financial Document',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit a new document for COSC Society audit trail',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _buildBottomSheetItem(
                icon: Icons.description_outlined,
                title: 'Expense Report',
                subtitle: 'Quarterly or monthly expense summary',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadPage(category: 'Expense Report'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildBottomSheetItem(
                icon: Icons.attach_money_outlined,
                title: 'Budget Proposal',
                subtitle: 'Event or project budget for approval',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadPage(category: 'Budget Proposal'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildBottomSheetItem(
                icon: Icons.receipt_long_outlined,
                title: 'Receipt / Invoice',
                subtitle: 'Individual transaction proof',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadPage(category: 'Receipt / Invoice'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildBottomSheetItem(
                icon: Icons.security_outlined,
                title: 'Audit Certificate',
                subtitle: 'External or internal audit document',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadPage(category: 'Audit Certificate'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: VeriFiColors.secondaryEE,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: VeriFiColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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

  Widget _buildOfficerDocumentCard(
    BuildContext context, {
    required String title,
    required String date,
    required String hash,
    required String status,
    VoidCallback? onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    IconData iconData = Icons.receipt_long_outlined;
    Color iconColor;
    Color iconBg;

    if (status.toUpperCase() == 'APPROVED') {
      iconColor = const Color(0xFF10B981);
      iconBg = const Color(0xFFE6F4EA);
    } else if (status.toUpperCase() == 'PENDING') {
      iconColor = const Color(0xFFF59E0B);
      iconBg = const Color(0xFFFEF7E0);
    } else {
      iconColor = const Color(0xFFEF4444);
      iconBg = const Color(0xFFFCE8E6);
    }

    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Details for: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF152238) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B192C) : iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.tag,
                        size: 10,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hash,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            VeriFiStatusBadge(status: status),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }



  String _formatCurrency(double amount) {
    final String raw = amount.toStringAsFixed(2);
    final parts = raw.split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedInt = parts[0].replaceAllMapped(reg, (Match match) => '${match[1]},');
    return '₱$formattedInt.${parts[1]}';
  }

  String _getHash(Document doc) {
    final rawHash = doc.filePath.isNotEmpty && doc.filePath.length >= 8 
        ? doc.filePath 
        : 'hash_${doc.documentId}_${doc.documentTitle.hashCode.toRadixString(16)}';
    if (rawHash.length > 8) {
      return '${rawHash.substring(0, 4)}...${rawHash.substring(rawHash.length - 4)}';
    }
    return rawHash;
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  Widget _buildOfficerHomeTab(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'Juan Santos';
    final String initial = user != null && user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'J';
    final String initial2 = user != null && user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : 'S';
    final String initials = '$initial$initial2';

    final docProvider = Provider.of<DocumentProvider>(context);
    final docsList = docProvider.documents;
    final OfficerStats? stats = docProvider.stats;
    final OrganizationBudget? orgBudget = docProvider.organizationBudget;

    // E-Wallet Dynamic Calculations from DB
    final double spent = stats?.budget?.spent ?? 0.0;
    final double remaining = stats?.budget?.remaining ?? 0.0;
    final double totalBudget = stats?.budget?.total ?? 1.0; // avoid div by zero
    final double spentPercent = totalBudget > 0 ? (spent / totalBudget) : 0.0;

    // Security Metrics from DB
    final double verifiedRatio = (stats?.complianceScore ?? 0) / 100.0;
    final double indexedRatio = (stats?.transparencyIndex ?? 0) / 100.0;

    final String orgName = orgBudget?.organization.orgName ?? 'Organization';

    return Container(
      color: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
      child: SingleChildScrollView(
        physics: _isNotificationPopOverOpen
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VeriFiProfileHeader(
              name: fullName,
              role: 'Officer',
              isDashboardStyle: true,
              backgroundColor: const Color(0xFF0F172A),
              initials: initials,
              onNotificationTap: null,
              onNotificationTapWithContext: (bellContext) {
                _showOfficerNotificationPopOver(bellContext);
              },
              onHistoryTap: null,
              notificationCount: _officerNotifications.where((n) => !n.isRead).length,
              bottomContent: Container(
                margin: const EdgeInsets.only(top: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B48F6), Color(0xFF6366F1), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B48F6).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$orgName Wallet',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Premium Gold Chip
                        Container(
                          width: 36,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  width: 24,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange.shade700.withValues(alpha: 0.4), width: 0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Available Allocation',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(remaining),
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Spent details and progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Spent: ${_formatCurrency(spent)}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(spentPercent * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: spentPercent.clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Card quick actions row (glassmorphic style)
                    Row(
                      children: [
                        _buildCardAction(Icons.arrow_upward, 'Disburse', () {
                          _showUploadBottomSheet(context);
                        }),
                        const SizedBox(width: 10),
                        _buildCardAction(Icons.arrow_downward, 'Request', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Budget request form is being prepared.')),
                          );
                        }),
                        const SizedBox(width: 10),
                        _buildCardAction(Icons.history, 'History', () {
                          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (innerContext) => ChangeNotifierProvider<ThemeProvider>.value(
                                value: themeProvider,
                                child: const ActivityHistoryPage(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Home Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization AI Analysis Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.blue.shade50.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blue.shade100, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.blue.shade600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$orgName AI Analysis',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.blue.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          docsList.isEmpty
                              ? 'No financial records in DB. Please upload a report to initialize AI transparency score.'
                              : 'All $orgName database documents analyzed. Verified ${docsList.where((d) => d.statusName?.toUpperCase() == "APPROVED").length} approved files. Mismatches details shown in Reports.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.blue.shade900.withValues(alpha: 0.8),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3; // Open reports/analysis
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Full Report',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF60A5FA) : Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward, color: isDark ? const Color(0xFF60A5FA) : Colors.blue.shade700, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Recent Documents Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Recent Documents',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1; // Switch to Documents Tab
                          });
                        },
                        child: Text(
                          'View All',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B48F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Documents List with Statuses (From DB)
                  if (docsList.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.folder_open_outlined, size: 48, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No documents in database yet',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...docsList.take(4).map((doc) => _buildOfficerDocumentCard(
                      context,
                      title: doc.documentTitle,
                      date: _formatDate(doc.submissionDate),
                      hash: _getHash(doc),
                      status: doc.statusName ?? 'PENDING',
                    )),
                  ],
                  const SizedBox(height: 32),

                  // Data Integrity Status (Redesigned with card border and progress indicators)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Data Integrity Status',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'SHA-256 Verified',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(verifiedRatio * 100).toInt()}%',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF60A5FA) : Colors.blue.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: verifiedRatio.clamp(0.0, 1.0),
                                      minHeight: 4,
                                      backgroundColor: isDark ? const Color(0xFF0B192C) : Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF60A5FA) : Colors.blue.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Audit Indexed',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(indexedRatio * 100).toInt()}%',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF60A5FA) : Colors.blue.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: indexedRatio.clamp(0.0, 1.0),
                                      minHeight: 4,
                                      backgroundColor: isDark ? const Color(0xFF0B192C) : Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF60A5FA) : Colors.blue.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildSummaryHeaderCard(IconData icon, String amount, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
            const SizedBox(height: 12),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final docProvider = Provider.of<DocumentProvider>(context);
    final stats = docProvider.stats;

    final double total = stats?.budget?.total ?? 150000.0;
    final double spent = stats?.budget?.spent ?? 87500.0;
    final double remaining = stats?.budget?.remaining ?? 62500.0;

    return Container(
      color: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              roundedBottom: false,
              bottomContent: Row(
                children: [
                  _buildSummaryHeaderCard(Icons.account_balance_wallet_outlined, _formatCurrency(total), 'Total Budget'),
                  const SizedBox(width: 8),
                  _buildSummaryHeaderCard(Icons.receipt_long_outlined, _formatCurrency(spent), 'Total Expenses'),
                  const SizedBox(width: 8),
                  _buildSummaryHeaderCard(Icons.savings_outlined, _formatCurrency(remaining), 'Remaining Funds'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transparency Report Button Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0B192C) : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.description_outlined, color: Colors.blue.shade600, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transparency Report',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Latest 6 months',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0B192C) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.file_download_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Chart Header
                  Text(
                    'Budget vs Expenses',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Financial flow overtime (Latest 6 months)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expanded Detailed Chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(8, (index) {
                                  final labels = ['300k', '200k', '100k', '80k', '60k', '40k', '20k', '0'];
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          labels[index],
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: _buildDynamicBars(
                                    context,
                                    docProvider.documents,
                                    total,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, color: const Color(0xFF34D399)),
                            const SizedBox(width: 6),
                            Text('Expenses', style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700)),
                            const SizedBox(width: 24),
                            Container(width: 8, height: 8, color: const Color(0xFF60A5FA)),
                            const SizedBox(width: 6),
                            Text('Budget', style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Expense Breakdown
                  Text(
                    'Expense Breakdown',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Where the money goes',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: () {
                        final List<Map<String, dynamic>> expenses = [];
                        double totalSpentCalculated = 0.0;
                        
                        final RegExp amountRegExp = RegExp(r'(?:Total Amount Spent|Proposed|Ending Balance):\s*([0-9.,]+)');
                        
                        for (var doc in docProvider.documents) {
                          if (doc.documentDescription != null) {
                            final match = amountRegExp.firstMatch(doc.documentDescription!);
                            if (match != null) {
                              final cleanStr = match.group(1)!.replaceAll(',', '');
                              final amount = double.tryParse(cleanStr) ?? 0.0;
                              totalSpentCalculated += amount;
                              expenses.add({
                                'title': doc.documentTitle,
                                'amount': amount,
                              });
                            }
                          }
                        }
                        
                        final List<Widget> children = [];
                        
                        if (expenses.isEmpty) {
                          children.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No logged expenses in database.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        } else {
                          expenses.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
                          
                          final colors = [
                            const Color(0xFF3B82F6),
                            const Color(0xFF8B5CF6),
                            const Color(0xFF06B6D4),
                            const Color(0xFF10B981),
                            const Color(0xFFF59E0B),
                            const Color(0xFFEF4444),
                          ];
                          
                          for (int i = 0; i < expenses.length; i++) {
                            final exp = expenses[i];
                            final double amount = exp['amount'];
                            final double percent = totalSpentCalculated > 0 ? (amount / totalSpentCalculated) : 0.0;
                            final color = colors[i % colors.length];
                            
                            children.add(
                              _buildExpenseRow(
                                context, 
                                exp['title'], 
                                '${(percent * 100).toStringAsFixed(1)}% of total', 
                                _formatCurrency(amount), 
                                color, 
                                percent
                              ),
                            );
                            
                            if (i < expenses.length - 1) {
                              children.add(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                                ),
                              );
                            }
                          }
                        }
                        
                        children.add(const SizedBox(height: 24));
                        children.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Expenses',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                _formatCurrency(spent),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        );
                        
                        return children;
                      }(),
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

  Widget _buildExpenseRow(BuildContext context, String title, String subtitle, String amount, Color color, double progress) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B192C) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final docProvider = Provider.of<DocumentProvider>(context);
    final docsList = docProvider.documents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section without rounded border
        _buildHeader(context, roundedBottom: false),

        // Rest of body
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VeriFiSearchComponent(
                    hintText: 'Search',
                    onFilterPressed: () {},
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'All Documents',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Documents List
                  if (docsList.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.folder_open_outlined, size: 48, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No documents in database yet',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...docsList.map((doc) => _buildDocumentCard(
                      context,
                      title: doc.documentTitle,
                      date: _formatDate(doc.submissionDate),
                      hash: _getHash(doc),
                      showChevron: true,
                    )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context, {
    required String title,
    required String body,
    required String date,
    required String time,
    bool isPinned = false,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152238) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B192C) : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (isPinned) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.push_pin, color: const Color(0xFF3B48F6), size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$date • $time',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final docProvider = Provider.of<DocumentProvider>(context);
    final docsList = docProvider.documents;

    return Container(
      color: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, roundedBottom: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VeriFiSearchComponent(
                    hintText: 'Search',
                    onFilterPressed: () {},
                  ),
                  const SizedBox(height: 32),

                  if (docsList.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No announcements at this time.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Pinned Section (Approved documents)
                    () {
                      final approvedDocs = docsList.where((d) => d.statusName?.toUpperCase() == 'APPROVED').toList();
                      if (approvedDocs.isEmpty) return const SizedBox.shrink();
                      
                      final List<Widget> list = [];
                      list.add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.push_pin_outlined, size: 18, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                            const SizedBox(width: 8),
                            Text(
                              'Pinned',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      );
                      list.add(const SizedBox(height: 16));
                      
                      for (var doc in approvedDocs.take(3)) {
                        list.add(
                          _buildAnnouncementCard(
                            context,
                            title: 'OFFICIAL: ${doc.documentTitle}',
                            body: '${doc.documentDescription ?? 'Financial record audit verified.'}\n\nIntegrity Hash: ${_getHash(doc)}',
                            date: _formatDate(doc.submissionDate),
                            time: '${doc.submissionDate.hour.toString().padLeft(2, '0')}:${doc.submissionDate.minute.toString().padLeft(2, '0')}',
                            isPinned: true,
                          ),
                        );
                      }
                      list.add(const SizedBox(height: 24));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: list,
                      );
                    }(),

                    // All Announcements Section (All documents)
                    Text(
                      'All Announcements',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...docsList.map((doc) => _buildAnnouncementCard(
                      context,
                      title: doc.documentTitle,
                      body: doc.documentDescription ?? 'New document submission registered in public ledger.',
                      date: _formatDate(doc.submissionDate),
                      time: '${doc.submissionDate.hour.toString().padLeft(2, '0')}:${doc.submissionDate.minute.toString().padLeft(2, '0')}',
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, IconData icon, String title, Color color, {bool isDestructive = false}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color itemColor = isDestructive ? color : (isDark ? Colors.white : color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152238) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : isDestructive ? Colors.red.shade100 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: itemColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isDestructive ? FontWeight.bold : FontWeight.w600,
                color: itemColor,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: isDestructive ? Colors.red.shade300 : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400), size: 20),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'Juan Dela Cruz Santos';
    final String email = user?.email ?? 'juan.santos@pup.edu.ph';
    
    final String initial = user != null && user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'J';
    final String initial2 = user != null && user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : 'S';
    final String initials = '$initial$initial2';

    final int activeRoleId = _overrideRoleId ?? user?.roleId ?? 2;
    final String roleName = _getRoleName(activeRoleId);
    final bool isOfficer = activeRoleId == 3 || activeRoleId == 1;

    final docProvider = Provider.of<DocumentProvider>(context);
    final orgBudget = docProvider.organizationBudget;
    final String orgName = orgBudget?.organization.orgName ?? (isOfficer ? 'COSC Society' : 'ISITE');

    return Container(
      color: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
      child: Column(
        children: [
          _buildHeader(context, roundedBottom: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  VeriFiProfileHeader(
                    name: fullName,
                    role: roleName,
                    subtitle: email,
                    initials: initials,
                    isDashboardStyle: false,
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(context, roleName == 'Admin' ? 'Faculty ID' : 'Student ID', user?.studentId ?? '2023-00001-SM-0'),
                        Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                        _buildInfoRow(context, 'Organization', orgName),
                        Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                        _buildInfoRow(context, 'Campus', 'PUP Sta. Maria, Bulacan'),
                        Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                        _buildInfoRow(context, 'Role', roleName),
                        Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
                        _buildInfoRow(context, 'Member Since', user != null ? '${_getMonthName(user.createdAt.month)} ${user.createdAt.year}' : 'September 2023'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Developer Switcher
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF152238) : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bug_report_outlined, color: isDark ? Colors.amber : Colors.amber.shade800),
                            const SizedBox(width: 8),
                            Text(
                              'Developer Tools',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.amber : Colors.amber.shade900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Override dashboard role layout for presentation and verification purposes:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Active UI: ${activeRoleId == 1 ? "Admin (System)" : isOfficer ? "Officer (E-Wallet)" : "Student (Standard)"}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.amber.shade900,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (activeRoleId == 2) {
                                    _overrideRoleId = 3; // Switch to Officer
                                  } else if (activeRoleId == 3) {
                                    _overrideRoleId = 1; // Switch to Admin
                                  } else {
                                    _overrideRoleId = 2; // Switch to Student
                                  }
                                  _selectedIndex = 0; // Reset index to Home
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF0B192C) : Colors.amber.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                                elevation: 0,
                              ),
                              child: const Text('Toggle Role UI'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  GestureDetector(
                    onTap: () {
                      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (innerContext) => ChangeNotifierProvider<ThemeProvider>.value(
                            value: themeProvider,
                            child: const SettingsPage(),
                          ),
                        ),
                      );
                    },
                    child: _buildActionRow(context, Icons.settings_outlined, 'Account Settings', const Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false).signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthPage()),
                        (route) => false,
                      );
                    },
                    child: _buildActionRow(context, Icons.logout, 'Log Out', Colors.redAccent, isDestructive: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final int activeRoleId = _overrideRoleId ?? user?.roleId ?? 2;

    if (activeRoleId == 1) {
      return const AdminDashboardPage();
    }

    final bool isOfficer = activeRoleId == 3;

    if (isOfficer) {
      return ChangeNotifierProvider<ThemeProvider>(
        create: (_) => OfficerThemeProvider(),
        child: Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            final bool isDark = themeProvider.isDarkMode;

            Widget activeBody;
            switch (_selectedIndex) {
              case 0:
                activeBody = _buildOfficerHomeTab(context);
                break;
              case 1:
                activeBody = _buildDocumentsTab(context);
                break;
              case 3:
                activeBody = _buildReportsTab(context);
                break;
              case 4:
                activeBody = _buildProfileTab(context);
                break;
              default:
                activeBody = _buildOfficerHomeTab(context);
            }

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showUploadBottomSheet(context),
                backgroundColor: const Color(0xFF3B48F6),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    if (index == 2) {
                      _showUploadBottomSheet(context);
                      return;
                    }
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: isDark ? const Color(0xFF152238) : Colors.white,
                  selectedItemColor: const Color(0xFF3B48F6),
                  unselectedItemColor: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                  selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Documents'),
                    BottomNavigationBarItem(
                      icon: SizedBox(height: 20, child: Icon(Icons.add, color: Colors.transparent)), 
                      label: '',
                    ), // FAB space
                    BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
                    BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
                  ],
                ),
              ),
              body: activeBody,
            );
          },
        ),
      );
    }

    // Student Dashboard Flow (Global ThemeProvider)
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    Widget activeBody;
    switch (_selectedIndex) {
      case 0:
        activeBody = _buildHomeTab();
        break;
      case 1:
        activeBody = _buildDocumentsTab(context);
        break;
      case 2:
        activeBody = _buildReportsTab(context);
        break;
      case 3:
        activeBody = _buildAnnouncementsTab(context);
        break;
      case 4:
        activeBody = _buildProfileTab(context);
        break;
      default:
        activeBody = _buildHomeTab();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B192C) : const Color(0xFFFAFAFA),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF152238) : Colors.white,
          selectedItemColor: const Color(0xFF3B48F6),
          unselectedItemColor: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Documents'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Announcements'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      body: activeBody,
    );
  }
}
