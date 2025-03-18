import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';

class TblUsecase<T> {
  final TblRepository<T> repository;
  TblUsecase({
    required this.repository
  });

  Future<bool> checkConnection() => repository.checkConnection();
  Future<void> insertRecord(String code, T record) => repository.insertRecord(code, record);
  Stream<List<T>> getList({int pageSize = 1, int pageNumber = 10, bool sortByDate = false}) =>  repository.getList(pageSize: pageSize, pageNumber: pageNumber, sortByDate: sortByDate);
  
}