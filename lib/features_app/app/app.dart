import 'package:flutter/material.dart';
import 'package:flutter_news_app/features_app/app/route.dart';
import 'package:flutter_news_app/features_app/app/themes.dart';

// Cấu hình dưới main.dart nữa là chạy app xem
class MainApp extends StatelessWidget{
  const MainApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp.router(
      debugShowCheckedModeBanner: true,
      theme: AppThemes.themeData,
      routerConfig: AppRoute().generatedRoute()
    );
  }
}