import 'package:async/async.dart';
import 'package:nravepay/nravepay.dart';

class BankService {
  static BankService get instance => ngetIt<BankService>();

  final HttpService _httpService;
  String _bankEndpoint(String country) => '/v2/banks/$country';

  BankService._(this._httpService);

  factory BankService() {
    return BankService._(HttpService.instance);
  }

  final _banksCache = AsyncMemoizer<List<Bank>>();

  ///Fetches the list of banks with thier codes
  Future<List<Bank>> get fetchBanks => _banksCache.runOnce(() async {
        final response = await _httpService.dio.get(
            _bankEndpoint(NRavePayRepository.instance.initializer.country),
            queryParameters: {'public_key': Setup.instance.publicKey});
        if (response.statusCode == 200) {
          var banks = (List.from(response.data['data']['Banks']))
              .map((m) => Bank.fromJson(m))
              .toList();
          banks.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
          return banks;
        }
        return [];
      });

  /// Creates a subaccount with the given [data] and returns
  /// the subaccount Id if successful
  Future<String?> registerSubAccount(Merchant data) async {
    try {
      var endPoint = Setup.instance.version == Version.v2
          ? '/v2/gpx/subaccounts/create'
          : 'v3/subaccounts';
      final response =
          await HttpService().dio.post(endPoint, data: data.toMap());

      if (response.statusCode == 200) {
        return response.data['data']['subaccount_id'];
      }
      return null;
    } catch (e) {
      throw NRavePayException(data: e.toString());
    }
  }
}
