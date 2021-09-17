import 'package:async/async.dart';
import 'package:nravepay/nravepay.dart';

import 'services.dart';

class BankService {
  static BankService get instance => ngetIt<BankService>();

  final HttpService _httpService;

  static final String _basePath = '/flwv3-pug/getpaidx/api';
  final String _bankEndpoint = '$_basePath/flwpbf-banks.js';

  BankService._(this._httpService);

  factory BankService() {
    return BankService._(HttpService.instance);
  }

  final _banksCache = AsyncMemoizer<List<Bank>>();

  Future<List<Bank>> get fetchBanks => _banksCache.runOnce(() async {
        final response = await _httpService.dio
            .get(_bankEndpoint, queryParameters: {'json': '1'});

        var banks =
            (response.data as List).map((m) => Bank.fromJson(m)).toList();
        banks.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
        return banks;
      });
}
