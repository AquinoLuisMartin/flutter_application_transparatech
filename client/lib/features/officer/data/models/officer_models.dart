class OfficerDocument {
  final int id;
  final String title;
  final String? description;
  final String filePath;
  final int? fileSize;
  final String? fileType;
  final String status;
  final String? statusColor;
  final DateTime createdAt;

  OfficerDocument({
    required this.id,
    required this.title,
    this.description,
    required this.filePath,
    this.fileSize,
    this.fileType,
    required this.status,
    this.statusColor,
    required this.createdAt,
  });

  factory OfficerDocument.fromJson(Map<String, dynamic> json) {
    return OfficerDocument(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      status: json['status'],
      statusColor: json['statusColor'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OfficerStats {
  final List<dynamic> byStatus;
  final int totalActive;
  final double complianceScore;
  final double transparencyIndex;

  OfficerStats({
    required this.byStatus,
    required this.totalActive,
    required this.complianceScore,
    required this.transparencyIndex,
  });

  factory OfficerStats.fromJson(Map<String, dynamic> json) {
    return OfficerStats(
      byStatus: json['byStatus'] ?? [],
      totalActive: json['totalActive'] ?? 0,
      complianceScore: (json['complianceScore'] ?? 0).toDouble(),
      transparencyIndex: (json['transparencyIndex'] ?? 0).toDouble(),
    );
  }
}
