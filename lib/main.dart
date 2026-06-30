import 'package:fitness_webapp/frontend/front.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const FitPilotApp());
}

