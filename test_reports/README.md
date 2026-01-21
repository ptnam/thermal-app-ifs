# 📊 Báo Cáo Test Tự Động

## Giới Thiệu

Thư mục này chứa các báo cáo tự động được tạo ra khi chạy integration tests. Mỗi test case sẽ tạo một file báo cáo riêng với đầy đủ thông tin về kết quả, dữ liệu và mục đích sử dụng.

## Cấu Trúc Thư Mục

```
test_reports/
├── area_api/                    # Nhóm API quản lý khu vực
│   ├── _SUMMARY_yyyyMMdd_HHmmss.md   # Báo cáo tổng hợp
│   ├── getAreaTreeWithCameras_yyyyMMdd_HHmmss.md
│   ├── getAllAreas_yyyyMMdd_HHmmss.md
│   ├── getAreaList_yyyyMMdd_HHmmss.md
│   └── getAreaById_yyyyMMdd_HHmmss.md
│
└── thermal_data_api/            # Nhóm API dữ liệu nhiệt độ
    ├── _SUMMARY_yyyyMMdd_HHmmss.md
    ├── getMachineComponentPositionByArea_yyyyMMdd_HHmmss.md
    ├── getMachineAndLatestDataByArea_yyyyMMdd_HHmmss.md
    ├── getList_yyyyMMdd_HHmmss.md
    └── ... (các test khác)
```

## Nội Dung Báo Cáo

Mỗi file báo cáo bao gồm:

### 1. Thông Tin Test
- Tên test case
- Thời gian chạy test
- Kết quả (thành công/thất bại)
- Thời gian thực thi (milliseconds)

### 2. Mô Tả Chức Năng
- Chức năng của API
- Đầu vào (parameters)
- Đầu ra (response structure)
- Ứng dụng thực tế

### 3. Thông Tin Request
- Endpoint
- HTTP method
- Parameters được truyền vào

### 4. Kết Quả
- Dữ liệu trả về (nếu thành công)
- Thông báo lỗi (nếu thất bại)
- Số liệu thống kê

## Cách Sử Dụng

### Chạy Test và Tạo Báo Cáo

```bash
# Chạy tất cả integration tests
flutter test test/integration/

# Chạy test cho một API group cụ thể
flutter test test/integration/api/area_api_integration_test.dart
flutter test test/integration/api/thermal_data_api_integration_test.dart
```

### Xem Báo Cáo

1. Sau khi chạy test, mở thư mục `test_reports/`
2. Chọn nhóm API tương ứng (area_api, thermal_data_api)
3. Mở file báo cáo mới nhất (sắp xếp theo timestamp)
4. Xem file `_SUMMARY_xxx.md` để có cái nhìn tổng quan

### Báo Cáo Tổng Hợp

File `_SUMMARY_xxx.md` trong mỗi folder chứa:
- Tổng số test đã chạy
- Số lượng thành công/thất bại
- Tỷ lệ thành công
- Danh sách chi tiết kết quả từng test
- Thông tin về các test thất bại (nếu có)

## Ví Dụ Nội Dung Báo Cáo

### File Test Đơn Lẻ

```markdown
# 📊 BÁO CÁO TEST API

---

## 📋 Thông Tin Test

| Thuộc tính | Giá trị |
|------------|---------|
| **Tên test** | getAreaTreeWithCameras |
| **Thời gian** | 10/01/2026 14:30:25 |
| **Kết quả** | ✅ THÀNH CÔNG |
| **Thời gian thực thi** | 1250ms |

## 📝 Mô Tả Chức Năng

API này trả về cấu trúc cây phân cấp đầy đủ của tất cả các khu vực...

## 📤 Thông Tin Request

```json
{
  "endpoint": "getAreaAllTree",
  "method": "GET",
  "authentication": "Bearer Token",
}
```

## ✅ Kết Quả Thành Công

### 📦 Dữ Liệu Trả Về

```json
{
  "total_root_areas": 5,
  "total_cameras": 25,
  "total_children": 15,
  ...
}
```
```

## Lưu Ý

- Báo cáo được tạo tự động mỗi khi chạy test
- File báo cáo có timestamp để tránh ghi đè
- Có thể xóa các báo cáo cũ để giữ thư mục gọn gàng
- Báo cáo sử dụng format Markdown, có thể xem bằng:
  - VS Code (preview markdown)
  - GitHub
  - Bất kỳ markdown viewer nào

## Troubleshooting

### Báo cáo không được tạo

- Kiểm tra quyền ghi file trong thư mục test_reports
- Đảm bảo package `intl` đã được thêm vào pubspec.yaml
- Xem log console để kiểm tra lỗi

### Dữ liệu báo cáo trống

- Kiểm tra kết nối API server
- Verify access token còn hiệu lực
- Kiểm tra test data IDs trong test_config.dart

## Đóng Góp

Khi thêm test case mới, nhớ:
1. Sử dụng `ReportHelper.createReport()` để tạo báo cáo
2. Thêm `TestResult` vào list để tạo summary
3. Viết mô tả chức năng bằng tiếng Việt
4. Cung cấp đủ thông tin request/response

---

*Được tạo tự động bởi hệ thống Integration Test*
