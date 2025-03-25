import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_news_app/cores/di/service_locator.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/news_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/entity/user_entity.dart';
import 'package:flutter_news_app/features_app/news/domain/repository/tbl_repository.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/auth_event.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/auth/authen_bloc.dart';
import 'package:flutter_news_app/features_app/news/screens/bottom_nav_bar.dart';
import 'package:flutter_news_app/features_app/news/screens/mainNewsScreen/main_news_detail.dart';
import 'package:flutter_news_app/features_app/news/screens/bloc/profile/profile_bloc.dart';
import 'package:flutter_news_app/features_app/news/service/authenService/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Đã sửa ở đây: Import DateFormat
import 'package:image_picker/image_picker.dart';
import 'package:flutter_news_app/features_app/news/screens/profileScreen/post_news_screen.dart';
import 'package:flutter_news_app/features_app/news/screens/profileScreen/edit_post_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _sortByDate = true;
  DateTime? _startDate; // Đã sửa ở đây: Biến lưu ngày bắt đầu
  DateTime? _endDate; // Đã sửa ở đây: Biến lưu ngày kết thúc
  final DateFormat displayDateFormat =
      DateFormat('yyyy-MM-dd'); // Định dạng hiển thị ngày
  UserEntity? _currentUser;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  // Giờ sẽ đến UI
  @override
  void initState() {
    // Khởi tạo trạng thái ( Bất cứ thay đổi gì trên widget cần phải gọi đến hàm này để thay đổi trạng thái)
    super.initState();
    _scrollController.addListener(_onScroll); // Hàm lắng nghe cuộn xuống
    _loadInitialData(); // Khởi tạo dữ liệu ban đầu
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final userToken = await serviceLocator<AuthService>().getUserRequested();
    final userId = userToken?.id;
    // if (userId == null) {
    //   throw Exception('User ID is null');
    // }
    final TblRepository<UserEntity> tblRepository =
        serviceLocator<TblRepository<UserEntity>>();
    final userDb = await tblRepository.getDetail(userId ?? '');
    // if(userDb == null) {
    //   throw Exception('User is null');
    // }
    setState(() {
      _currentUser = userDb ??
          UserEntity(
              id: '',
              email: '',
              name: '',
              age: 0,
              role: '',
              phoneNumber: '',
              address: '');
    });
  }

  void _loadInitialData() {
    // Đọc dữ liệu từ Bloc
    context
        .read<
            ProfileBloc>() // Truy cập instance context ( Giống kiểu trích xuất các phần tử ( Đọc ))
        .add(LoadInitialProfilevent(
            sortByDate:
                _sortByDate)); // Ban đầu thì sẽ sắp xếp theo ngày ( sort by date)
  }

  // Liệu rằng người dùng đã cuộn xuống cuối danh sách chưa? Đoạn code dưới sẽ giải quyết vấn đề
  // đấy bằng cách phân chia pixel của màn và đo xem vị trí đã cuốn xuống dưới ( )
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      context.read<ProfileBloc>().add(
          LoadMoreProfileEvent()); // Nếu cuộn xuống dưới thì sẽ load đến sự kiện load trang
    }
  }

  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI CODE Ở ĐÂY: Loại bỏ SafeArea bên ngoài Scaffold để tránh thêm padding không cần thiết,
    // và Scaffold sẽ tự quản lý vùng hiển thị của bottomNavigationBar.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => BlocProvider<ProfileBloc>(
      //         create: (context) => serviceLocator<ProfileBloc>(),
      //         child: CreatePostScreen(),
      //       ),
      //     ),
      //   ),
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.blue,
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'), // Thêm route cho create-post
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      // endDrawer: _buildProfileDrawer(), 
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () {
              // Thêm logic đăng xuất
              (context).read<AuthenBloc>().add(LogoutRequestedEvent());
              // Hoặc hiển thị một thông báo khi người dùng nhấn nút thoát
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng xuất thành công')));
              GoRouter.of(context).go('/login');
            },
            // icon: Icon(Icons.account_circle, color: Colors.black),
            // onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
        elevation: 1,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              flex: 5,
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
                    context.read<ProfileBloc>().add(
                          LoadInitialProfilevent(
                            sortByDate: _sortByDate,
                            keySearch:
                                value.trim().isNotEmpty ? value.trim() : null,
                            // attributeSearch: "title",
                            // attributeSort: "publishedAt",
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
                child: PopupMenuButton<String>(
                  // Bắt sự kieen khi người dùfng chọn
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
                          context.read<ProfileBloc>().add(
                                LoadInitialProfilevent(
                                  keySearch:
                                      _searchController.text.trim().isNotEmpty
                                          ? _searchController.text.trim()
                                          : null,
                                  startDate: _startDate?.toIso8601String(),
                                  endDate: _endDate?.toIso8601String(),
                                  sortByDate:
                                      _sortByDate, // Mặc định biến _sortByDate (Xem giá trị ở trên đầu)
                                ),
                              );
                        }
                      });
                    } else if (value == 'newest' || value == 'oldest') {
                      setState(() => _sortByDate = value == 'newest');
                      context.read<ProfileBloc>().add(
                            LoadInitialProfilevent(
                              sortByDate: value ==
                                  'newest', // True thì là newsest ngược lại   ( Mà nếu sai thì đổi là được)
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
                        title:
                            Text('Select time', style: TextStyle(fontSize: 13)),
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
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileNewsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildProfileHeader(),
              Expanded(
                child: _buildBodyContent(state),
              ),
            ],
          );
        },
      ),
      // THAY ĐỔI CODE Ở ĐÂY: Đặt BottomNavigationBar vào thuộc tính bottomNavigationBar
      bottomNavigationBar: Container(
        height: 65,
        child: SizedBox(
          child: const BottomNavBar(index: 1),
        ),
      ),
    );
  }

  // Header profile
  Widget _buildProfileHeader() {
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
               backgroundImage: _currentUser?.avatarUrl != null
              ? NetworkImage(_currentUser!.avatarUrl!)
              : NetworkImage('https://img.freepik.com/free-icon/boy_318-858292.jpg')
              as ImageProvider,
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.name ?? 'Guest(not name)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  _currentUser?.email ?? 'Not logged in',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatItem('Posts', _currentUser?.postCount ?? 0),
                    _buildStatItem(
                        'Followers', _currentUser?.followerCount ?? 0),
                    _buildStatItem(
                        'Following', _currentUser?.followingCount ?? 0),
                  ],
                ),
              ],
            ))
          ],
        ));
  }

  // THÊM MỚI: Xây dựng drawer profile
  Widget _buildProfileDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_currentUser?.name ?? 'Guest(not name)'),
            accountEmail: Text(_currentUser?.email ?? 'Why not email?'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _currentUser?.avatarUrl != null
                  ? CachedNetworkImageProvider(_currentUser!.avatarUrl!)
                   : NetworkImage('https://img.freepik.com/free-icon/boy_318-858292.jpg')
                      as ImageProvider,
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Login'),
            onTap: () {
              GoRouter.of(context).go('/login');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              // Thêm logic đăng xuất
              (context).read<AuthenBloc>().add(LogoutRequestedEvent());
              // Hoặc hiển thị một thông báo khi người dùng nhấn nút thoát
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng xuất thành công')));
            }
          ),
        ],
      ),
    );
  }

  //
  Widget _buildStatItem(String label, int value) {
    return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ));
  }

  Widget _buildBodyContent(ProfileState state) {
    if (state is ProfileNewsInitialState) {
      return const Center(child: CircularProgressIndicator());
    }

    List<NewsEntity> news = [];
    bool hasError = false;
    bool hasReachedMax = false;

    if (state is ProfileNewsLoadedState) {
      news = state.news;
      hasReachedMax = state.hasReachedMax;
    } else if (state is ProfileNewsLoadingState) {
      news = state.news;
    } else if (state is ProfileNewsErrorState) {
      news = state.news;
      hasError = true;
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<ProfileBloc>().add(RefreshProfileEvent()),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: news.length + (hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= news.length) {
                  return _buildBottomLoader(hasError);
                }
                return _NewsItem(news: news[index], currentUser: _currentUser);
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
                        context.read<ProfileBloc>().add(LoadMoreProfileEvent()),
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
  final UserEntity? currentUser; // Thêm để kiểm tra quyền
  // print('currentUser.id: ${currentUser?.id}');
  const _NewsItem({required this.news, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = news.userCodePost == currentUser?.id;
    print('Gia tri isCurrentUser: $isCurrentUser');
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainNewsDetail(news: news),
          ),
        ).then((value) {
          context.read<ProfileBloc>().add(RefreshProfileEvent());
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
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
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
                      
                      if (isCurrentUser) // Chỉ hiển thị nếu là bài viết của người dùng
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPostScreen(news: news),
                                ),
                              ).then((_) {
                                context.read<ProfileBloc>().add(RefreshProfileEvent());
                              });
                            } else if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<ProfileBloc>().add(DeleteProfileNewsEvent(id: news.code ?? ''));
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Chỉnh sửa'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa'),
                            ),
                          ],
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



// class _NewsItem extends StatelessWidget {
//   final NewsEntity news;

//   const _NewsItem({required this.news});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       // Hiển thị màn hình (Lai lái dạng feedback)
//       onTap: () {
//         // Bắt sự kiện tại thời điểm người dùng click vào bài viết nhé
//         // Điều hướng đến widget MainNewsDetail
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 MainNewsDetail(news: news), // Di chuyển đến widget detail
//           ),
//         ).then((value) {
//           context.read<ProfileBloc>().add(RefreshProfileEvent());
//         });
//       },
//       child: Card(
//         margin: const EdgeInsets.all(10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             news.imageUrl != null && news.imageUrl!.isNotEmpty
//                 ? CachedNetworkImage(
//                     imageUrl: news.imageUrl!,
//                     width: double.infinity,
//                     height: 200,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(
//                       color: Colors.grey[200],
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                     errorWidget: (context, url, error) {
//                       debugPrint('Lỗi khi tải ảnh: $error');
//                       return Container(
//                         width: double.infinity,
//                         height: 200,
//                         color: Colors.grey[200],
//                         child: const Icon(Icons.error),
//                       );
//                     },
//                   )
//                 : Container(
//                     width: double.infinity,
//                     height: 200,
//                     color: Colors.grey[200],
//                     child: const Icon(Icons.image_not_supported),
//                   ),
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     news.title ?? 'Không có tiêu đề',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     news.description ?? 'Không có mô tả',
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       const Icon(Icons.calendar_today, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         news.publishedAt != null
//                             ? '${DateTime.parse(news.publishedAt!).year}-${DateTime.parse(news.publishedAt!).month}-${DateTime.parse(news.publishedAt!).day} ${DateTime.parse(news.publishedAt!).hour}:${DateTime.parse(news.publishedAt!).minute}'
//                             : 'Không có ngày',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                       const Spacer(),
//                       const Icon(Icons.visibility, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${news.viewCount ?? 0}',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
