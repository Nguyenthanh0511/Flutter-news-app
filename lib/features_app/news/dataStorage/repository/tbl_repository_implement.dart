import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_news_app/cores/shared/connectFirebase/database_service.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
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

  //Tạm thời 2 action
  Stream<List<T>> getList({
  int pageSize = 10,
  int pageNumber = 1,
  bool sortByDate = false,
  String? title,
}) {
  try {
    Query query;
    // Xây dựng query theo phân trang dựa trên sortByDate
    if (sortByDate) {
      if (pageNumber > 1) {
        // Lưu ý: Cách tính startKey cần đảm bảo phù hợp với định dạng 'publishedAt'
        final startKey = (pageNumber * pageSize - pageSize).toString();
        query = databaseService.database
            .child(tableName)
            .orderByChild('publishedAt')
            .startAfter(startKey)
            .limitToFirst(pageSize);
      } else {
        query = databaseService.database
            .child(tableName)
            .orderByChild('publishedAt')
            .limitToFirst(pageSize);
      }
    } else {
      if (pageNumber > 1) {
        final startKey = (pageNumber * pageSize - pageSize).toString();
        query = databaseService.database
            .child(tableName)
            .orderByKey()
            .startAfter(startKey)
            .limitToFirst(pageSize);
      } else {
        query = databaseService.database
            .child(tableName)
            .orderByKey()
            .limitToFirst(pageSize);
      }
    }

    return query.onValue.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }

      final Map<dynamic, dynamic> dataValues =
          event.snapshot.value as Map<dynamic, dynamic>;

      List<T> list = dataValues.entries
          .map((entry) =>
              fromJson(Map<String, dynamic>.from(entry.value as Map)))
          .toList();

      // Nếu có từ khóa tìm kiếm title, lọc danh sách ở phía client
      if (title != null && title.isNotEmpty) {
        list = list.where((element) {
          // Giả sử đối tượng T là NewsEntity có thuộc tính title
          if (element is NewsEntity) {
            final elementTitle = element.title?.toLowerCase() ?? "";
            return elementTitle.contains(title.toLowerCase());
          }
          return true;
        }).toList();
      }

      return list;
    });
  } catch (ex) {
    print('Lỗi get-list: $ex');
    throw Exception("Lỗi get-list: $ex");
  }
}
  @override
  Future<T?> getDetail(String code) async {
    try {
      final snapshot =
          await databaseService.database.child(tableName).child(code).get();
      if (snapshot.exists) {
        return fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (ex) {
      print('Lỗi getDetail: $ex');
      throw Exception("Lỗi getDetail: $ex");
    }
  }

  @override
  Future<void> deleteById(String code) async {
    try {
      await databaseService.database.child(tableName).child(code).remove();
    } catch (ex) {
      print('Lỗi deleteById: $ex');
      throw Exception("Lỗi deleteById: $ex");
    }
  }

  @override
  Future<void> updateById(String code, T record) async {
    try {
      await databaseService.database
          .child(tableName)
          .child(code)
          .update(toJson(record));
    } catch (ex) {
      print('Lỗi updateById: $ex');
      throw Exception("Lỗi updateById: $ex");
    }
  }

  @override
  Future<void> deleteByListId(List<String> codes) async {
    try {
      final updates = <String, dynamic>{};
      for (var code in codes) {
        updates["$tableName/$code"] = null;
      }
      await databaseService.database.update(updates);
    } catch (ex) {
      print('Lỗi deleteByListId: $ex');
      throw Exception("Lỗi deleteByListId: $ex");
    }
  }
}
