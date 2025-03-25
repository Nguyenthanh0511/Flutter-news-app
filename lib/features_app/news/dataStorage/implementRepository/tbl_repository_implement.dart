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
    try{

      // Dùng bất đồng bộ
      await databaseService.database
          .child(tableName)
          .child(code)
          .set(toJson(record));
      print('Insert success: $code');
    }catch(ex){
      print('Lỗi insertRecord: $ex');
      throw Exception("Lỗi insertRecord: $ex");
    }
  }

  @override
  /*
    - Phân trang (pageSize, pageNumber)
    - Sắp xếp theo ngày (với field được chỉ định qua orderByChildField)
    - Lọc theo khoảng ngày (startDate và endDate)
    - Lọc theo từ khóa (keySearch) với một hàm selector (attributeSearchSelector)
  */
  Stream<List<T>> getList({
    int pageSize = 10,
    int pageNumber = 1,
    bool sortByDate = false,
    String?
        attributeSortSelector, // Tên trường dùng để sắp xếp, ví dụ: "publishedAt"
    String? keySearch, // Từ khóa tìm kiếm (ví dụ: tiêu đề bài viết)
    String? Function(T element)?
        attributeSearchSelector, // Hàm lấy giá trị cần so sánh (ví dụ: (element) => element.title)
    String? startDate, // Ngày bắt đầu (ISO8601 string)
    String? endDate, // Ngày kết thúc (ISO8601 string)
  }) {
    try {
      Query query;

      // Nếu có khoảng ngày và field sắp xếp, sử dụng range query
      if (startDate != null &&
          endDate != null &&
          attributeSortSelector != null) {
        query = databaseService.database
            .child(tableName)
            .orderByChild(attributeSortSelector)
            .startAt(startDate)
            .endAt(endDate)
            .limitToFirst(pageSize);
        print(
            'Range Query: orderByChild($attributeSortSelector), startAt($startDate), endAt($endDate)');
      }
      // Nếu có từ khóa tìm kiếm, lấy toàn bộ dữ liệu và lọc phía client
      else if (keySearch != null &&
          keySearch.isNotEmpty &&
          attributeSearchSelector != null) {
        query = databaseService.database.child(tableName);
        print('Query with keySearch: $keySearch');
      }
      // Nếu không có khoảng ngày và không có keySearch, sử dụng phân trang và sắp xếp
      else {
        if (sortByDate) {
          if (pageNumber > 1) {
            final startKey = (pageNumber * pageSize - pageSize).toString();
            print(
                'Pagination with sortByDate: orderByChild($attributeSortSelector), startAfter($startKey)');
            query = databaseService.database
                .child(tableName)
                .orderByChild(attributeSortSelector!)
                .startAfter(startKey)
                .limitToFirst(pageSize);
          } else {
            query = databaseService.database
                .child(tableName)
                .orderByChild(attributeSortSelector!)
                .limitToFirst(pageSize);
          }
        } else {
          if (pageNumber > 1) {
            final startKey = (pageNumber * pageSize - pageSize).toString();
            print(
                'Pagination without sortByDate: orderByKey(), startAfter($startKey)');
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
      }

      return query.onValue.map((event) {
        if (event.snapshot.value == null) return [];
        final Map<dynamic, dynamic> dataValues =
            event.snapshot.value as Map<dynamic, dynamic>;
        List<T> list = dataValues.entries
            .map((entry) =>
                fromJson(Map<String, dynamic>.from(entry.value as Map)))
            .toList();

        // Nếu có từ khóa tìm kiếm, lọc danh sách phía client bằng cách sử dụng attributeSearchSelector
        if (keySearch != null &&
            keySearch.isNotEmpty &&
            attributeSearchSelector != null) {
          list = list.where((element) {
            try {
              final String attributeValue =
                  attributeSearchSelector(element)?.toLowerCase() ?? "";
              print('Attribute value: $attributeValue');
              return attributeValue.contains(keySearch.toLowerCase());
            } catch (e) {
              print('Error during attribute filtering: $e');
              return false;
            }
          }).toList();
        }

        return list;
      });
    } catch (ex) {
      print('Error in getList: $ex');
      throw Exception('Error in getList: $ex');
    }
  }

  @override
  //Tạm thời 2 action ( Hàm tìm kiếm này nhiều tạp chất quá rồi)
  /*
    - Phân trang (pageSize, pageNumber)
    - Sắp xếp theo ngày (với field được chỉ định qua orderByChildField)
    - Lọc theo từ khóa (keySearch) với một hàm selector (attributeSearchSelector)
  */
  // Stream<List<T>> getList( // Lọc từ ngày đến ngày
  //     {int pageSize = 10,
  //     int pageNumber = 1, // Mặc định ban đầu
  //     bool sortByDate = false,
  //     String? attributeSortSelector,
  //     String? keySearch,
  //     String? Function(T element)? attributeSearchSelector}) {
  //   try {
  //     Query query;
  //     if (keySearch != null && keySearch.isNotEmpty) {
  //       // Giả sử đối tượng T là NewsEntity có thuộc tính title
  //       // Tôi muốn truy vấn lọc ( Khi chọc thẳng vào database )
  //       print('attribute search selector: ${attributeSearchSelector.runtimeType}');
  //       query = databaseService.database
  //           .child(tableName)
  //           .orderByChild('${attributeSearchSelector!}');
  //       print('Query get-list: ${query}');
  //     } // Sử dụng ký tự Unicode '\uf8ff' để tìm kiếm tất cả các giá trị bắt đầu bằng title
  //     else {
  //       // Xây dựng query theo phân trang dựa trên sortByDate
  //       print('Gia tri sortByDate: $sortByDate');
  //       if (!sortByDate) {
  //         // == true
  //         // Tức là sortByDate là true thì
  //         if (pageNumber > 1) {
  //           // Lưu ý: Cách tính startKey cần đảm bảo phù hợp với định dạng 'publishedAt'
  //           final startKey = (pageNumber * pageSize - pageSize)
  //               .toString(); //Trang 1 sẽ là 1 * 10 - 10 = 0. Và 2 * 10 - 10 = 10 => Trang số 2
  //           print('Atribute sort: $attributeSortSelector');
  //           query = databaseService.database
  //               .child(tableName)
  //               .orderByChild("${attributeSortSelector}")
  //               .startAfter(startKey)
  //               .limitToFirst(pageSize);
  //         } else {

  //           query = databaseService.database
  //               .child(tableName)
  //               .orderByChild("${attributeSortSelector}")
  //               .limitToFirst(pageSize);
  //         }
  //       } else {
  //         if (pageNumber > 1) {
  //           final startKey = (pageNumber * pageSize - pageSize)
  //               .toString(); //Trang 1 sẽ là 1 * 10 - 10 = 0. Và 2 * 10 - 10 = 10 => Trang số 2
  //           print('pageNumber: $pageNumber, pageSize: $pageSize');
  //           print('Giá trị startKey nếu pageNumber > 1: $startKey');
  //           print('Atribute sort: $attributeSortSelector');
  //           query = databaseService.database
  //               .child(tableName) // Tên bảng
  //               .orderByKey()
  //               .startAfter(startKey) // Ban đầu sẽ Bắt đầu từ sau 0
  //               .limitToFirst(
  //                   pageSize); // Giới hạn là 10 phần tử. Tức là sẽ từ 1 đến 10

  //         } else {
  //           // Đoạn này sẽ thực hiện tại thời điểm người dùng mở app ( Tức là chưa phân trang )
  //           query = databaseService.database
  //               .child(tableName)
  //               .orderByKey()
  //               .limitToFirst(pageSize);
  //         }
  //       }
  //     }
  //     return query.onValue.map((event) {
  //       // Thực hiện map
  //       if (event.snapshot.value == null) {
  //         return [];
  //       }

  //       final Map<dynamic, dynamic> dataValues =
  //           event.snapshot.value as Map<dynamic, dynamic>;

  //       List<T> list = dataValues.entries
  //           .map((entry) =>
  //               fromJson(Map<String, dynamic>.from(entry.value as Map)))
  //           .toList();

  //       // Nếu có từ khóa tìm kiếm title, lọc danh sách ở phía client
  //       // Xem kết quả nè ( Đại khái là mình chỉ thay đổi cách truy vấn thôi )
  //       // Tức là nếu title có giá trị thì lấy all bản ghi ( Và lọc phía client)
  //       if (keySearch != null &&
  //           keySearch.isNotEmpty &&
  //           attributeSearchSelector != null) {
  //         list = list.where((element) {
  //           // Giả sử đối tượng T là NewsEntity có thuộc tính title
  //           try {
  //             // Truy cập thuộc tính được chỉ định bằng dynamic access
  //             final String attributeValue = attributeSearchSelector(element)!.toLowerCase();
  //             print('Attribute value: $attributeValue');
  //             return attributeValue.contains(keySearch.toLowerCase());
  //           } catch (e) {
  //             print('Lỗi query key search cụ thể lỗi: $e');
  //             throw Exception("Lỗi query key search cụ thể lỗi: $e");
  //           }
  //         }).toList();
  //       }

  //       return list;
  //     });
  //   } catch (ex) {
  //     print('Lỗi get-list: $ex');
  //     throw Exception("Lỗi get-list: $ex");
  //   }
  // }

  // Get list theo danh sach code
  @override
  Stream<List<T>> getListByCode({
    List<String> codes = const [],
  }) {
    try {
      Query query;
      // Giả sử đối tượng T là NewsEntity có thuộc tính title
      // Tôi muốn truy vấn lọc ( Khi chọc thẳng vào database )
      query = databaseService.database.child(tableName);
      // Lọc

      return query.onValue.map((event) {
        // Thực hiện map
        if (event.snapshot.value == null) {
          return [];
        }

        final Map<dynamic, dynamic> dataValues =
            event.snapshot.value as Map<dynamic, dynamic>;

        List<T> list = dataValues.entries
            .map((entry) =>
                fromJson(Map<String, dynamic>.from(entry.value as Map)))
            .toList();
        list = list.where((element) {
          try {
            // Kiểm tra xem title có chứa bất kỳ code nào không
            return codes.any(
                (code) => (element as dynamic).contains(code.toLowerCase()));
          } catch (e) {
            // Nếu element không có thuộc tính title, cho phép nó qua
            return true;
          }
        }).toList();
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
