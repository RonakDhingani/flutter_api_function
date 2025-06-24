# API Function for Flutter 🚀

## 📌 Overview
This repository provides a **Dart API helper** using **Dio** for network requests in Flutter. It is compatible with **GetX**, **Provider**, and other state management approaches. It includes:
- A **universal API request function** supporting GET, POST, PUT, and DELETE requests.
- **Automatic token handling** using shared_preferences.
- **Error handling and retries** for failed requests.
- A **refresh token mechanism** to maintain session validity.

## 🛠️ Features
- ✅ API calls using **Dio**
- ✅ Compatible with **GetX, Provider, and other state management solutions**
- ✅ Supports **GET, POST, PUT, DELETE** requests
- ✅ Handles **access tokens** using shared_preferences
- ✅ **Retry mechanism** for failed requests
- ✅ **Automatic refresh token implementation**

## 📂 Files Included
### 1️⃣ **api_function.dart**
- Handles API requests.
- Supports error handling & logging.
- Implements a retry mechanism.
- Uses access tokens stored in shared_preferences.

### 2️⃣ **refresh_token.dart**
- Implements a refresh token API call.
- Updates stored tokens automatically.

## 🚀 Setup & Usage
### 1️⃣ **Install Dependencies**
Add the following dependencies in pubspec.yaml:
```yaml
dependencies:
  get: ^4.6.5  # Only if using GetX
  provider: ^6.0.5  # Only if using Provider
  get_storage: ^2.0.2
  shared_preferences: ^2.2.2
  dio: ^5.4.2+1
```
Run:
```bash
flutter pub get
```

### 2️⃣ **How to Use API Function**
```dart
import 'api_function.dart';

testApiCall() {
  ApiFunction.apiRequest(
    url: 'https://your-api-url.com/data',
    method: 'GET',
    onSuccess: (response) {
      print('Data: ${response.data}');
    },
    onError: (error) {
      print('Error: ${error.statusMessage}');
    },
  );
}
```

### 3️⃣ **Refresh Token Usage**
```dart
await ApiFunction.refreshTokenApi();
```

## 📞 Contact
For any issues or suggestions, feel free to reach out or open an issue in this repository!

🚀 **Happy Coding!**

