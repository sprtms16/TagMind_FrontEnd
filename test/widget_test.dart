import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:tagmind_frontend/main.dart';
import 'package:tagmind_frontend/providers/auth_provider.dart';
import 'package:tagmind_frontend/screens/auth_screen.dart';

// Mock AuthProvider
class MockAuthProvider extends Mock implements AuthProvider {
  @override
  Future<void> login(String email, String password) async {
    return Future.value();
  }

  @override
  Future<void> signup(String email, String password, String? nickname) async {
    return Future.value();
  }
}

void main() {
  group('AuthScreen Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    Widget createAuthScreen() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => mockAuthProvider,
            ),
          ],
          child: AuthScreen(),
        ),
      );
    }

    testWidgets('Login mode UI elements are present', (tester) async {
      await tester.pumpWidget(createAuthScreen());

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create new account'), findsOneWidget);
      expect(find.text('Nickname'), findsNothing); // Nickname should not be present in login mode
    });

    testWidgets('Signup mode UI elements are present', (tester) async {
      await tester.pumpWidget(createAuthScreen());

      // Switch to signup mode
      await tester.tap(find.text('Create new account'));
      await tester.pump();

      expect(find.text('Signup'), findsOneWidget);
      expect(find.text('Nickname'), findsOneWidget); // Nickname should be present in signup mode
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('Login with valid credentials', (tester) async {
      await tester.pumpWidget(createAuthScreen());





      // Enter email and password
      await tester.enterText(find.byKey(ValueKey('email')), 'test@example.com');
      await tester.enterText(find.byKey(ValueKey('password')), 'password123');

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify login method was called
      verify(mockAuthProvider.login('test@example.com', 'password123')).called(1);

    testWidgets('Signup with valid credentials', (tester) async {
      await tester.pumpWidget(createAuthScreen());

      // Switch to signup mode
      await tester.tap(find.text('Create new account'));
      await tester.pump();





      // Enter details
      await tester.enterText(find.byKey(ValueKey('nickname')), 'newuser');
      await tester.enterText(find.byKey(ValueKey('email')), 'new@example.com');
      await tester.enterText(find.byKey(ValueKey('password')), 'newpassword');

      // Tap signup button
      await tester.tap(find.text('Signup'));
      await tester.pump();

      // Verify signup method was called
      verify(mockAuthProvider.signup('new@example.com', 'newpassword', 'newuser')).called(1);

    testWidgets('Login with invalid email shows error', (tester) async {
      await tester.pumpWidget(createAuthScreen());

      // Enter invalid email
      await tester.enterText(find.byKey(ValueKey('email')), 'invalid-email');
      await tester.enterText(find.byKey(ValueKey('password')), 'password123');

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify error message is shown
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('Signup with short password shows error', (tester) async {
      await tester.pumpWidget(createAuthScreen());

      // Switch to signup mode
      await tester.tap(find.text('Create new account'));
      await tester.pump();

      // Enter short password
      await tester.enterText(find.byKey(ValueKey('nickname')), 'user');
      await tester.enterText(find.byKey(ValueKey('email')), 'user@example.com');
      await tester.enterText(find.byKey(ValueKey('password')), 'short');

      // Tap signup button
      await tester.tap(find.text('Signup'));
      await tester.pump();

      // Verify error message is shown
      expect(find.text('Password must be at least 7 characters long.'), findsOneWidget);
    });
  });
}
