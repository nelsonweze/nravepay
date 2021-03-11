import 'dart:io';
import 'package:dio/dio.dart';
import 'payment.dart';
import 'util.payment.dart';
import 'package:async/async.dart';
import 'package:nwidgets/nwidgets.dart';

class HttpService {
  static HttpService get instance => getIt<HttpService>();

  Dio _dio;

  Dio get dio => _dio;

  HttpService._(PayInitializer init) {
    var options = BaseOptions(
      baseUrl: init.staging
          ? "https://ravesandboxapi.flutterwave.com"
          : "https://api.ravepay.co",
      responseType: ResponseType.json,
      connectTimeout: 60000,
      receiveTimeout: 60000,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    );
    _dio = Dio(options);
    if (init.staging) {
      _dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
        ),
      );
    }
  }

  factory HttpService(PayInitializer initializer) => HttpService._(initializer);
}

class TransactionService {
  static TransactionService get instance => getIt<TransactionService>();
  final HttpService _httpService;

  static final String basePath = "/flwv3-pug/getpaidx/api";
  final String _chargeEndpoint = "$basePath/charge";
  final String _chargeWithTokenEndpoint = "$basePath/tokenized/charge";
  final String _validateChargeEndpoint = "$basePath/validatecharge";
  final String _reQueryEndpoint = "$basePath/v2/verify";

  TransactionService._(this._httpService);

  factory TransactionService() {
    return TransactionService._(HttpService.instance);
  }

  Future<ChargeResponse> charge(Payload body) async {
    if (body.token.isValid())
      return chargeWithToken(ChargeWithTokenBody.fromPayload(payload: body));
    try {
      var _body = ChargeRequestBody.fromPayload(payload: body);
      final response = await this
          ._httpService
          .dio
          .post(_chargeEndpoint, data: _body.toJson());
      return ChargeResponse.fromJson(response.data);
    } on DioError catch (e) {
      print('charge ${e.message}');
      throw NRavePayException(data: e?.response?.data);
    } catch (e) {
      print(e);
      throw NRavePayException();
    }
  }

  Future<ChargeResponse> chargeWithToken(ChargeWithTokenBody body) async {
    try {
      final response = await this
          ._httpService
          .dio
          .post(_chargeWithTokenEndpoint, data: body.toJson());
      return ChargeResponse.fromJson(response.data);
    } on DioError catch (e) {
      print('charge token ${e.message}');
      throw NRavePayException(data: e?.response?.data);
    } catch (e) {
      print(e);
      throw NRavePayException();
    }
  }

  Future<ChargeResponse> validateCardCharge(
      ValidateChargeRequestBody body) async {
    try {
      final response = await this
          ._httpService
          .dio
          .post(_validateChargeEndpoint, data: body.toJson());
      return ChargeResponse.fromJson(response.data);
    } on DioError catch (e) {
      throw NRavePayException(data: e?.response?.data);
    } catch (e) {
      throw NRavePayException();
    }
  }

  Future<ReQueryResponse> reQuery(String txRef, String secret) async {
    try {
      print('requery');
      final response = await this
          ._httpService
          .dio
          .post(_reQueryEndpoint, data: {"txref": txRef, "SECKEY": secret});
      print('requery resp ${response?.statusMessage}');
      return ReQueryResponse.fromJson(response.data);
    } on DioError catch (e) {
      print(e);
      throw NRavePayException(data: e?.response?.data);
    } catch (e) {
      print(e);
      throw NRavePayException();
    }
  }
}

class BankService {
  static BankService get instance => getIt<BankService>();

  final HttpService _httpService;

  static final String _basePath = "/flwv3-pug/getpaidx/api";
  final String _bankEndpoint = "$_basePath/flwpbf-banks.js";

  BankService._(this._httpService);

  factory BankService() {
    return BankService._(HttpService.instance);
  }

  var _banksCache = AsyncMemoizer<List<Bank>>();

  Future<List<Bank>> get fetchBanks => _banksCache.runOnce(() async {
        final response = await this
            ._httpService
            .dio
            .get(_bankEndpoint, queryParameters: {'json': '1'});

        var banks =
            (response.data as List).map((m) => Bank.fromJson(m)).toList();
        banks.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
        return banks;
      });
}
