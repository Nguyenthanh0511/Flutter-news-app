import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/main_news_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_detail.dart';
class MainNewsScreen extends StatefulWidget {
  const MainNewsScreen({Key? key}) : super(key: key);

  @override
  _MainNewsScreenState createState() => _MainNewsScreenState();
}

class _MainNewsScreenState extends State<MainNewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _sortByDate = true;

  @override

  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _loadInitialData() {
    context
        .read<MainNewsBloc>()
        .add(LoadInitialNewsEvent(sortByDate: _sortByDate));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MainNewsBloc>().add(LoadMoreNewsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.blueGrey, // Điều chỉnh theo giao diện của bạn
        title: Row(
          children: [
            const Text(
              'News',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    context.read<MainNewsBloc>().add(
                          LoadInitialNewsEvent(
                            sortByDate: _sortByDate,
                            title: value.trim().isNotEmpty ? value.trim() : null,
                          ),
                        );
                  },
                ),
              ),
            ),
            DropdownButton<bool>(
              value: _sortByDate,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text("Newest", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28,)),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text("oldest", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28,)),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortByDate = value);
                  context.read<MainNewsBloc>().add(
                        LoadInitialNewsEvent(
                          sortByDate: value,
                          title: _searchController.text.trim().isNotEmpty
                              ? _searchController.text.trim()
                              : null,
                        ),
                      );
                }
              },
            ),
          ],
        ),
      ),
      body: BlocConsumer<MainNewsBloc, MainNewsState>(
        listener: (context, state) {
          if (state is NewsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return _buildBodyContent(state);
        },
      ),
    );
  }

  Widget _buildBodyContent(MainNewsState state) {
    if (state is NewsInitialState) {
      return const Center(child: CircularProgressIndicator());
    }

    List<NewsEntity> news = [];
    bool hasError = false;
    bool hasReachedMax = false;

    if (state is NewsLoadedState) {
      news = state.news;
      hasReachedMax = state.hasReachedMax;
    } else if (state is NewsLoadingState) {
      news = state.news;
    } else if (state is NewsErrorState) {
      news = state.news;
      hasError = true;
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<MainNewsBloc>().add(RefreshNewsEvent()),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: news.length + (hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= news.length) {
                  return _buildBottomLoader(hasError);
                }
                return _NewsItem(news: news[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLoader(bool hasError) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: hasError
            ? Column(
                children: [
                  const Text('Lỗi tải dữ liệu'),
                  TextButton(
                    onPressed: () =>
                        context.read<MainNewsBloc>().add(LoadMoreNewsEvent()),
                    child: const Text('Thử lại'),
                  )
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
class _NewsItem extends StatelessWidget {
  final NewsEntity news;

  const _NewsItem({required this.news});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Điều hướng đến widget MainNewsDetail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainNewsDetail(news: news),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            news.imageUrl != null && news.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: news.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) {
                      debugPrint('Lỗi khi tải ảnh: $error');
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title ?? 'Không có tiêu đề',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.description ?? 'Không có mô tả',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        news.publishedAt?.split('T')[0] ?? 'Không có ngày',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      const Icon(Icons.visibility, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${news.viewCount ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}