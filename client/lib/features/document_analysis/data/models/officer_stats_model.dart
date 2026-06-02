class OfficerStats {
  final int totalActive;
  final int complianceScore;
  final int transparencyIndex;
  final List<StatusCount> byStatus;
  final BudgetSummary? budget;

  OfficerStats({
    required this.totalActive,
    required this.complianceScore,
    required this.transparencyIndex,
    required this.byStatus,
    this.budget,
  });

  factory OfficerStats.fromJson(Map<String, dynamic> json) {
    return OfficerStats(
      totalActive: json['totalActive'] ?? 0,
      complianceScore: json['complianceScore'] ?? 0,
      transparencyIndex: json['transparencyIndex'] ?? 0,
      byStatus: (json['byStatus'] as List? ?? [])
          .map((e) => StatusCount.fromJson(e))
          .toList(),
      budget: json['budget'] != null ? BudgetSummary.fromJson(json['budget']) : null,
    );
  }
}

class StatusCount {
  final String status;
  final int count;

  StatusCount({required this.status, required this.count});

  factory StatusCount.fromJson(Map<String, dynamic> json) {
    return StatusCount(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class BudgetSummary {
  final double total;
  final double spent;
  final double remaining;

  BudgetSummary({
    required this.total,
    required this.spent,
    required this.remaining,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      total: (json['total'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
    );
  }
}
