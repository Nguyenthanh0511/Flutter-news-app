import 'package:flutter/material.dart';
import 'package:flutter_news_app/features_app/app/app.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
// import 'package:flutter_news_app/features_app/news/domain/usecase/connect_firebase_usecase.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/push_data_from_api_to_firebase_usecase.dart';
Future<void> main() async {
  // Đảm bảo Flutter binding đã được khởi tạo để sử dụng các API liên quan đến widgets
  WidgetsFlutterBinding.ensureInitialized();
  

  // Đăng ký các dependency qua DI (GetIt)
  await setupServiceLocator();

  // Biến để lưu trạng thái kết nối Firebase và thông báo lỗi (nếu có)
  bool firebaseConnected = false;
  String? errorMessage;

  try {
    // Chờ đợi cho đến khi các dependency bất đồng bộ được ready
    await serviceLocator.allReady();
    // Gọi hàm khởi tạo Firebase thông qua ConnectFirebaseUseCase
    // await serviceLocator<ConnectFirebaseUseCase>().initializeApp();
    // serviceLocator<PushDataFromApiToFirebaseUsecase>().execute();
    firebaseConnected = true;
  } catch (e) {
    errorMessage = e.toString();
    firebaseConnected = false;
  }
  
  // Xử lý lỗi ở cấp độ Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    // In lỗi ra console
    debugPrint('Caught Flutter error: ${details.exception}');
    // Mặc định, Flutter sẽ hiển thị màn hình đỏ trong debug mode
    // // Nếu muốn ẩn UI lỗi, ta cần thêm ErrorWidget.builder hoặc xóa cờ debug.
    // FlutterError.dumpErrorToConsole(details);
  };
  // Chạy ứng dụng và truyền trạng thái kết nối Firebase vào MainApp
  runApp(MainApp(
    
    // firebaseConnected: firebaseConnected,
    // errorMessage: errorMessage,
  ));
}
