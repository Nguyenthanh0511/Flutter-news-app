import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/comment_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/domain/usecase/tbl_usecase.dart';
import 'package:flutter_news_app/features_app/news/screens/commentScreen/comment_section.dart';
import 'package:flutter_news_app/features_app/news/service/authenService/auth_service.dart';
class MainNewsDetail extends StatefulWidget {
  final NewsEntity news;

  const MainNewsDetail({Key? key, required this.news}) : super(key: key);

  @override
  _MainNewsDetailState createState() => _MainNewsDetailState();
}

class _MainNewsDetailState extends State<MainNewsDetail> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _currentLikeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _currentLikeCount = widget.news.likeCount ?? 0;

  }

  void _loadInitialData() async{
    if(widget.news.code == null) return;

    try{
      final TblRepository<NewsEntity> newsEntity = serviceLocator<TblRepository<NewsEntity>>();
      NewsEntity? getEntity = await newsEntity.getDetail(widget.news.code!);
      if(getEntity == null){
        debugPrint('Lỗi khi tìm thấy bài viết với code la: ${widget.news.code}');
        throw Exception('Lỗi khi tìm thấy bài viết với code la: ${widget.news.code}');
      }
      print('view Entity: ${getEntity.toJson()}');
      //Update view
      NewsEntity updateViewNews;

      int currentViews = (getEntity.viewCount as int?) ?? 0;
      int count = currentViews + 1;
      // String userCode = 'Thanhkk';
      updateViewNews = getEntity.copyWith(viewCount: count, 
        // userCode: userCode
        );
      await newsEntity.updateById(widget.news.code!, updateViewNews);

    }catch(e){
      debugPrint('Lỗi khi cập nhật viewCount: $e');
      throw Exception('Lỗi khi cập nhật viewCount: $e');
    }
  }

  // Void comment ( Viết thêm chức năng comment ), cần dependencty injection CommentEntity
  void _openCommentSection(){ 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentSection(newsCode: widget.news.code ?? '') 
       
      )
    ).then((value){
      setState(() {
        
      });
    });
  }



  // CHức năng like bài viết
  void _increaseLikeCount() async{
    if(widget.news.code == null) return;
    try{
      final TblRepository<NewsEntity> newsEntity = serviceLocator<TblRepository<NewsEntity>>();
      final NewsEntity? event = await newsEntity.getDetail(widget.news.code!);
      if(event == null){
        debugPrint('Lỗi khi cập nhật likeCount không tìm thấy bài viết với code là: ${widget.news.code}');
        throw Exception('Lỗi khi cập nhật likeCount không tìm thấy bài viết với code là: ${widget.news.code}');
      }

      /// get user
      final UserEntity? userDb = await serviceLocator<AuthService>().getUserRequested();
      String currentCodeUser = userDb?.id ?? '';
      if(currentCodeUser == '') {
        debugPrint('Lỗi khi tìm thấy user');
        throw Exception('Lỗi khi tìm thấy user');
      }
      
      DatabaseReference likeUserRef = FirebaseDatabase.instance.ref().child('news/${widget.news.code}/likes/$currentCodeUser');

      //Kiem tra user da like chua
      DataSnapshot snapshot = await likeUserRef.get();
      if(snapshot.exists && snapshot.value == true){ // Nếu user đã bấm like mà muốn hủy
        debugPrint('User ${userDb?.name ?? ''}, có id ${userDb?.id ?? ''} đã like bài viết');
        await likeUserRef.remove();
        int currentLikeCount = (event.likeCount as int?) ?? 0;
        int count = currentLikeCount - 1;
          _currentLikeCount = count;
          NewsEntity updateEvent = event.copyWith(likeCount: count);
          await newsEntity.updateById(widget.news.code!, updateEvent);
          setState((){
            _currentLikeCount = count;
          });
      }
      else{ // Nếu user chưa bấm like thì có thể bấm like
        int currentLikeCount = (event.likeCount as int?) ?? 0;
        if(currentLikeCount == 0 || currentLikeCount == null){
          int count = 1;
          _currentLikeCount = count;
          NewsEntity updateEvent = event.copyWith(likeCount: count);
          await newsEntity.updateById(widget.news.code!, updateEvent);
          await likeUserRef.set(true);
          setState((){
            _currentLikeCount = count;
          });
        }
        else{
          int count = currentLikeCount + 1;
          _currentLikeCount = count;
          NewsEntity updateEvent = event.copyWith(likeCount: count);
          await newsEntity.updateById(widget.news.code!, updateEvent);
          await likeUserRef.set(true);
          setState((){
            _currentLikeCount = count;
          });
        }
      }


    }catch(ex){
      debugPrint('Lỗi khi cập nhật likeCount: $ex');
      throw Exception('Lỗi khi cập nhật likeCount: $ex');
    }
  }

  Future<int> _countCountComment() async {
    try{

      final TblRepository<NewsEntity> newsEntity = serviceLocator<TblRepository<NewsEntity>>();

      final NewsEntity? entity = await newsEntity.getDetail(widget.news.code!);

      if(entity == null){
        debugPrint('Lỗi khi tìm thấy commentCount voi news code: ${widget.news.code}');
        throw Exception('Lỗi khi tìm thấy commentCount voi news code: ${widget.news.code}');
      }

      return (entity!.commentCount) ?? 0;
    }
    catch(ex){
      debugPrint('Lỗi khi tìm thấy commentCount: $ex');
      throw Exception('Lỗi khi tìm thấy commentCount: $ex');
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.news.title ?? 'Chi tiết tin tức', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.news.imageUrl != null && widget.news.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.news.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  ),
            const SizedBox(height: 16),
            Text(
              widget.news.title ?? 'Không có tiêu đề',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.news.publishedAt?.split('T')[0] ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              widget.news.description ?? 'Không có mô tả',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.news.content ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Màu nút Like
                  ),
                  onPressed: _increaseLikeCount,
                  icon: const Icon(Icons.thumb_up, color: Colors.white),
                  label: Text(
                    'Like ($_currentLikeCount)',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
               ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: _openCommentSection,
                icon: const Icon(Icons.comment, color: Colors.white),
                label: FutureBuilder(
                  future: _countCountComment(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text('Comment(${snapshot.data})', style: TextStyle(color: Colors.white));
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              )
              ]
            )
          ],
        ),
      ),
    );
  }
}