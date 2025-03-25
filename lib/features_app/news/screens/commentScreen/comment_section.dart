import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/comment_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entityView/comment_entity_view.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_event.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/authen_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/service/authenService/auth_service.dart';
import 'package:flutter_news_app/features_app/news/domain/Mapping/mapping_common.dart';
import 'package:collection/collection.dart';

class CommentSection extends StatefulWidget {
  final String newsCode;
  const CommentSection({Key? key, required this.newsCode}) : super(key: key);

  @override
  _CommentSection createState() => _CommentSection();
}

class _CommentSection extends State<CommentSection> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _commentController = TextEditingController();
  List<CommentEntityView> _commentViews = [];
  late Stream<DatabaseEvent> _commentStream;
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Lấy thông tin người dùng hiện tại
    listenForComment();
  }

  // Lấy thông tin người dùng hiện tại
  void _getCurrentUser() async {
    _currentUser = await serviceLocator<AuthService>().getUserRequested();
    setState(() {});
  }

  void listenForComment() {
    print('listen for comment, news code is: ${widget.newsCode}');
    _commentStream = _database.child('comment').onValue;

    _commentStream.listen((event) async {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        List<Map<String, dynamic>> commentMaps = [];
        for (final key in data.keys) {
          final Map<String, dynamic> commentMap = Map<String, dynamic>.from(data[key]);
          if (commentMap['newsCode'] == widget.newsCode) {
            commentMaps.add(commentMap);
          }
        }

        final Set<String> userCodes = commentMaps.map((map) => map['userCode'] as String).toSet();
        TblRepository<UserEntity> tblUserRepository = serviceLocator<TblRepository<UserEntity>>();
        final List<UserEntity> userList = (await tblUserRepository.getListByCode(codes: userCodes.toList()).first).toList();
        final Map<String, UserEntity> userMap = { for (var user in userList) user.id: user };

        List<CommentEntityView> comments = commentMaps.map((map) {
          final comment = CommentEntity.fromJson(map);
          final user = userMap[comment.userCode];
          return comment.toView(userName: user?.name);
        }).toList();

        final sortComments = comments.sortedBy((element) => element.createDate);
        setState(() {
          _commentViews = sortComments;
        });
      } else {
        setState(() {
          _commentViews = [];
        });
      }
    });
  }

  void _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    final commentId = const Uuid().v4();
    final UserEntity? userDb = await serviceLocator<AuthService>().getUserRequested();
    if (userDb == null) throw Exception('User is null with id: ${userDb?.id}');
    final newComment = CommentEntity(
        code: commentId,
        newsCode: widget.newsCode,
        userCode: userDb.id,
        createDate: DateTime.now(),
        content: content,
        updateDate: null,
        userCodeUpdate: null);
    try {
      final TblRepository<CommentEntity> commentEntity = serviceLocator<TblRepository<CommentEntity>>();
      await commentEntity.insertRecord(commentId, newComment);
      _commentController.clear();

      final TblRepository<NewsEntity> newsEntity = serviceLocator<TblRepository<NewsEntity>>();
      final news = await newsEntity.getDetail(widget.newsCode);
      int countComments = (news!.commentCount) ?? 0;
      countComments = news.commentCount == null ? 1 : countComments + 1;
      final updateNews = news.copyWith(commentCount: countComments);
      await newsEntity.updateById(widget.newsCode, updateNews);
    } catch (e) {
      throw Exception('Lỗi post comment: $e');
    }
  }

  // Hiển thị hộp thoại chỉnh sửa comment
  void _showEditDialog(CommentEntityView comment) {
    final TextEditingController _editController = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Comment'),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(hintText: 'Edit your comment'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedContent = _editController.text.trim();
              if (updatedContent.isNotEmpty) {
                await _updateComment(comment.code, updatedContent);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Cập nhật comment trong cơ sở dữ liệu
  Future<void> _updateComment(String commentId, String newContent) async {
    try {
      final TblRepository<CommentEntity> commentEntity = serviceLocator<TblRepository<CommentEntity>>();
      final comment = await commentEntity.getDetail(commentId);
      if (comment != null) {
        final updatedComment = comment.copyWith(
          content: newContent,
          updateDate: DateTime.now(),
          userCodeUpdate: _currentUser?.id,
        );
        await commentEntity.updateById(commentId, updatedComment);
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật comment: $e');
    }
  }

  // Hiển thị hộp thoại xác nhận xóa comment

  void _showDeleteConfirmation(CommentEntityView comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteComment(comment.code);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Xóa comment khỏi cơ sở dữ liệu
  Future<void> _deleteComment(String commentId) async {
    try {
      final TblRepository<CommentEntity> commentEntity = serviceLocator<TblRepository<CommentEntity>>();
      await commentEntity.deleteById(commentId);

      final TblRepository<NewsEntity> newsEntity = serviceLocator<TblRepository<NewsEntity>>();
      final news = await newsEntity.getDetail(widget.newsCode);
      if (news != null) {
        int countComments = news.commentCount ?? 0;
        countComments = countComments > 0 ? countComments - 1 : 0;
        final updatedNews = news.copyWith(commentCount: countComments);
        await newsEntity.updateById(widget.newsCode, updatedNews);
      }
    } catch (e) {
      throw Exception('Lỗi xóa comment: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comment',
          style: TextStyle(color: const Color.fromARGB(255, 174, 172, 172)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _commentViews.isEmpty
                ? const Center(
                    child: Text(
                      'No comment yet!',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 174, 167, 167)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _commentViews.length,
                    itemBuilder: (context, index) {
                      final comment = _commentViews[index];
                      final isCurrentUser = comment.userCode == _currentUser?.id;
                      return ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '${comment.userName}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 232, 180, 180)),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          comment.content,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${comment.createDate.day}/${comment.createDate.month}/${comment.createDate.year}",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            if (isCurrentUser) // Chỉ hiển thị nếu là comment của người dùng hiện tại
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDialog(comment);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(comment);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: const Color.fromARGB(255, 246, 242, 242)),
                    minLines: 1,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Write your comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _postComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}