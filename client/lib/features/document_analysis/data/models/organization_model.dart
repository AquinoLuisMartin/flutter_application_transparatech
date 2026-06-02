class Organization {
  final int organizationId;
  final String orgName;
  final String orgCode;
  final String? description;
  final String? logoUrl;

  Organization({
    required this.organizationId,
    required this.orgName,
    required this.orgCode,
    this.description,
    this.logoUrl,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      organizationId: json['organizationId'] ?? 0,
      orgName: json['orgName'] ?? '',
      orgCode: json['orgCode'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
    );
  }
}

class OrganizationBudget {
  final Organization organization;
  final BudgetDetails? budget;

  OrganizationBudget({required this.organization, this.budget});

  factory OrganizationBudget.fromJson(Map<String, dynamic> json) {
    return OrganizationBudget(
      organization: Organization.fromJson(json['organization']),
      budget: json['budget'] != null ? BudgetDetails.fromJson(json['budget']) : null,
    );
  }
}

class BudgetDetails {
  final int budgetId;
  final String academicYear;
  final double totalBudget;
  final double spentAmount;
  final double remainingAmount;

  BudgetDetails({
    required this.budgetId,
    required this.academicYear,
    required this.totalBudget,
    required this.spentAmount,
    required this.remainingAmount,
  });

  factory BudgetDetails.fromJson(Map<String, dynamic> json) {
    return BudgetDetails(
      budgetId: json['budgetId'] ?? 0,
      academicYear: json['academicYear'] ?? '',
      totalBudget: (json['totalBudget'] ?? 0).toDouble() / 100,
      spentAmount: (json['spentAmount'] ?? 0).toDouble() / 100,
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble() / 100,
    );
  }
}
