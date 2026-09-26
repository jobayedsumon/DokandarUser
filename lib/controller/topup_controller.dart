import 'dart:math';

import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/data/model/response/topup_models.dart';
import 'package:dokandar/data/api/api_checker.dart';
import 'package:dokandar/data/repository/topup_repo.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class TopupController extends GetxController implements GetxService {
  final TopupRepo topupRepo;

  TopupController({required this.topupRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DriveModel> _driveList = [];
  List<DriveModel> get driveList => _driveList;

  DriveModel? _selectedDrive;
  DriveModel? get selectedDrive => _selectedDrive;

  String _selectedOperator = '';
  String get selectedOperator => _selectedOperator;

  String _selectedType = 'prepaid';
  String get selectedType => _selectedType;

  double _topupBalance = 0;
  double get topupBalance => _topupBalance;

  String _lastTransactionId = '';
  String get lastTransactionId => _lastTransactionId;

  String _lastStatus = '';
  String get lastStatus => _lastStatus;

  void resetForm() {
    _selectedDrive = null;
    _selectedOperator = '';
    _selectedType = 'prepaid';
    update();
  }

  void setOperator(String code) {
    _selectedOperator = code;
    update();
  }

  void setType(String type) {
    _selectedType = type;
    update();
  }

  void setSelectedDrive(DriveModel? drive) {
    _selectedDrive = drive;
    update();
  }

  String _key() => Get.find<SplashController>().configModel?.successTopupKey ?? '';

  String _secret() =>
      Get.find<SplashController>().configModel?.successTopupSecret ?? '';

  bool get isEnabled =>
      (Get.find<SplashController>().configModel?.successTopupStatus ?? 0) == 1;

  bool _hasCredentials() {
    final key = _key();
    final secret = _secret();
    return key.isNotEmpty && secret.isNotEmpty;
  }

  String _generateTrxId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'TU-$ms-$rnd';
  }

  Future<bool> getDrives({String? operator, String? type}) async {
    if (!_hasCredentials()) {
      showCustomSnackBar('success_topup_credentials_not_configured'.tr);
      return false;
    }
    _isLoading = true;
    update();
    Response response = await topupRepo.getDrives(
      operator: operator ?? _selectedOperator,
      type: type,
      key: _key(),
      secret: _secret(),
    );
    _isLoading = false;
    if (response.statusCode == 200 && response.body != null) {
      _driveList = [];
      if (response.body['result'] == true && response.body['drives'] != null) {
        response.body['drives'].forEach((v) {
          _driveList.add(DriveModel.fromJson(v));
        });
      }
      update();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  Future<bool> getBalance() async {
    if (!_hasCredentials()) return false;
    _isLoading = true;
    update();
    Response response = await topupRepo.getBalance(
      key: _key(),
      secret: _secret(),
    );
    _isLoading = false;
    if (response.statusCode == 200 && response.body != null) {
      if (response.body['result'] == true) {
        _topupBalance =
            (response.body['balance'] ?? 0).toDouble();
      }
      update();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  Future<bool> recharge({
    required String number,
    required num amount,
    String? packageId,
  }) async {
    if (!_hasCredentials()) {
      showCustomSnackBar('success_topup_credentials_not_configured'.tr);
      return false;
    }
    if (_selectedOperator.isEmpty) {
      showCustomSnackBar('please_select_operator'.tr);
      return false;
    }

    final user = Get.find<UserController>().userInfoModel;
    final walletBalance = user?.walletBalance ?? 0;
    if (walletBalance < amount.toDouble()) {
      showCustomSnackBar('insufficient_wallet_balance'.tr);
      return false;
    }

    _isLoading = true;
    update();
    final trxid = _generateTrxId();
    _lastTransactionId = trxid;
    Response response = await topupRepo.recharge(
      number: number,
      type: _selectedType,
      operator: _selectedOperator,
      amount: amount,
      packageId: packageId,
      trxid: trxid,
      key: _key(),
      secret: _secret(),
    );
    _isLoading = false;
    update();

    if (response.statusCode == 200 && response.body != null) {
      if (response.body['result'] == true) {
        _lastStatus = response.body['message']?.toString() ?? 'Success';
        showCustomSnackBar(
            response.body['message']?.toString() ?? 'recharge_successful'.tr,
            isError: false);
        Get.find<UserController>().getUserInfo();
        return true;
      } else {
        showCustomSnackBar(
            response.body['message']?.toString() ?? 'recharge_failed'.tr);
        return false;
      }
    } else {
      ApiChecker.checkApi(response);
      return false;
    }
  }

  Future<bool> payBill({
    required String billOperator,
    required String billNumber,
    required num billAmount,
    required String mobileNumber,
    required String monthName,
    String? note,
  }) async {
    if (!_hasCredentials()) {
      showCustomSnackBar('success_topup_credentials_not_configured'.tr);
      return false;
    }

    final user = Get.find<UserController>().userInfoModel;
    final walletBalance = user?.walletBalance ?? 0;
    if (walletBalance < billAmount.toDouble()) {
      showCustomSnackBar('insufficient_wallet_balance'.tr);
      return false;
    }

    _isLoading = true;
    update();
    final trxid = _generateTrxId();
    _lastTransactionId = trxid;
    Response response = await topupRepo.payBill(
      billOperator: billOperator,
      billNumber: billNumber,
      billAmount: billAmount,
      mobileNumber: mobileNumber,
      monthName: monthName,
      note: note,
      trxid: trxid,
      key: _key(),
      secret: _secret(),
    );
    _isLoading = false;
    update();

    if (response.statusCode == 200 && response.body != null) {
      if (response.body['result'] == true) {
        _lastStatus = response.body['message']?.toString() ?? 'Success';
        showCustomSnackBar(
            response.body['message']?.toString() ?? 'bill_payment_successful'.tr,
            isError: false);
        Get.find<UserController>().getUserInfo();
        return true;
      } else {
        showCustomSnackBar(
            response.body['message']?.toString() ?? 'bill_payment_failed'.tr);
        return false;
      }
    } else {
      ApiChecker.checkApi(response);
      return false;
    }
  }

  Future<bool> checkStatus(String trxid) async {
    if (!_hasCredentials()) return false;
    _isLoading = true;
    update();
    Response response = await topupRepo.checkStatus(
      trxid: trxid,
      key: _key(),
      secret: _secret(),
    );
    _isLoading = false;
    if (response.statusCode == 200 && response.body != null) {
      _lastStatus = response.body['status']?.toString() ?? '';
      update();
      return response.body['result'] == true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }
}
