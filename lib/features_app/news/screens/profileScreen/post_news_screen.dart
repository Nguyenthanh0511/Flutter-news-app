import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/screens/bottom_nav_bar.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_detail.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/profile/profile_bloc.dart';
import 'package:flutter_news_app/features_app/news/service/authenService/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController(); // Đã sửa ở đây: Thêm controller cho URL ảnh
  File? _selectedImage;
  bool _isLoading = false;

  // Chọn ảnh từ gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Upload ảnh nếu có chọn từ thiết bị, nếu không thì kiểm tra URL đã nhập
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await context
            .read<ProfileBloc>()
            .uploadImage(_selectedImage!); // Upload từ thiết bị cá nhân
      } else if (_imageUrlController.text.trim().isNotEmpty) { // Đã sửa ở đây: Kiểm tra URL ảnh
        imageUrl = _imageUrlController.text.trim();
      }

      // Tạo bài viết mới
      final newPost = NewsEntity(
        code: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        description: _contentController.text,
        imageUrl: imageUrl,
        publishedAt: DateTime.now().toIso8601String(),
        // Đã sửa ở đây: Sử dụng userCodePost từ AuthService
        userCodePost: await serviceLocator<AuthService>().getUserRequested().then((user) => user?.id),
      );
      TblRepository<NewsEntity> tblRepository = serviceLocator<TblRepository<NewsEntity>>();
      // await tblRepository.insertRecord(newPost.code!, newPost);
      print('My post is: ${newPost.toJson()}');
      // Thêm bài viết vào Bloc
      
      context
          .read<ProfileBloc>()
          .add(InsertProfileNewsEvent(id: newPost.code!, newsEntity: newPost));

        // Thay thế điều hướng hiện tại
     // Chuyển hướng bằng cách pop và push
      // Sử dụng context.go() để điều hướng
    context.go('/profile');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đăng bài: ${e.toString()}')));
      print('Lỗi khi đăng bài: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose(); // Đã sửa ở đây: Dispose controller URL
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng bài mới', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập nội dung' : null,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              // Đã sửa ở đây: Thêm ô nhập URL ảnh
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL ảnh (nếu có)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              // Vẫn giữ nguyên giao diện chọn ảnh từ gallery (không bắt buộc)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage == null 
                    ? Center(child: Text('Chạm để thêm ảnh từ thiết bị (tuỳ chọn)'))
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : () async{
                 await _submitPost();
                },
                child: _isLoading 
                  ? CircularProgressIndicator()
                  : Text('Đăng bài'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
