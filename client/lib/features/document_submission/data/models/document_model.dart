class DocumentModel {
  final String id;
  final String name;
  final String path;

  DocumentModel({required this.id, required this.name, required this.path});

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
      };
}
