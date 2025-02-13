import 'dart:developer';

import 'api_function.dart';


Future<void> getHolidays() async {
    ApiFunction.apiRequest(
      url: ApiUrl.holidays,
      method: 'GET',
      onSuccess: (value) {
        log(value.statusCode.toString());
        log(value.statusMessage.toString());
        log('Holidays API Response : ${value.data.toString()}');
      },
      onUnauthorized: (p0) {
       // getHolidays(), whatever you wnat to call
      },
      onError: (value) {
        log('Holidays API Error Response : ${value.data.toString()}');
      },
    );
  }
