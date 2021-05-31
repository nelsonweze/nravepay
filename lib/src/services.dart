import 'dart:io';
import 'package:dio/dio.dart';
import 'payment.dart';
import 'util.payment.dart';
import 'package:async/async.dart';

class HttpService {
  static HttpService get instance => ngetIt<HttpService>();

  late Dio _dio;

  Dio get dio => _dio;

  HttpService._(PayInitializer init) {
    var staging = init.staging;
    var options = BaseOptions(
      baseUrl: staging
          ? "https://ravesandboxapi.flutterwave.com"
          : init.version == Version.v2
              ? "https://api.ravepay.co"
              : "https://api.flutterwave.com",
      responseType: ResponseType.json,
      connectTimeout: 60000,
      receiveTimeout: 60000,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: init.secKey
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

  factory HttpService(PayInitializer initializer) => HttpService._(initializer);
}

class TransactionService {
  static TransactionService get instance => ngetIt<TransactionService>();
  late final HttpService _httpService;

  static final String basePathV2 = "/flwv3-pug/getpaidx/api";
  static final String basePathV3 = "/v3";
  final String _chargeEndpointV2 = "$basePathV2/charge";
  final String _chargeEndpointV3 = "$basePathV3/charges?type=card";
  final String _chargeWithTokenEndpointV2 = "$basePathV2/tokenized-charges";
  final String _chargeWithTokenEndpointV3 = "$basePathV3/tokenized-charges";
  final String _validateChargeEndpointV2 = "$basePathV2/validatecharge";
  final String _validateChargeEndpointV3 = "$basePathV3/validate-charge";
  final _reQueryEndpointV2 = "$basePathV2/v2/verify";
  final _reQueryEndpointV3 = (int id) => "$basePathV3/transactions/$id/verify";

  Future<void> saveCardFunction(BankCard card) async {
    return null;
  }

  TransactionService._(this._httpService);

  factory TransactionService() {
    return TransactionService._(HttpService.instance);
  }

  Future<ChargeResponse> charge(Payload body) async {
    if (body.token != null)
      return chargeWithToken(body.withToken(), body.version);
    try {
      var _body = ChargeRequestBody.fromPayload(payload: body);
      final response = await this._httpService.dio.post(
          body.version == Version.v2 ? _chargeEndpointV2 : _chargeEndpointV3,
          data: _body.toJson());
      return ChargeResponse.fromJson(response.data, body.version);
    } on DioError catch (e) {
      print('charge ${e.message}');
      throw NRavePayException(data: e.response?.data);
    } catch (e) {
      print(e);
      throw NRavePayException();
    }
  }

  Future<ChargeResponse> chargeWithToken(Map body, Version version) async {
    try {
      final response = await this._httpService.dio.post(
          version == Version.v2
              ? _chargeWithTokenEndpointV2
              : _chargeWithTokenEndpointV3,
          data: body);
      return ChargeResponse.fromJson(response.data, version);
    } on DioError catch (e) {
      print('charge token ${e.message}');
      throw NRavePayException(data: e.response?.data);
    } catch (e) {
      print(e);
      throw NRavePayException();
    }
  }

  Future<ChargeResponse> validateCardCharge(
      ValidateChargeRequestBody body, Version version) async {
    try {
      final response = await this._httpService.dio.post(
          version == Version.v2
              ? _validateChargeEndpointV2
              : _validateChargeEndpointV3,
          data: body.toJson());
      return ChargeResponse.fromJson(response.data, version);
    } on DioError catch (e) {
      throw NRavePayException(data: e.response?.data);
    } catch (e) {
      throw NRavePayException();
    }
  }

  Future<ReQueryResponse> reQuery(int id, Map? body) async {
    print('requerying transaction');
    try {
      final response = body != null
          ? await this._httpService.dio.post(_reQueryEndpointV2, data: body)
          : await this._httpService.dio.get(_reQueryEndpointV3(id));
      print('requery resp ${response.statusMessage}');
      return ReQueryResponse.fromJson(response.data, body != null);
    } on DioError catch (e) {
      print(e);
      throw NRavePayException(data: e.response?.data);
    } catch (e) {
      print(e);
      throw NRavePayException();
    }
  }
}

class BankService {
  static BankService get instance => ngetIt<BankService>();

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
