import 'package:flutter/widgets.dart';

class AnalysisResultPage extends StatelessWidget {
  final String extractedText;

  const AnalysisResultPage({super.key, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Analysis Result:\n\n$extractedText'));
  }
}
