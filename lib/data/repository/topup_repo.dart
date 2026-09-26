import 'package:dokandar/data/api/api_client.dart';
import 'package:dokandar/util/topup_constants.dart';
import 'package:get/get.dart';

class TopupRepo {
  final ApiClient apiClient;

  TopupRepo({required this.apiClient});

  Future<Response> recharge({
    required String number,
    required String type,
    required String operator,
    required num amount,
    String? packageId,
    required String trxid,
  }) async {
    final body = {
      'number': number,
      'type': type,
      'operator': operator,
      'amount': amount,
      'trxid': trxid,
    };
    if (packageId != null && packageId.isNotEmpty) {
      body['package_id'] = packageId;
    }
    return await apiClient.postData(TopupConstants.rechargeUri, body);
  }

  Future<Response> checkStatus({
    required String trxid,
  }) async {
    return await apiClient.postData(TopupConstants.statusUri, {
      'trxid': trxid,
    });
  }

  Future<Response> getDrives({
    String? operator,
    String? type,
  }) async {
    final body = <String, dynamic>{};
    if (operator != null && operator.isNotEmpty) {
      body['operator'] = operator;
    }
    if (type != null && type.isNotEmpty) {
      body['type'] = type;
    }
    return await apiClient.postData(TopupConstants.drivesUri, body);
  }

  Future<Response> getBalance() async {
    return await apiClient.getData(TopupConstants.balanceUri);
  }

  Future<Response> payBill({
    required String billOperator,
    required String billNumber,
    required num billAmount,
    required String mobileNumber,
    required String monthName,
    String? note,
    required String trxid,
  }) async {
    final body = {
      'billOperator': billOperator,
      'billNumber': billNumber,
      'billAmount': billAmount,
      'mobileNumber': mobileNumber,
      'monthName': monthName,
      'trxid': trxid,
    };
    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }
    return await apiClient.postData(TopupConstants.billPayUri, body);
  }
}
