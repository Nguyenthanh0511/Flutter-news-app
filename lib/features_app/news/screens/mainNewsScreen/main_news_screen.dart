import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/main_news_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bottom_nav_bar.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_detail.dart';
import 'package:intl/intl.dart'; // Đã sửa ở đây: Import DateFormat

class MainNewsScreen extends StatefulWidget {
  const MainNewsScreen({Key? key}) : super(key: key);

  @override
  _MainNewsScreenState createState() => _MainNewsScreenState();
}

class _MainNewsScreenState extends State<MainNewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _sortByDate = true;
  DateTime? _startDate; // Đã sửa ở đây: Biến lưu ngày bắt đầu
  DateTime? _endDate; // Đã sửa ở đây: Biến lưu ngày kết thúc
  final DateFormat displayDateFormat =
      DateFormat('yyyy-MM-dd'); // Định dạng hiển thị ngày
  // Giờ sẽ đến UI
  @override
  void initState() {
    // Khởi tạo trạng thái ( Bất cứ thay đổi gì trên widget cần phải gọi đến hàm này để thay đổi trạng thái)
    super.initState();
    _scrollController.addListener(_onScroll); // Hàm lắng nghe cuộn xuống
    _loadInitialData(); // Khởi tạo dữ liệu ban đầu
  }

  void _loadInitialData() {
    // Đọc dữ liệu từ Bloc
    context
        .read<
            MainNewsBloc>() // Truy cập instance context ( Giống kiểu trích xuất các phần tử ( Đọc ))
        .add(LoadInitialNewsEvent(
            sortByDate:
                _sortByDate)); // Ban đầu thì sẽ sắp xếp theo ngày ( sort by date)
  }

  // Liệu rằng người dùng đã cuộn xuống cuối danh sách chưa? Đoạn code dưới sẽ giải quyết vấn đề
  // đấy bằng cách phân chia pixel của màn và đo xem vị trí đã cuốn xuống dưới ( )
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      context.read<MainNewsBloc>().add(
          LoadMoreNewsEvent()); // Nếu cuộn xuống dưới thì sẽ load đến sự kiện load trang
    }
  }
  //
  // Đã sửa ở đây: Hàm chọn ngày bắt đầu
  // Future<void> _selectStartDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _startDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _startDate = picked;
  //     });
  //     _loadInitialData(); // Reload dữ liệu với khoảng ngày mới
  //   }
  // }
  // // Đã sửa ở đây: Hàm chọn ngày kết thúc
  // Future<void> _selectEndDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _endDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _endDate = picked;
  //     });
  //     _loadInitialData(); // Reload dữ liệu với khoảng ngày mới
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI CODE Ở ĐÂY: Loại bỏ SafeArea bên ngoài Scaffold để tránh thêm padding không cần thiết,
    // và Scaffold sẽ tự quản lý vùng hiển thị của bottomNavigationBar.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  onSubmitted: (value) {
                    context.read<MainNewsBloc>().add(
                          LoadInitialNewsEvent(
                            sortByDate: _sortByDate,
                            keySearch:
                                value.trim().isNotEmpty ? value.trim() : null,
                            startDate: _startDate?.toIso8601String(),
                            endDate: _endDate?.toIso8601String(),
                          ),
                        );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 4,
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>( // Bắt sự kieen khi người dùfng chọn
                  onSelected: (value) async {
                    if (value == 'date') {
                      Future.delayed(Duration.zero, () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDateRange: DateTimeRange(
                            start: _startDate ?? DateTime.now(),
                            end: _endDate ?? DateTime.now(),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked.start;
                            _endDate = picked.end;
                          });
                          context.read<MainNewsBloc>().add(
                                LoadInitialNewsEvent(
                                  keySearch:
                                      _searchController.text.trim().isNotEmpty
                                          ? _searchController.text.trim()
                                          : null,
                                  startDate: _startDate?.toIso8601String(),
                                  endDate: _endDate?.toIso8601String(),
                                  sortByDate: _sortByDate, // Mặc định biến _sortByDate (Xem giá trị ở trên đầu)
                                ),
                              );
                        }
                      });
                    } else if (value == 'newest' || value == 'oldest') {
                      setState(() => _sortByDate = value == 'newest');
                      context.read<MainNewsBloc>().add(
                            LoadInitialNewsEvent(
                              sortByDate: value == 'newest',  // True thì là newsest ngược lại   ( Mà nếu sai thì đổi là được)
                              keySearch:
                                  _searchController.text.trim().isNotEmpty
                                      ? _searchController.text.trim()
                                      : null,
                              startDate: _startDate?.toIso8601String(),
                              endDate: _endDate?.toIso8601String(),
                            ),
                          );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'date',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.calendar_today, size: 20),
                        title: Text('Select time',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'newest',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.arrow_upward, size: 20),
                        title: Text('Newest', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'oldest',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.arrow_downward, size: 20),
                        title: Text('Oldest', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list, size: 18),
                        SizedBox(width: 4),
                        Text('Filter', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    onPressed: null, // Let PopupMenuButton handle the press
                  ),
                ),
              ),
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
      // THAY ĐỔI CODE Ở ĐÂY: Đặt BottomNavigationBar vào thuộc tính bottomNavigationBar
      bottomNavigationBar: Container(
        height: 65,
        child: SizedBox(
          child: const BottomNavBar(index: 0),
        ),
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
              padding: const EdgeInsets.only(bottom: 120),
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

  // Ý tưởng đoạn này là khi build widget thì sẽ hiển thị ở dưới là đang loading.
  // Ngoại lệ là nếu gặp lỗi thì thông báo lỗi nhé
  // LoadMoreNewsEvent ( Hàm lắng nghe này quan trọng nhé. Để lắng nghe khởi tạo dữ liệu)
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
      // Hiển thị màn hình (Lai lái dạng feedback)
      onTap: () {
        // Bắt sự kiện tại thời điểm người dùng click vào bài viết nhé
        // Điều hướng đến widget MainNewsDetail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainNewsDetail(news: news), // Di chuyển đến widget detail
          ),
        ).then((value) {
          context.read<MainNewsBloc>().add(RefreshNewsEvent());
        });
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
                        news.publishedAt != null
                            ? '${DateTime.parse(news.publishedAt!).year}-${DateTime.parse(news.publishedAt!).month}-${DateTime.parse(news.publishedAt!).day} ${DateTime.parse(news.publishedAt!).hour}:${DateTime.parse(news.publishedAt!).minute}'
                            : 'Không có ngày',
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
