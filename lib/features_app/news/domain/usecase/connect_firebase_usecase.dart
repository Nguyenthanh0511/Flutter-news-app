import 'package:flutter_news_app/cores/shared/connectFirebase/connect_firebase.dart';
import 'package:firebase_core/firebase_core.dart'; // Để khởi tạo Firebase

class ConnectFirebaseUseCase {
  Future<void> initializeApp() async{

    final FirebaseOptions firebaseOptions = await loadFirebaseOptions();
    // Khởi tạo Firebase với các tùy chọn đã tải (phải thực hiện trước khi chạy app)
    await Firebase.initializeApp(options: firebaseOptions);
    print('Connect Firebase thành công!');
  }
}
// Ddại ý là chỉ có thể dùng bất đồng bộ trong hàm có bất đồng bộ
// Giowf ddawng ky ca su dung