# 🧪 Hướng Dẫn Chạy Integration Tests

## Chuẩn Bị

1. **Cập nhật thông tin đăng nhập** trong `test/integration/config/test_config.dart`:
   ```dart
   static const String username = 'your_username';
   static const String password = 'your_password';
   ```

2. **Cập nhật test data IDs** (nếu cần):
   ```dart
   static const int testAreaId = 5;
   static const int testMachineId = 3;
   static const int testComponentId = 14;
   ```

## Chạy Tests

### Chạy tất cả integration tests
```bash
flutter test test/integration/
```

### Chạy test cho Area API
```bash
flutter test test/integration/api/area_api_integration_test.dart
```

### Chạy test cho Thermal Data API
```bash
flutter test test/integration/api/thermal_data_api_integration_test.dart
```

## Xem Báo Cáo

Sau khi chạy test, báo cáo sẽ được tạo tự động trong thư mục `test_reports/`:

```
test_reports/
├── area_api/
│   ├── _SUMMARY_20260110_143025.md        ← Báo cáo tổng hợp
│   ├── getAreaTreeWithCameras_xxx.md      ← Báo cáo chi tiết từng test
│   └── ...
└── thermal_data_api/
    ├── _SUMMARY_20260110_143125.md
    └── ...
```

### Mở báo cáo trong VS Code

1. Mở thư mục `test_reports/`
2. Click vào file `.md` cần xem
3. Nhấn `Ctrl+Shift+V` (hoặc `Cmd+Shift+V` trên Mac) để xem preview

## Nội Dung Báo Cáo

Mỗi báo cáo bao gồm:

✅ **Kết quả test**: Thành công/Thất bại
📝 **Mô tả chức năng**: API làm gì, dùng để làm gì
📤 **Request info**: Endpoint, parameters
📦 **Response data**: Dữ liệu trả về hoặc lỗi
⏱️ **Thời gian thực thi**: Performance metrics

## Ví Dụ Output Console

```
================================================================================
🏢 AREA API INTEGRATION TESTS
Base URL: https://thermal.infosysvietnam.vn:10253/api
================================================================================

🔐 Logging in...
✅ Login successful
────────────────────────────────────────────────────────────────
🌳 TEST: getAreaTreeWithCameras
────────────────────────────────────────────────────────────────

📊 RESULT: ✅ SUCCESS
Root areas: 5

📍 Area: Nhà máy chính (ID: 1)
   Cameras: 5
   Children: 3
   ...

📝 Đã tạo báo cáo: test_reports/area_api/getAreaTreeWithCameras_20260110_143025.md
────────────────────────────────────────────────────────────────
```

## Troubleshooting

### ❌ Lỗi login
- Kiểm tra username/password trong test_config.dart
- Verify server URL đúng
- Kiểm tra kết nối mạng

### ❌ Test failed
- Xem file báo cáo để biết lỗi chi tiết
- Kiểm tra test data IDs có tồn tại trên server không
- Verify API endpoints chưa thay đổi

### 📝 Báo cáo không được tạo
- Kiểm tra quyền ghi file
- Xem console log có lỗi gì không
- Đảm bảo package `intl` đã được cài đặt

## Tips

💡 **Chạy test trước khi commit code** để đảm bảo không break API integration

💡 **Giữ báo cáo mới nhất** để tracking, xóa báo cáo cũ để tiết kiệm dung lượng

💡 **So sánh báo cáo** giữa các lần chạy để phát hiện regression

💡 **Share báo cáo** với team để document API behavior

---

*Tạo bởi Integration Test Framework - Thermal Mobile App*
