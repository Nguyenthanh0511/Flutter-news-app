// Import các package cần thiết
import 'dart:convert'; // Để decode file JSON
import 'package:firebase_core/firebase_core.dart'; // Để khởi tạo Firebase
import 'package:flutter/services.dart'
    show rootBundle; // Để load file từ assets

/// Hàm loadFirebaseOptions() đọc file JSON cấu hình từ assets, phân tích dữ liệu và tạo FirebaseOptions
Future<FirebaseOptions> loadFirebaseOptions() async {
  try {
    // Đọc nội dung file JSON từ thư mục assets (đảm bảo file được khai báo trong pubspec.yaml)
    final String configString =
        await rootBundle.loadString('lib/cores/shared/connectFirebase/google-services.json');

    // Chuyển nội dung JSON thành Map<String, dynamic>
    final Map<String, dynamic> config = json.decode(configString);

    // Lấy thông tin project từ phần "project_info" của file JSON
    final Map<String, dynamic> projectInfo = config['project_info'];

    // Lấy thông tin của client đầu tiên từ danh sách "client"
    final Map<String, dynamic> client = config['client'][0];
    // Lấy thông tin của client từ "client_info"
    final Map<String, dynamic> clientInfo = client['client_info'];

    // Lấy API key từ mảng "api_key" (lấy phần tử đầu tiên)
    final String apiKey = client['api_key'][0]['current_key'];

    // Tạo đối tượng FirebaseOptions với các thông số cần thiết:
    // - apiKey: API key từ cấu hình
    // - appId: Mobile SDK App ID từ thông tin client
    // - projectId: Project ID từ projectInfo
    // - messagingSenderId: Project number từ projectInfo
    // - databaseURL: Firebase URL từ projectInfo
    // - storageBucket: Storage bucket từ projectInfo
    
    return FirebaseOptions(
      apiKey: apiKey,
      appId: clientInfo['mobilesdk_app_id'],
      projectId: projectInfo['project_id'],
      messagingSenderId: projectInfo['project_number'],
      databaseURL: projectInfo['firebase_url'],
      storageBucket: projectInfo['storage_bucket'],
    );

  } catch (e) {
    print('Lỗi khi tải cấu hình Firebase: $e');
    throw Exception("Lỗi khi tải cấu hình Firebase: $e");
  }
}
