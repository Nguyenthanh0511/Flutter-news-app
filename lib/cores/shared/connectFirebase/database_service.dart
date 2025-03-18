// Connect
import 'package:firebase_database/firebase_database.dart';
//Cấu hình thêm document hay collection nhỉ ( Đại khá là table news )
// import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';

class DatabaseService{
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Tao một instance context 

  // doc du lieu
  DatabaseReference get database => _database; // Cách viết tắt nhé ( Có nghĩa là gán xong trả về _database)
  //Check connect to database
  Future<bool> checkConnection() async{
    try{
      final connectedRef = FirebaseDatabase.instance.ref('.info/connected');
      final snapshot = await connectedRef.get();
      return snapshot.value as bool ?? false;
    }catch(ex){
      print('Lỗi kết nối: $ex');
      throw Exception(("Lỗi kết nối tới database"));
      // return false;
    }
  }
  // Cấu hình entity news ( Tin tức)


}