import 'package:dio/dio.dart';
import 'package:nravepay/nravepay.dart';

class TransactionService {
  static TransactionService get instance => ngetIt<TransactionService>();

  final _httpService = HttpService.instance;

  static final String basePathV2 = '/flwv3-pug/getpaidx/api';
  static final String basePathV3 = '/v3';
  final String chargeEndpointV2 = '$basePathV2/charge';
  final String chargeEndpointV3 = '$basePathV3/charges?type=card';
  final String chargeWithTokenEndpointV2 = '$basePathV2/tokenized/charge';
  final String chargeWithTokenEndpointV3 = '$basePathV3/tokenized-charges';
  final String validateChargeEndpointV2 = '$basePathV2/validatecharge';
  final String validateChargeEndpointV3 = '$basePathV3/validate-charge';
  final _reQueryEndpointV2 = '$basePathV2/v2/verify';
  final _reQueryEndpointV3 = (int id) => '$basePathV3/transactions/$id/verify';

  Future<void> saveCardFunction(BankCard card) async {
    return null;
  }

  Future<ChargeResponse> charge(Payload body) async {
    if (body.token != null) {
      return chargeWithToken(body.withToken(), body.version);
    }
    try {
      var _body = ChargeRequestBody.fromPayload(payload: body);
      final response = await _httpService.dio.post(
          body.version == Version.v2 ? chargeEndpointV2 : chargeEndpointV3,
          data: _body.toJson());
      logger(response.data);
      return ChargeResponse.fromJson(response.data, body.version);
    } on DioError catch (e, s) {
      logger('charge ${e.response?.data}');
      throw NRavePayException(data: e.response?.data, stackTrace: s);
    } catch (e, s) {
      logger(e, stackTrace: s);
      throw NRavePayException(data: e, stackTrace: s);
    }
  }

  Future<ChargeResponse> chargeWithToken(Map body, Version version) async {
    try {
      final response = await _httpService.dio.post(
          version == Version.v2
              ? chargeWithTokenEndpointV2
              : chargeWithTokenEndpointV3,
          data: body);
      logger(response.data);
      return ChargeResponse.fromJson(response.data, version);
    } on DioError catch (e, s) {
      logger('charge token ${e.message}');
      throw NRavePayException(data: e.response?.data, stackTrace: s);
    } catch (e, s) {
      logger(e, stackTrace: s);
      throw NRavePayException(data: e, stackTrace: s);
    }
  }

  Future<ChargeResponse> validateCardCharge(
      ValidateChargeRequestBody body, Version version) async {
    try {
      logger('validating card charge');
      final response = await _httpService.dio.post(
          version == Version.v2
              ? validateChargeEndpointV2
              : validateChargeEndpointV3,
          data: body.toJson());
      logger(response.data);
      return ChargeResponse.fromJson(response.data, version);
    } on DioError catch (e, s) {
      logger(e, stackTrace: s);
      throw NRavePayException(data: e.response?.data, stackTrace: s);
    } catch (e, s) {
      logger(e, stackTrace: s);
      throw NRavePayException(data: e, stackTrace: s);
    }
  }

  Future<ReQueryResponse> reQuery(int id, Map? body) async {
    logger('requerying transaction');
    try {
      final response = body != null
          ? await _httpService.dio.post(_reQueryEndpointV2, data: body)
          : await _httpService.dio.get(_reQueryEndpointV3(id));
      logger('requery resp ${response.statusMessage}');
      return ReQueryResponse.fromJson(response.data, body != null);
    } on DioError catch (e, s) {
      logger(e, stackTrace: s);
      throw NRavePayException(data: e.response?.data, stackTrace: s);
    } catch (e, s) {
      logger(e, stackTrace: s);
      throw NRavePayException(data: e, stackTrace: s);
    }
  }
}
