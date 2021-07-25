import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nravepay/nravepay.dart';

class HttpService {
  static HttpService get instance => ngetIt<HttpService>();

  late Dio _dio;

  Dio get dio => _dio;

  HttpService._() {
    var staging = Setup.instance.staging;
    var options = BaseOptions(
      baseUrl: staging
          ? 'https://ravesandboxapi.flutterwave.com'
          : Setup.instance.version == Version.v2
              ? 'https://api.ravepay.co'
              : 'https://api.flutterwave.com',
      responseType: ResponseType.json,
      connectTimeout: 60000,
      receiveTimeout: 60000,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: Setup.instance.secKey
      },
    );
    _dio = Dio(options);
    if (staging) {
      _dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
        ),
      );
    }
  }

  factory HttpService() => HttpService._();
}