import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';

class MainNewsDetail extends StatefulWidget {
  final NewsEntity news;

  const MainNewsDetail({Key? key, required this.news}) : super(key: key);

  @override
  _MainNewsDetailState createState() => _MainNewsDetailState();
}

class _MainNewsDetailState extends State<MainNewsDetail> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _increaseViewCount();
  }

  void _increaseViewCount() async {
    if (widget.news.code == null) return;

    DatabaseReference newsRef = _database.child('news/${widget.news.code}/viewCount');
    try {
      final event = await newsRef.get();
      if (event.exists) {
        int currentViews = (event.value as int?) ?? 0;
        await newsRef.set(currentViews + 1);
      } else {
        await newsRef.set(1);
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật viewCount: $e');
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
          ],
        ),
      ),
    );
  }
}