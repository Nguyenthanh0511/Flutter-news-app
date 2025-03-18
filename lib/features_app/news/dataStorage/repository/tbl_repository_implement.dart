import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_news_app/cores/shared/connectFirebase/database_service.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';

//
class TblRepositoryImplement<T> implements TblRepository<T> {
  final DatabaseService databaseService;
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  //Init
  TblRepositoryImplement(
      {required this.databaseService,
      required this.tableName,
      required this.fromJson,
      required this.toJson});

  @override
  Future<bool> checkConnection() => databaseService.checkConnection();

  @override
  Future<void> insertRecord(String code, T record) async {
    // Dùng bất đồng bộ
    await databaseService.database
        .child(tableName)
        .child(code)
        .set(toJson(record));
  }

  @override
  // Stream<List<T>> getList(){
  //   return databaseService.database.child(tableName).onValue.map((event){
  //     if(event.snapshot.value == null){
  //       return [];
  //     }

  //     final Map<dynamic, dynamic> dataValues =
  //       event.snapshot.value as Map<dynamic, dynamic>;

  //     return dataValues.entries
  //       .map((entry) => fromJson(Map<String, dynamic>.from(entry.value as Map))).toList();
  //   });
  // }
  //-----------Phân trang

  //Tạm thời 2 action
  Stream<List<T>> getList({
    int pageSize = 10,
    int pageNumber = 1,
    bool sortByDate = false
  }) {
    try {
      final startKey = (pageNumber * pageSize - pageSize).toString();
      return databaseService.database
          .child(tableName)
          .orderByKey()
          .limitToFirst(pageSize)
          .startAfter(startKey)
          .onValue
          .map((event) {
        if (event.snapshot.value == null) {
          return [];
        }

        final Map<dynamic, dynamic> dataValues =
            event.snapshot.value as Map<dynamic, dynamic>;

        return dataValues.entries
            .map((entry) =>
                fromJson(Map<String, dynamic>.from(entry.value as Map)))
            .toList();
      });
    } catch (ex) {
      print('Lỗi get-list: $ex');
      throw Exception("Lỗi get-list: $ex");
    }
  }
}
