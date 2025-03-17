// Vô network client để cấu hình tới đường dẫn api
// Dio: Cung cấp. Giúp chúng ta thực hiện các request http ( get, post, put), ngoài ra hỗ trợ mã hóa dạng json

import 'package:dio/dio.dart'; // thêm thư viện dio
import 'package:flutter_news_app/cores/shared/contants.dart';
class NetworkClient{
  final Dio _dio;
  final Constants constants;
  // Khởi tạo constructor
  NetworkClient(this._dio, {required this.constants }){
    _dio.options = BaseOptions(baseUrl: constants.apiBaseUrl); // Gọi đến base url mà chúng ta

  }
  get dio => _dio;
}