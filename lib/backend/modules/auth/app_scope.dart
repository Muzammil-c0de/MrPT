import 'package:fitness_webapp/backend/modules/auth/app_state.dart';
import 'package:flutter/material.dart';

/// Provides the shared [AppState] to the widget tree and rebuilds dependents
/// whenever the state changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope?.notifier != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
