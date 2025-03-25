import 'package:intl/intl.dart'; // Sử dụng date
// Xây dựng chức năng comment bài viết
class CommentEntityView{
  final String code;
  final String? userCode; // Link bang user
  final String? userName;
  final String content;
  final String newsCode; // Link bang News
  final DateTime createDate;
  final String? userCodeUpdate;
  final DateTime? updateDate;

  CommentEntityView({
    required this.code,  // bắt buộc
    required this.newsCode,
    this.userCode,
    this.userName,
    required this.createDate,
    required this.content,
    this.updateDate,
    this.userCodeUpdate
  });
   factory CommentEntityView.fromJson(Map<String, dynamic> json) {
    return CommentEntityView(
      code: json['code'] as String,
      content: json['content'] as String,
      newsCode: json['newsCode'] as String,
      userCode: json['userCode'] as String?, // Làm khóa duy nhất
      createDate: DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(json['createDate']), // Cập nhật hàm chuyển đổi chuỗi sang DateTime
    updateDate: json['updateDate'] != null ? DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(json['updateDate']) : null,
      userCodeUpdate: json['userCodeUpdate'] as String?,
      userName: json['userName'] as String?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'content': content,
      'newsCode': newsCode,
      'userCode': userCode,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'userCodeUpdate': userCodeUpdate,
      'userName': userName
    };
  }

  CommentEntityView copyWith({
    String? code,
    String? userCode,
    String? userName,
    String? content,
    String? newsCode,
    DateTime? createDate,
    String? userCodeUpdate,
    DateTime? updateDate,
  }) {
    return CommentEntityView(
      code: code ?? this.code,
      content: content ?? this.content,
      newsCode: newsCode ?? this.newsCode,
      userCode: userCode ?? this.userCode,
      createDate: createDate ?? this.createDate,
      userCodeUpdate: userCodeUpdate ?? this.userCodeUpdate,
      updateDate: updateDate ?? this.updateDate,
      userName: userName ?? this.userName
    );
  }
}