import 'package:fitness_webapp/frontend/front.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the personal trainer portal', (tester) async {
    await tester.pumpWidget(const FitnessWebApp());

    expect(find.text('MrPT'), findsWidgets);
    expect(find.text('Fitness'), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Welcome, Maya Johnson'), findsOneWidget);
    expect(find.text('Assigned members'), findsWidgets);
    expect(find.text('Recent activities'), findsOneWidget);

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.text('My Members'), findsOneWidget);
    expect(find.text('Ava Ramos'), findsWidgets);
    expect(find.text('Progress tracking'), findsOneWidget);
    expect(find.text('Attendance history'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Workout Tasks'), findsOneWidget);
    expect(find.text('Assigned tasks'), findsOneWidget);
    expect(find.text('Task progress'), findsOneWidget);
    expect(find.text('Photo upload system'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Update profile'), findsOneWidget);
    expect(find.text('Contact information'), findsOneWidget);
    expect(find.text('Certifications'), findsOneWidget);
  });

  testWidgets('pins the bottom navigation to the bottom of the page', (
    tester,
  ) async {
    await tester.pumpWidget(const FitnessWebApp());
    await tester.pumpAndSettle();

    // Dashboard content is rendered.
    expect(find.text('Welcome, Maya Johnson'), findsOneWidget);

    // The bottom navigation rests against the bottom edge of the scaffold
    // instead of floating in the middle of the screen.
    final scaffold = tester.getRect(find.byType(Scaffold));
    final navIconCenter = tester.getCenter(find.byIcon(Icons.person_outline)).dy;
    expect(navIconCenter, greaterThan(scaffold.bottom * 0.85));
    expect(navIconCenter, lessThanOrEqualTo(scaffold.bottom));
  });

  testWidgets('admin signs in and creates a trainer with a generated ID', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FitPilotApp());
    await tester.pump();
    await tester.pumpAndSettle();

    // The app opens on the login screen showing only the sign-in form.
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Use admin credentials'), findsNothing);

    // The admin types their ID and password manually, then signs in (the last
    // 'Sign in' is the button, the first is the heading).
    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'ADM-0001'); // Account ID
    await tester.enterText(loginFields.at(1), 'Admin@123'); // Password
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    // The admin console dashboard is shown.
    expect(find.text("Today's summary"), findsOneWidget);

    // Open the Trainers tab and the Add trainer dialog.
    await tester.tap(find.text('Trainers').last);
    await tester.pumpAndSettle();
    expect(find.text('All trainers'), findsOneWidget);

    await tester.tap(find.text('Add trainer'));
    await tester.pumpAndSettle();

    // The create form previews the generated ID.
    expect(find.text('Generated ID'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jordan Lee'); // Full name
    await tester.enterText(fields.at(2), 'secret123'); // Password
    await tester.tap(find.text('Create trainer'));
    await tester.pumpAndSettle();

    // The credentials dialog confirms the new account, then it appears in the
    // directory.
    expect(find.text('Trainer created'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Jordan Lee'), findsWidgets);
  });

  testWidgets('admin can navigate every console section', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1100, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FitPilotApp());
    await tester.pump();
    await tester.pumpAndSettle();

    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'ADM-0001');
    await tester.enterText(loginFields.at(1), 'Admin@123');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Members').last);
    await tester.pumpAndSettle();
    expect(find.text('All members'), findsOneWidget);
    expect(find.text('Membership plans'), findsOneWidget);

    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    expect(find.text('Photo approvals'), findsOneWidget);

    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    expect(find.text('Reports'), findsWidgets);

    // A More sub-page opens.
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(find.text('Payment history'), findsOneWidget);
  });
}
