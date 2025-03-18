# Flutter News App

Một ứng dụng tin tức được xây dựng bằng Flutter theo kiến trúc Clean Architecture, sử dụng Firebase Realtime Database để lưu trữ và truy xuất dữ liệu, BLoC cho quản lý trạng thái, Dependency Injection qua GetIt và GoRouter cho định tuyến.

## 📌 Tính Năng Chính

- Lấy dữ liệu tin tức từ API thông qua lớp usecase GetUseCaseApi.
- Đẩy dữ liệu tin tức từ API lên Firebase bằng PushDataFromApiToFirebaseUsecase.
- Đọc dữ liệu tin tức từ Firebase và hiển thị qua màn hình chính sử dụng BLoC.
- Quản lý dependency và khởi tạo Firebase qua ConnectFirebaseUseCase với GetIt.
- Định tuyến bằng GoRouter và hiển thị giao diện theo BLoC.

## 🚀 Yêu Cầu Cài Đặt

- Flutter 3.x trở lên
- Firebase Project với Firebase Realtime Database được thiết lập và file cấu hình google-services.json được cung cấp
- (Tùy chọn) Android Studio hoặc VS Code

## 🛠 Hướng Dẫn Cài Đặt

1. Clone repository:
```bash
git clone https://github.com/yourusername/flutter_news_app.git
cd flutter_news_app
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Cấu hình Firebase:
   - Đặt file google-services.json vào thư mục:
   ```bash
   lib/cores/shared/connectFirebase/google-services.json
   ```
   - Đảm bảo rằng file được khai báo đúng trong pubspec.yaml:
   ```yaml
   flutter:
     assets:
       - lib/cores/shared/connectFirebase/google-services.json
   ```

4. Chạy project:
```bash
flutter run
```

## 🏗 Cấu Trúc Dự Án

- **cores/**
  - **di/**: Cấu hình Dependency Injection sử dụng GetIt.
  - **network/**: Cấu hình NetworkClient với Dio.
  - **shared/**: Các hằng số và cấu hình chung (ví dụ: file cấu hình Firebase).
- **features/**
  - **news/**
    - **data/**: Các nguồn dữ liệu, API calls, repository implementations (ví dụ: TblRepositoryImplement, NewsRepositoryImplement).
    - **domain/**: Entity (ví dụ: NewsEntity), repository interface, use cases (ví dụ: GetUseCaseApi, PushDataFromApiToFirebaseUsecase, TblUsecase).
    - **presentation/**: UI và BLoC (MainNewsBloc, MainNewsScreen).
- **app/**
  - **app.dart**: Widget gốc của ứng dụng (MainApp), cấu hình theme và định tuyến.
  - **route.dart**: Cấu hình định tuyến sử dụng GoRouter.
  - **home_screen.dart**: Màn hình chính (nếu cần).

## 🔧 Hướng Dẫn Sử Dụng

### Khởi Tạo Firebase

- ConnectFirebaseUseCase được gọi trong main.dart để khởi tạo Firebase trước khi chạy ứng dụng.
- Các dependency khác (như DatabaseService) phụ thuộc vào kết nối Firebase, đảm bảo chúng được khởi tạo sau khi Firebase đã sẵn sàng.

### Quản Lý Tin Tức

- **Lấy dữ liệu API**: Usecase GetUseCaseApi lấy dữ liệu từ API, sau đó usecase PushDataFromApiToFirebaseUsecase sẽ đẩy dữ liệu lên Firebase.
- **Hiển thị tin tức**: MainNewsBloc được tiêm qua DI để quản lý trạng thái, và giao diện MainNewsScreen hiển thị danh sách tin tức từ Firebase thông qua Bloc.

### Dependency Injection

- GetIt được sử dụng để đăng ký tất cả các dependency:
  - Constants, Dio, MainNewsBloc, NewsApi, NewsRepository, GetUseCaseApi
- Các usecase và repository sử dụng generic, ví dụ: TblRepository<NewsEntity> và TblUsecase<NewsEntity>
- Firebase được khởi tạo thông qua ConnectFirebaseUseCase và các service như DatabaseService phụ thuộc vào nó.

## 📝 Lưu Ý

- **Asset Configuration**: Đảm bảo file google-services.json được đặt đúng vị trí và khai báo trong pubspec.yaml.
- **Phân trang với Firebase**: Trong TblRepositoryImplement, lưu ý khi dùng orderByKey(), các tham số startAt cần là String.
- **Chạy trên nền tảng được hỗ trợ**: Firebase Realtime Database chủ yếu hỗ trợ Android, iOS và Web. Nếu chạy trên desktop, hãy kiểm tra tính tương thích của plugin.
