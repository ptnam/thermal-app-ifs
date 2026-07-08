# Đặc tả chức năng ứng dụng IFS – Camera Vision
> Tài liệu này mô tả **chức năng** của từng màn hình. Không đề cập thiết kế giao diện hiện tại. Dùng để yêu cầu AI thiết kế lại giao diện mới.

---

## Tổng quan ứng dụng

| Thuộc tính | Mô tả |
|---|---|
| Tên ứng dụng | IFS – AISOFT / Camera Vision |
| Phụ đề | Phần mềm Camera thông minh |
| Nền tảng | iOS & Android (Flutter) |
| Ngôn ngữ | Tiếng Việt |
| Chủ đề màu | Dark theme (nền tối) |

**Mục đích ứng dụng**: Giám sát camera nhiệt, theo dõi nhiệt độ thiết bị công nghiệp theo thời gian thực, nhận cảnh báo khi nhiệt độ vượt ngưỡng hoặc khi AI phát hiện sự bất thường qua camera.

---

## Điều hướng chính

### Bottom Navigation Bar (Thanh điều hướng dưới)
Gồm **4 tab**, luôn hiển thị khi đã đăng nhập:

| Index | Tên tab | Icon |
|---|---|---|
| 0 | Trang chủ | Home |
| 1 | Camera | Camera |
| 2 | Sự cố | Warning/Bell |
| 3 | Báo cáo | Chart/Report |

### Side Drawer (Menu trượt từ trái)
Mở bằng icon hamburger (☰) trên AppBar của mỗi tab. Nội dung:
- **Header**: Avatar người dùng + Tên đầy đủ + Vai trò (Role)
- **Cấu hình Server** (chỉ hiện trong chế độ developer)
- **Privacy Policy** (mở trình duyệt ngoài)
- **Đăng xuất** / **Đăng nhập** (tùy trạng thái)

---

## Màn hình 1 – Đăng nhập (Login Screen)

**Mục đích**: Xác thực người dùng trước khi vào ứng dụng.

### Thành phần giao diện

| Thành phần | Chức năng |
|---|---|
| Logo ứng dụng | Hiển thị logo IFS ở trung tâm màn hình |
| Tiêu đề "IFS – AISOFT" | Tên ứng dụng |
| Phụ đề "Phần mềm Camera thông minh" | Mô tả ngắn |
| Trường "Tên đăng nhập" | Nhập username, có icon người dùng |
| Trường "Mật khẩu" | Nhập mật khẩu, có icon khóa, nút ẩn/hiện mật khẩu |
| Nút "Đăng nhập" | Submit form, disable khi form chưa hợp lệ, hiện loading spinner khi đang xử lý |
| Bản quyền | Dòng text nhỏ ở cuối màn hình |
| Icon cài đặt (góc trên phải) | Truy cập màn hình cấu hình URL server (chỉ hiện trong chế độ developer) |

### Luồng xử lý
1. Người dùng nhập username + password (tối thiểu 3 ký tự)
2. Nút "Đăng nhập" chỉ kích hoạt khi cả hai trường có giá trị hợp lệ
3. Nhấn đăng nhập → gọi API → hiện loading → nếu thành công chuyển vào màn hình chính
4. Nếu lỗi → hiện thông báo lỗi dạng snackbar (nổi dưới màn hình)
5. Sau đăng nhập thành công → tự động đăng ký FCM token để nhận push notification

---

## Màn hình 2 – Cấu hình Server (Config Screen)

**Mục đích**: Cho phép người dùng (developer/admin) thiết lập URL backend server.

### Thành phần giao diện
- Trường nhập URL server API
- Nút lưu cấu hình

**Lưu ý**: Màn hình này chỉ truy cập được từ nút Settings ở góc trên phải màn hình đăng nhập (chế độ developer).

---

## Màn hình 3 – Trang chủ (Home Page)

**Mục đích**: Dashboard tổng quan giám sát nhiệt độ và trạng thái thiết bị theo khu vực.

### AppBar
- Icon hamburger (☰) mở Side Drawer
- **Dropdown chọn khu vực (Area)**: Danh sách khu vực từ server, tự động lưu lựa chọn để dùng ở các tab khác

### Nội dung (scroll dọc, từ trên xuống)

#### Card 1 – Nhiệt độ Môi trường
- Hiển thị nhiệt độ môi trường của khu vực đang chọn
- Giá trị dạng: `XX.X°C`
- Tự động làm mới mỗi 1 phút
- Trạng thái: Đang tải... / giá trị nhiệt độ / dấu `—` nếu không có dữ liệu

#### Card 2 – Máy Nóng Nhất / Lạnh Nhất
- Hai cột: máy có nhiệt độ cao nhất và thấp nhất trong khu vực
- Hiển thị: tên máy, nhiệt độ tương ứng
- Tự động làm mới mỗi 1 phút

#### Card 3 – Biểu đồ tròn Trạng thái Thiết bị
- Pie chart thể hiện tỷ lệ thiết bị theo trạng thái (Online / Offline / Cảnh báo...)
- Có chú thích màu sắc cho từng trạng thái

#### Card 4 – Cảnh báo Mới nhất
- Danh sách các cảnh báo nhiệt độ vượt ngưỡng mới nhất của khu vực
- Mỗi mục hiển thị: tên máy, mức nhiệt, thời gian, loại cảnh báo
- Cuộn dọc trong phần còn lại của màn hình

---

## Màn hình 4 – Camera (Camera Page)

**Mục đích**: Xem trực tiếp (livestream) từ tất cả camera theo khu vực.

### AppBar
- Icon hamburger (☰) mở Side Drawer
- Tiêu đề "Camera"

### Bộ chọn khu vực (Horizontal chips)
- Thanh ngang cuộn được, mỗi chip là một khu vực/phòng
- Chip đang chọn được highlight (màu nổi bật)
- Khi chọn chip → danh sách camera phía dưới cập nhật theo khu vực đó

### Danh sách Camera (List)
Mỗi item gồm:

| Thành phần | Mô tả |
|---|---|
| Khung video preview | Hiển thị luồng HLS thời gian thực (200px chiều cao), tự load khi item xuất hiện trong viewport |
| Trạng thái loading | Spinner khi đang tải stream |
| Trạng thái lỗi | Icon "no signal" khi không thể tải |
| Tên camera | Tên camera bên dưới video |
| Tên khu vực | Sub-text nhỏ hơn |
| Icon phóng to | Nhấn để xem toàn màn hình |

**Hành vi thông minh của video**: Video chỉ phát khi item hiển thị >20% trong viewport; tự dừng/giải phóng bộ nhớ khi cuộn ra ngoài; dừng toàn bộ khi chuyển sang màn hình chi tiết.

**Pull-to-refresh**: Kéo xuống để tải lại danh sách camera.

---

## Màn hình 5 – Xem Camera Toàn màn hình (Camera Stream Page)

**Mục đích**: Xem chi tiết một camera với video fullscreen, điều khiển PTZ nếu hỗ trợ.

**Truy cập**: Nhấn vào bất kỳ camera nào ở màn hình Camera.

### Thành phần giao diện

| Thành phần | Điều kiện |
|---|---|
| Video player toàn màn hình | Luôn có, phát HLS stream |
| Nút back | Quay lại danh sách camera |
| **PTZ D-pad Controller** | Chỉ hiện với camera loại PTZ |

### PTZ Controller (Camera có thể xoay/zoom)
- D-pad 4 hướng: Lên, Xuống, Trái, Phải
- Nút Zoom In / Zoom Out
- Có thể preset vị trí
- Điều khiển thời gian thực qua API

---

## Màn hình 6 – Sự cố / Thông báo (Notification Page)

**Mục đích**: Xem lịch sử và danh sách các sự cố cảnh báo, bao gồm cả cảnh báo nhiệt độ và cảnh báo AI.

### AppBar
- Icon hamburger (☰) mở Side Drawer
- Tiêu đề "Sự cố"
- **Icon bộ lọc (funnel)**: Mở dialog lọc tương ứng theo tab đang xem

### Tab Bar – 2 tab

---

### Tab 1 – Nhiệt độ Vượt Ngưỡng

**Mô tả**: Danh sách các lần nhiệt độ thiết bị vượt quá ngưỡng cài đặt.

#### Mỗi card thông báo nhiệt độ hiển thị
- Tên thiết bị / bộ phận
- Giá trị nhiệt độ ghi nhận
- Thời gian xảy ra
- Khu vực
- Trạng thái (đã xử lý / chưa xử lý)

#### Bộ lọc (hiện khi nhấn icon funnel ở Tab 1)
- Khoảng thời gian (From – To)
- Khu vực (dropdown)
- Máy (dropdown, phụ thuộc khu vực đã chọn)
- Trạng thái thông báo
- Kiểu so sánh

#### Hành vi danh sách
- Phân trang (pageSize = 20)
- Load thêm khi cuộn đến 90% danh sách
- Pull-to-refresh để tải lại từ đầu

#### Nhấn vào card → Màn hình chi tiết thông báo nhiệt độ (NotificationDetailPage)

---

### Tab 2 – Cảnh báo AI

**Mô tả**: Danh sách sự kiện do AI phát hiện qua camera (phát hiện người, phương tiện, cháy, bất thường...).

#### Mỗi card cảnh báo AI hiển thị
- Tên sự kiện cảnh báo (ví dụ: "Quá nhiệt", "Cháy", "Cảnh báo...")
- Ngày giờ phát hiện
- Badge "AI" với màu mức độ nguy hiểm:
  - Đỏ: Quá nhiệt / Nguy hiểm / Cháy
  - Vàng: Cảnh báo thông thường
  - Xanh: Thông tin
- Chip khu vực (icon vị trí + tên khu vực)
- Chip camera (icon camera + tên camera)
- Ảnh preview (nếu có) – hiển thị hình ảnh từ camera tại thời điểm phát hiện

#### Bộ lọc (hiện khi nhấn icon funnel ở Tab 2)
- Khoảng thời gian (From – To)
- Khu vực (dropdown)
- Camera (dropdown, phụ thuộc khu vực đã chọn)
- Loại sự kiện cảnh báo (dropdown)

#### Hành vi danh sách
- Phân trang (pageSize = 20)
- Load thêm khi cuộn đến 90% danh sách
- Pull-to-refresh để tải lại

#### Nhấn vào card → Màn hình chi tiết cảnh báo AI

---

## Màn hình 7 – Chi tiết Cảnh báo AI (Vision Notification Detail Screen)

**Mục đích**: Xem đầy đủ thông tin một sự kiện cảnh báo AI.

**Truy cập**: Nhấn vào card cảnh báo AI ở Tab 2 màn hình Sự cố.

### Thành phần giao diện (scroll dọc từ trên xuống)

#### Phần 1 – Ảnh sự kiện (Hero Image)
- Ảnh chụp từ camera tại thời điểm phát hiện, chiều cao cố định ~280px
- Gradient mờ dần từ ảnh xuống nền
- Badge cảnh báo nổi góc trên phải: icon warning + tên loại cảnh báo + màu theo mức độ

#### Phần 2 – Card tổng quan cảnh báo
- Tên loại cảnh báo (lớn, màu theo mức độ nguy hiểm)
- Ngày giờ phát hiện
- Chip khu vực + chip camera

#### Phần 3 – Card thông tin thời gian
- Ngày: DD/MM/YYYY
- Giờ: HH:MM:SS

#### Phần 4 – Card thông tin vị trí
- Khu vực
- Tên camera
- Trong vùng giám sát: Có / Không (màu xanh / đỏ)

---

## Màn hình 8 – Báo cáo (Report Page)

**Mục đích**: Hiển thị biểu đồ phân tích dữ liệu nhiệt độ và thống kê cảnh báo.

### AppBar
- Icon hamburger (☰) mở Side Drawer
- Tiêu đề "Báo cáo"

### Nội dung (scroll dọc)

#### Biểu đồ 1 – Đường nhiệt độ (Thermal Line Chart)
- Biểu đồ đường (line chart) thể hiện sự thay đổi nhiệt độ theo thời gian
- Nhiều đường (multi-series) tương ứng với nhiều máy / bộ phận máy khác nhau
- Trục X: Thời gian (2 ngày gần nhất)
- Trục Y: Nhiệt độ (°C)
- Có lưới (grid lines) và chú thích màu (legend)
- Dữ liệu được lọc theo cài đặt người dùng (khu vực, máy, bộ phận máy)

#### Biểu đồ 2 – Số lượng Cảnh báo (Notification Count Chart)
- Tiêu đề: "Tổng số cảnh báo"
- Sub-title: "7 ngày qua"
- Thể hiện số lượng cảnh báo nhiệt độ theo từng ngày trong 7 ngày gần nhất

---

## Màn hình 9 – Cài đặt (Setting Page)

**Mục đích**: Quản lý tài khoản và thông tin ứng dụng.

**Truy cập**: Từ Side Drawer hoặc Bottom Navigation (hiện bị ẩn, có thể bật lại).

### Các nhóm cài đặt

#### Nhóm 1 – Tài khoản
| Tùy chọn | Mô tả |
|---|---|
| Đăng xuất (khi đã đăng nhập) | Hiện dialog xác nhận → đăng xuất, hủy FCM token, chuyển về login |
| Đăng nhập (khi chưa đăng nhập) | Chuyển đến màn hình đăng nhập |

#### Nhóm 2 – Bảo mật & Quyền riêng tư
| Tùy chọn | Mô tả |
|---|---|
| Chính sách bảo mật | Mở trình duyệt ngoài đến trang Privacy Policy |

#### Nhóm 3 – Dành cho nhà phát triển
| Tùy chọn | Mô tả |
|---|---|
| API Test | Truy cập màn hình kiểm tra các API endpoints |

#### Nhóm 4 – Về ứng dụng
- Tên ứng dụng: Camera Vision
- Phiên bản: 1.0.0

---

## Màn hình 10 – Chi tiết Thông báo Nhiệt độ (Notification Detail Page)

**Mục đích**: Xem chi tiết một sự kiện nhiệt độ vượt ngưỡng.

**Truy cập**: Nhấn vào card ở Tab 1 màn hình Sự cố.

### Thông tin hiển thị
- Tên thiết bị / bộ phận
- Giá trị nhiệt độ ghi nhận
- Ngưỡng cài đặt
- Thời điểm xảy ra
- Khu vực
- Trạng thái xử lý

---

## Màn hình 11 – API Test Page (Developer)

**Mục đích**: Cho phép kiểm tra thủ công các API endpoints.

**Truy cập**: Settings → API Test.

### Thành phần
- Danh sách các API endpoint
- Nút gọi từng API
- Hiển thị kết quả response (JSON)

---

## Tính năng Cross-screen

### Push Notification (FCM)
- Đăng ký nhận notification ngay sau khi đăng nhập
- Nhận cảnh báo khi ứng dụng ở background hoặc bị đóng
- Hủy đăng ký khi đăng xuất

### Session Management
- Token tự động refresh khi hết hạn
- Tự động chuyển về Login khi session expired
- Lưu trữ token an toàn (Secure Storage)

### Khu vực được chọn (Global Area State)
- Khu vực chọn ở Trang chủ được lưu lại
- Tự động áp dụng làm bộ lọc mặc định ở màn hình Sự cố

---

## Luồng điều hướng tổng thể

```
App khởi động
    ↓
Kiểm tra session
    ├── Chưa đăng nhập → Màn hình Đăng nhập
    └── Đã đăng nhập   → Main Shell (Bottom Nav)
                              ├── Tab 0: Trang chủ
                              │       └── [Side Drawer]
                              ├── Tab 1: Camera
                              │       └── Camera tile → Camera Stream (Fullscreen + PTZ)
                              ├── Tab 2: Sự cố
                              │       ├── Tab Nhiệt độ → Chi tiết thông báo nhiệt độ
                              │       └── Tab AI       → Chi tiết cảnh báo AI
                              └── Tab 3: Báo cáo
```

---

## Dữ liệu & API

### Các loại dữ liệu chính

| Entity | Mô tả |
|---|---|
| Area (Khu vực) | Cây phân cấp khu vực (parent → children) |
| Camera | Thông tin camera, loại (fixed / PTZ), luồng HLS |
| Machine (Máy) | Thiết bị công nghiệp cần giám sát nhiệt độ |
| MachinePart (Bộ phận máy) | Các bộ phận riêng lẻ của máy |
| ThermalData | Dữ liệu nhiệt độ theo thời gian |
| Notification | Cảnh báo nhiệt độ vượt ngưỡng |
| VisionNotification | Cảnh báo phát hiện bởi AI camera |
| WarningEvent | Loại sự kiện cảnh báo AI (cháy, người lạ, v.v.) |
| User | Thông tin người dùng, role (Admin / Manager / User) |

### Phân quyền theo Role

| Tính năng | Admin | Manager | User |
|---|---|---|---|
| Xem Dashboard | ✅ | ✅ | ✅ |
| Xem Camera | ✅ | ✅ | ✅ |
| Xem Sự cố | ✅ | ✅ | ✅ |
| Xem Báo cáo | ✅ | ✅ | ✅ |
| Cấu hình khu vực / camera | ✅ | ✅ | ❌ |
| Điều khiển PTZ | ✅ | ✅ | ✅ |

---

## Ghi chú thiết kế lại

> Khi yêu cầu AI thiết kế giao diện mới, hãy cung cấp tài liệu này và thêm các yêu cầu sau:

- **Ngôn ngữ hiển thị**: Tiếng Việt
- **Nền tảng**: Mobile (iOS & Android), tối ưu cho màn hình 375–430px chiều rộng
- **Theme**: Có thể chọn Dark hoặc Light hoặc cả hai
- **Framework**: Flutter (Material Design 3)
- **Phong cách thiết kế mong muốn**: [Mô tả phong cách bạn muốn, ví dụ: Industrial dark, Modern minimal, Glassmorphism...]
- **Màu chủ đạo**: [Chỉ định màu brand, ví dụ: Navy + Orange, Teal + Dark...]
- **Font**: [Chỉ định font, ví dụ: Inter, Roboto, SF Pro...]
