# Integration Tests

Integration tests cho Thermal Mobile App - Test thực tế với server.

## 📋 Cấu trúc thư mục

```
test/integration/
├── config/
│   ├── test_config.dart              # Config chung (URL, credentials, IDs)
│   └── test_client_factory.dart      # Factory tạo API clients
├── helpers/
│   └── auth_helper.dart              # Helper xử lý authentication
└── api/
    ├── auth_api_integration_test.dart          # Test Auth API
    ├── area_api_integration_test.dart          # Test Area API
    └── thermal_data_api_integration_test.dart  # Test ThermalData API
```

## 🚀 Setup

### 1. Cấu hình credentials

Mở file `test/integration/config/test_config.dart` và cập nhật:

```dart
class IntegrationTestConfig {
  // ⚠️ THAY ĐỔI THEO TÀI KHOẢN TEST CỦA BẠN
  static const String testUsername = 'your_username';  // TODO: Đổi
  static const String testPassword = 'your_password';  // TODO: Đổi
  
  // ⚠️ THAY ĐỔI THEO DỮ LIỆU THẬT TRÊN SERVER
  static const int testAreaId = 1;          // TODO: Đổi
  static const int testMachineId = 1;       // TODO: Đổi
  static const int testComponentId = 1;     // TODO: Đổi
  static const int testMonitorPointId = 1;  // TODO: Đổi
}
```

### 2. Verify server connection

Đảm bảo server đang chạy tại:
```
https://thermal.infosysvietnam.com.vn:10253
```

## 🧪 Chạy Tests

### Chạy tất cả integration tests
```bash
flutter test test/integration/
```

### Chạy test cụ thể
```bash
# Test Auth API
flutter test test/integration/api/auth_api_integration_test.dart

# Test Area API  
flutter test test/integration/api/area_api_integration_test.dart

# Test ThermalData API
flutter test test/integration/api/thermal_data_api_integration_test.dart
```

### Chạy với verbose output
```bash
flutter test test/integration/ --verbose
```

## 🔐 Xử lý Authentication

**AuthHelper tự động quản lý token:**

1. Lần đầu tiên test chạy → Login và cache token
2. Các test sau → Dùng cached token (không login lại)
3. Token hết hạn → Gọi `AuthHelper.clearToken()` và login lại

### Example usage trong test:

```dart
late String accessToken;

setUpAll(() async {
  // Tự động login và lấy token
  accessToken = await AuthHelper.getAccessToken();
});

test('some test', () async {
  // Dùng accessToken cho API calls
  final result = await service.someMethod(accessToken: accessToken);
  // ...
});
```

## 📊 Output mẫu

Khi chạy test thành công, bạn sẽ thấy:

```
============================================================
🔐 Logging in to get access token...
Username: admin
============================================================
✅ Login successful!
Access Token: eyJhbGciOiJIUzI1NiIsInR5...
Token Type: Bearer
Expires In: 3600s
============================================================

────────────────────────────────────────────────────────
📍 TEST: getMachineComponentPositionByArea
────────────────────────────────────────────────────────
Area ID: 1

📊 RESULT: ✅ SUCCESS
Data count: 5

📦 Sample Data (First Component):
  ID: 1
  Name: Component A
  Machine ID: 1
  Machine Name: Machine X
  Position: (100.0, 200.0)
  Temperature Level: normal
────────────────────────────────────────────────────────
```

## ⚠️ Troubleshooting

### Login failed
```
❌ Login failed: Invalid credentials
⚠️  Vui lòng kiểm tra:
  1. Username/password trong test/integration/config/test_config.dart
  2. Server có đang chạy: https://thermal.infosysvietnam.com.vn:10253
  3. Network connection
```

**Giải pháp:**
1. Kiểm tra username/password trong `test_config.dart`
2. Ping server để verify connection
3. Kiểm tra firewall/VPN

### API call failed with 401
```
❌ Error: Unauthorized
Status Code: 401
```

**Giải pháp:**
1. Token đã hết hạn → Clear và login lại:
```dart
AuthHelper.clearToken();
accessToken = await AuthHelper.getAccessToken();
```

### Test data not found
```
⚠️  No components found for this area
```

**Giải pháp:**
1. Update test data IDs trong `test_config.dart`
2. Verify data tồn tại trên server

## 📝 Best Practices

1. **Không commit credentials thật** - Dùng environment variables hoặc `.env` file
2. **Test với dữ liệu test** - Không test với production data
3. **Cleanup data** - Xóa test data sau khi test xong
4. **Run locally trước** - Đừng chạy test lần đầu trên CI/CD
5. **Skip tests không cần thiết** - Dùng flag `skipAuthTests` khi cần

## 🔗 Liên quan

- Unit Tests: `test/data/network/`
- Widget Tests: `test/widget_test.dart`
- Main code: `lib/data/network/`
