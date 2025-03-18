import 'dart:async';

abstract class TblRepository<T>{
  Future<bool> checkConnection();

  // Các action
  Future<void> insertRecord(String id, T record);

  Stream<List<T>> getList({int pageSize, int pageNumber, bool sortByDate});

  // Future<T?> getDetail(String code);
  // Future<void> deleteById(String code);
  // Future<void> updateById(String code, T record);
  // Future<void> deleteByListId(List<String> codes);
}