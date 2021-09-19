import 'package:dio/dio.dart';
import 'package:nravepay/nravepay.dart';

class TransactionService {
  static TransactionService get instance => ngetIt<TransactionService>();

  final _httpService = HttpService.instance;

  static final String basePathV2 = '/flwv3-pug/getpaidx/api';
  static final String basePathV3 = '/v3';
  final String _chargeEndpointV2 = '$basePathV2/charge';
  final String _chargeEndpointV3 = '$basePathV3/charges?type=card';
  final String _chargeWithTokenEndpointV2 = '$basePathV2/tokenized/charge';
  final String _chargeWithTokenEndpointV3 = '$basePathV3/tokenized-charges';
  final String _validateChargeEndpointV2 = '$basePathV2/validatecharge';
  final String _validateChargeEndpointV3 = '$basePathV3/validate-charge';
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
      final response = await _httpService.dio.post(
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
      final response = await _httpService.dio.post(
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
    if (Setup.instance.staging) print('requerying transaction');
    try {
      final response = body != null
          ? await _httpService.dio.post(_reQueryEndpointV2, data: body)
          : await _httpService.dio.get(_reQueryEndpointV3(id));
      if (Setup.instance.staging)
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
