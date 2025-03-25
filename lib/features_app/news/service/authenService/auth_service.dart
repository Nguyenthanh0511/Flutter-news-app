import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Sử dụng thư viện authen service của firebase nhé mọi người. Nay chúng ta sẽ làm
// chức năng đăng nhập, đăng ký
class AuthService{
  final fbAuth.FirebaseAuth _firebaseAuth = fbAuth.FirebaseAuth.instance;
  Future<fbAuth.UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<fbAuth.UserCredential> login({ // Đăng nhập
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Dang xuat
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Chuyển đổi Firebase user thành custom User (có thể mở rộng) ( Form dành cho đăng nhập ( Đăng ký skhgon sử dụng được))
  UserEntity? userFromFirebase(fbAuth.User? firebaseUser, {String? name, int? age, String? role, String? phoneNumber, String? address}) {
    if (firebaseUser == null) return null;
    return UserEntity(
      id: firebaseUser.uid,
      name: name ?? firebaseUser.email ?? '',
      age: age ?? 0,
      role: role ?? 'User', //Queyn User va Admin
      phoneNumber: firebaseUser.phoneNumber ?? '',
      // address: firebaseUser.address ?? '',
      email: firebaseUser.email ?? '',
    );
  }

   Future<void> saveUserDetails(UserEntity user) async {
    // Lưu thông tin người dùng dưới node 'users/{id}'
    final TblRepository<UserEntity> tblUserRepository = serviceLocator<TblRepository<UserEntity>>();
    await tblUserRepository.insertRecord(user.id, user);

  }
  Future<UserEntity?> getUserRequested() async {
    try{
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final TblRepository<UserEntity> userEntity = serviceLocator<TblRepository<UserEntity>>();
      final user = await userEntity.getDetail(uid);
      print('get user: ${user!.toJson()}');
      // if(user == null){
      //   print('User is null with id: $uid');
      //   throw Exception('User is null with id: $uid');
      // }
      return user;
    } 
    catch (e) {
      print('Lỗi get dữ liệu user: $e');
      throw Exception('Lỗi get dữ liệu user: $e');
    }
  }

  // Tiếp theo đăng ký dependency injection

}