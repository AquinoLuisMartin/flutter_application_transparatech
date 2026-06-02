import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/main.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/document_analysis/presentation/providers/document_provider.dart';

void main() {
  testWidgets('App loads and shows LandingPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that our app shows "Verifi".
    expect(find.text('Verifi'), findsWidgets);
  });
}
