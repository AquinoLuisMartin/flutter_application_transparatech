import '../../domain/entities/extracted_data.dart';

class ExtractedDataModel extends ExtractedData {
  ExtractedDataModel({required super.text, required super.metadata});

  factory ExtractedDataModel.fromJson(Map<String, dynamic> json) => ExtractedDataModel(
        text: json['text'] as String? ?? '',
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'metadata': metadata,
      };
}
