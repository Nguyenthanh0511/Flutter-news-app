import 'package:flutter/material.dart';
import 'package:flutter_news_app/features_app/app/route.dart';
import 'package:flutter_news_app/features_app/app/themes.dart';
// Cấu hình dưới main.dart nữa là chạy app xem
class MainApp extends StatelessWidget{
  // final bool firebaseConnected;
  // final String? errorMessage;
  const MainApp({
    super.key,
    // required this.firebaseConnected,
    // this.errorMessage,
    });


  @override
  Widget build(BuildContext context){
      

    return MaterialApp.router(

      debugShowCheckedModeBanner: false,
      // Connect firebase
       // Đọc cấu hình Firebase từ file JSON và tạo đối tượng FirebaseOptions
      theme: AppThemes.themeData,
      routerConfig: AppRoute().generatedRoute(
        // firebaseConnected,errorMessage
        ),
    );
  }
}