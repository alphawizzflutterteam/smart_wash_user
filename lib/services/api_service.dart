import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dry_cleaners/constants/config.dart';
import 'package:dry_cleaners/services/interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String res = await prefs
      .getString(
        'bearerToken',
      )
      .toString();

  return res;
}

Dio getDio() {
  final Dio dio = Dio();

  //Basic Configuration
  dio.options.baseUrl = AppConfig.baseUrl;
  dio.options.connectTimeout = Duration(seconds: 60);
  dio.options.receiveTimeout = Duration(seconds: 60);
  // _dio.options.headers = {'Content-Type': 'application/json'};
  var toekn = getToken();
  dio.options.headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $toekn'
  };
  dio.options.headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $toekn'
  };
  dio.options.followRedirects = false;

  //for Logging the Request And response
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      logPrint: (object) {
        getToken();
      },
    ),
  );

  //Intercepts all requests and adds the token to the header and Allows Global Logout
  dio.interceptors.add(ElTanvirInterceptors());

  return dio;
}
