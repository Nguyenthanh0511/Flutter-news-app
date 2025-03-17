import 'package:flutter/material.dart';
import 'package:flutter_news_app/features_app/app/app.dart';
import  'package:flutter_news_app/cores/di/service_locator.dart';

// Giờ thì chạy code (flutter run)
void main() async {
  await setupServiceLocator();
  runApp(const MainApp());
}