# Flutter-news-app
 
Xin chào bạn đã quay trở lại Cùng Thành Lập Trình

Hôm nay mình sẽ lập trình app tin tức đơn giản.

Clean architecture ( Bloc ) và dữ liệu lấy từ api bên ngoài

Để bắt đầu. Mình mặc định các bạn đã set up môi trường flutter, SDK đầy đủ rùi nhé

Và chúng ta cùng bắt đầu.

- Vô thư mục nơi bạn cần lưu dự án và mở terminal lên. Sau đó gõ lệnh
  flutter create flutter_news_app
- Bạn có thể nhìn thấy tên app phía góc phải màn hình của mình
  
- Tiếp sau khi đã tạo thành công dự án flutter bạn hãy chạy lệnh 
  flutter run
- Và bạn sẽ thấy app giao diện ( Hãy chọn trình duyệt muốn hiển thị, mình chọn chrome) Đang kết nối tới
  

- Sau khi mở lên và bạn sẽ làm theo mình( Quay trở lại visual studio)

- Bạn hãy tạo các thư mục theo cấu trúc như sau
  Tạo cores: Nơi chứa những dependency injection, network ( Kết nối tới api) và shared
  Tạo features_app: Nơi chứa những giao diện, code logic ...
  
  - thư mục app: Nơi chạy mà có widget không thay đổi state. và có route ( Bộ chuyển đổi các đường dẫn ví dụ: màn hình main, màn hình product), và theme
  - Thư mục news: Nơi sử dụng đén kiến trúc BLoc. Và xây giao diện, dữ liệu, domain
    - domain: là thành phần chính ( entity, repository ( Ở đây sẽ là code mẫu mẫu để get list trang tin tức), usecase ( Ca sử dụng) )
    - Tiếp là screens/bloc: Nơi chứa logic nghiệp vụ 
    - Đã xong cấu trúc thư mục

- Giờ ta sẽ dependency vài thư viện. Ta vô pubspec.yaml

- Sau đó ta dùng lệnh
  Flutter pub get

- Bắt đầu code:
  
  - Vô thư mục app/shared tạo contants.dart và network để cấu hình base url của api
  - Vô domain: Để cấu hình cho entity ( Mã hóa, giải mã ( Dạng json ) ). Nhớ dependency
    thêm cho các thư mục vừa thêm
  - Mãi mới cấu hình xong entity ( Map )
  - Cấu hình tạo mới repository ( Ngắn thui)
  - Viết bloc cho trang chính tin tức (MainNews)
  - Tao api
  - Sau khi xong các entity ( Cấu hình để chuyển đổi dạng json và entity thực. Dễ dàng thao tác json, bảo trì và quản lý)
  - Các repository để sử dụng api
  - Tái thiết xong vòng đời ứng dụng thông qua file network_client
  - Giờ ta sẽ code phần giao diện ở mainNewsScreen
  - Giờ sẽ cấu hình route và app
  - Đã gặp lỗi. Giờ fix đã ( Xem bug nhé ) => Thiếu ca sử dụng call api
  - Mình đã xây xong trang main tin tức rồi. Dữ liệu đấy mình call từ api mẫu để hiển thị lên.
  - Mình chọn firebase để lưu trữ dữ liệu nhé. Giờ bắt đầu cấu hình firebase ( Dựa vào project tutoril connect firebase mình đã làm trước đó)
  - Tạo project ( Néu chưa có )
  - DI thêm firebase
  - Tạo tbl_repository và implement
  - Ca sử dụng
  - Giờ sẽ Dependency injection cho app
  - Viết thêm ca sử dụng lấy dữ liệu đã call từ api đẩy vào firebase (bảng news)
  - ca sử dụng đấy chỉ lên chạy một lần thui nhé. Chạy lại nhiều là database lặp lại nhiều bản ghi
  - Giờ test thử nhé
  - Chưa thêm ca sử dụng vào bloc