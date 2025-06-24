import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_url.dart';
import '../global_value.dart';

class ApiFunction {
  static Future<void> apiRequest({
    required String url,
    required String method,
    Object? data,
    Map<String, dynamic>? headers,
    Function(dio.Response)? onSuccess,
    Function(dio.Response)? onError,
    Function(String)? onUnauthorized,
    Function(String)? onServerError,
    Function(String)? onBadRequest,
    Function(String)? onNotFound,
    int retries = 3,
    int currentRetry = 0,
  }) async {
    bool hasNetwork = await NetworkManager.checkNetworkAndShowPopup();

    if (!hasNetwork) {
      log("No internet connection. API call stopped for URL => $url");
      return;
    }
    try {
      log("API Request Initiated: URL => $url, Method => $method");
      if (data != null) log("Request Data: ${data.toString()}");
      var myDio = dio.Dio();
      dio.Response response;

      if (method == 'GET') {
        log("Sending GET request to URL => $url");
        response = await myDio.get(
          url,
          options: dio.Options(
            headers: headers ?? {"Authorization": 'Bearer $accessToken'},
            validateStatus: (status) => true,
          ),
        );
      } else if (method == 'POST') {
        log("Sending POST request to URL => $url");
        response = await myDio.post(
          url,
          data: data,
          options: dio.Options(
            headers: headers ?? {"Authorization": 'Bearer $accessToken'},
            validateStatus: (status) => true,
          ),
        );
      } else if (method == 'PUT') {
        log("Sending PUT request to URL => $url");
        response = await myDio.put(
          url,
          data: data,
          options: dio.Options(
            headers: headers ?? {"Authorization": 'Bearer $accessToken'},
            validateStatus: (status) => true,
          ),
        );
      } else {
        log("Sending DELETE request to URL => $url");
        response = await myDio.delete(
          url,
          options: dio.Options(
            headers: headers ?? {"Authorization": 'Bearer $accessToken'},
            validateStatus: (status) => true,
          ),
        );
      }

      log("Response Received: URL => $url, Status Code => ${response.statusCode}");
      switch (response.statusCode) {
        case 200:
        case 201:
          if (onSuccess != null) onSuccess(response);
          break;
        case 400:
          log("Bad Request Error for URL => $url");
          if (onBadRequest != null) {
            onBadRequest('Bad Request: ${response.data}');
          }
          if (onError != null) onError(response);
          break;
        case 401:
          log("Unauthorized Error for URL => $url");
          if (onUnauthorized != null) {
            onUnauthorized('Unauthorized: ${response.data}');
          }
          break;
        case 403:
          log("Forbidden Error for URL => $url");
          if (onError != null) onError(response);
          break;
        case 404:
          log("Not Found Error for URL => $url");
          if (onNotFound != null) onNotFound('Not Found: ${response.data}');
          if (onError != null) onError(response);
          break;
        case 500:
          log("Server Error for URL => $url");
          if (onServerError != null) {
            onServerError('Internal Server Error: ${response.data}');
          }
          break;
        default:
          log("Unhandled Error for URL => $url");
          if (onError != null) onError(response);
          break;
      }
    } catch (err) {
      log("API Request Error for URL => $url, Error => ${err.toString()}");

      // Retry logic
      if (currentRetry < retries) {
        log("Retrying API Request for URL => $url... Attempt ${currentRetry + 1}");
        await apiRequest(
          url: url,
          method: method,
          data: data,
          headers: headers,
          onSuccess: onSuccess,
          onError: onError,
          onUnauthorized: onUnauthorized,
          onServerError: onServerError,
          onBadRequest: onBadRequest,
          onNotFound: onNotFound,
          retries: retries,
          currentRetry: currentRetry + 1,
        );
      } else {
        if (onError != null) {
          onError(dio.Response(
            requestOptions: dio.RequestOptions(path: url),
            statusCode: 500,
            statusMessage: 'Internal Error: ${err.toString()}',
          ));
        }
      }
    }
  }

  static Future<void> refreshTokenApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      log("Initiating Refresh Token API: URL => ${ApiUrl.refreshToken}");
      dio.FormData formData = dio.FormData.fromMap({
        "refresh": refreshToken,
        "access": accessToken,
      });
      var myDio = dio.Dio();
      await myDio
          .post(
        ApiUrl.refreshToken,
        data: formData,
        options: dio.Options(
          headers: {
            "Content-Type":
                'multipart/form-data; boundary=<calculated when request is sent>',
          },
          validateStatus: (status) => true,
        ),
      )
          .then((value) async {
        log("Refresh Token Response for URL => ${ApiUrl.refreshToken}, Status Code => ${value.statusCode}");
        if (value.statusCode == 200 || value.statusCode == 201) {
          log('Refresh Token API Response : ${value.data.toString()}');
          accessToken = value.data['access'];
          refreshToken = value.data['refresh'];
          prefs.setString('accessToken', accessToken);
          prefs.setString('refreshToken', refreshToken);
        } else if (value.statusCode == 400 ||
            value.statusCode == 404 ||
            value.statusCode == 403) {
          log('Refresh Token API Error Response : ${value.data.toString()}');
        }
      });
    } catch (err) {
      log("Refresh Token API Error => ${err.toString()}");
    }
  }
}