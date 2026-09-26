import 'package:dokandar/data/api/topup_api_client.dart';
import 'package:dokandar/util/topup_constants.dart';
import 'package:get/get.dart';

class TopupRepo {
  final TopupApiClient apiClient;

  TopupRepo({required this.apiClient});

  String _key(String? configKey) =>
      (configKey?.isNotEmpty ?? false) ? configKey! : TopupConstants.fallbackKey;

  String _secret(String? configSecret) => (configSecret?.isNotEmpty ?? false)
      ? configSecret!
      : TopupConstants.fallbackSecret;

  Future<Response> recharge({
    required String number,
    required String type,
    required String operator,
    required num amount,
    String? packageId,
    required String trxid,
    required String key,
    required String secret,
  }) async {
    final body = {
      'number': number,
      'type': type,
      'operator': operator,
      'amount': amount,
      'trxid': trxid,
      'successtopup_key': _key(key),
      'successtopup_secret': _secret(secret),
    };
    if (packageId != null && packageId.isNotEmpty) {
      body['package_id'] = packageId;
    }
    return await apiClient.postData(TopupConstants.rechargeUri, body);
  }

  Future<Response> checkStatus({
    required String trxid,
    required String key,
    required String secret,
  }) async {
    return await apiClient.postData(TopupConstants.statusUri, {
      'trxid': trxid,
      'successtopup_key': _key(key),
      'successtopup_secret': _secret(secret),
    });
  }

  Future<Response> getDrives({
    String? operator,
    String? type,
    required String key,
    required String secret,
  }) async {
    final body = {
      'successtopup_key': _key(key),
      'successtopup_secret': _secret(secret),
    };
    if (operator != null && operator.isNotEmpty) {
      body['operator'] = operator;
    }
    if (type != null && type.isNotEmpty) {
      body['type'] = type;
    }
    return await apiClient.postData(TopupConstants.drivesUri, body);
  }

  Future<Response> getBalance({
    required String key,
    required String secret,
  }) async {
    return await apiClient.postData(TopupConstants.balanceUri, {
      'successtopup_key': _key(key),
      'successtopup_secret': _secret(secret),
    });
  }

  Future<Response> payBill({
    required String billOperator,
    required String billNumber,
    required num billAmount,
    required String mobileNumber,
    required String monthName,
    String? note,
    required String trxid,
    required String key,
    required String secret,
  }) async {
    final body = {
      'billOperator': billOperator,
      'billNumber': billNumber,
      'billAmount': billAmount,
      'mobileNumber': mobileNumber,
      'monthName': monthName,
      'trxid': trxid,
      'successtopup_key': _key(key),
      'successtopup_secret': _secret(secret),
    };
    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }
    return await apiClient.postData(TopupConstants.billPayUri, body);
  }
}
