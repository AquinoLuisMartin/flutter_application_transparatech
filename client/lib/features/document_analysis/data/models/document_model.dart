class Document {
  final int documentId;
  final String documentTitle;
  final String? documentDescription;
  final String filePath;
  final int? fileSize;
  final String? fileType;
  final int uploadedBy;
  final int statusId;
  final DateTime submissionDate;
  final DateTime lastModified;
  final bool isDeleted;

  Document({
    required this.documentId,
    required this.documentTitle,
    this.documentDescription,
    required this.filePath,
    this.fileSize,
    this.fileType,
    required this.uploadedBy,
    required this.statusId,
    required this.submissionDate,
    required this.lastModified,
    required this.isDeleted,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentId: json['documentId'] ?? 0,
      documentTitle: json['documentTitle'] ?? '',
      documentDescription: json['documentDescription'],
      filePath: json['filePath'] ?? '',
      fileSize: json['fileSize'],
      fileType: json['fileType'],
      uploadedBy: json['uploadedBy'] ?? 0,
      statusId: json['statusId'] ?? 0,
      submissionDate: DateTime.parse(json['submissionDate'] ?? DateTime.now().toIso8601String()),
      lastModified: DateTime.parse(json['lastModified'] ?? DateTime.now().toIso8601String()),
      isDeleted: json['isDeleted'] == 1 || json['isDeleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'documentTitle': documentTitle,
      'documentDescription': documentDescription,
      'filePath': filePath,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadedBy': uploadedBy,
      'statusId': statusId,
      'submissionDate': submissionDate.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }
}
