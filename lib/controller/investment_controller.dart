import 'package:dokandar/data/api/api_checker.dart';
import 'package:dokandar/view/screens/checkout/investment_payment_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

import '../data/model/response/investment_model.dart';
import '../data/repository/investment_repo.dart';
import '../helper/route_helper.dart';

class InvestmentController extends GetxController implements GetxService {
  final InvestmentRepo investmentRepo;

  final List<String> withdrawalMethodList = ['bkash', 'nagad', 'bank'];

  InvestmentController({required this.investmentRepo});

  PaginatedInvestmentModel? _flexibleInvestmentModel;
  PaginatedInvestmentModel? _lockedInInvestmentModel;
  PaginatedMyInvestmentModel? _myInvestmentModel;
  MyInvestmentModel? _myInvestmentDetailsModel;
  PaginatedWithdrawalModel? _withdrawalModel;
  InvestmentWalletModel? _investmentWalletModel;
  InvestmentModel? _investmentModel;
  String? _digitalPaymentName;
  String? _withdrawalMethod = 'bkash';

  PaginatedInvestmentModel? get flexibleInvestmentModel =>
      _flexibleInvestmentModel;

  PaginatedInvestmentModel? get lockedInInvestmentModel =>
      _lockedInInvestmentModel;

  PaginatedMyInvestmentModel? get myInvestmentModel => _myInvestmentModel;

  MyInvestmentModel? get myInvestmentDetailsModel => _myInvestmentDetailsModel;

  PaginatedWithdrawalModel? get withdrawalModel => _withdrawalModel;

  InvestmentWalletModel? get investmentWalletModel => _investmentWalletModel;

  InvestmentModel? get investmentModel => _investmentModel;

  String? get digitalPaymentName => _digitalPaymentName;

  String? get withdrawalMethod => _withdrawalMethod;

  TextEditingController withdrawalAmountController = TextEditingController();
  TextEditingController withdrawalMobileNumberController =
      TextEditingController();
  TextEditingController withdrawalAccountNumberController =
      TextEditingController();
  TextEditingController withdrawalAccountNameController =
      TextEditingController();
  TextEditingController withdrawalBankNameController = TextEditingController();
  TextEditingController withdrawalBranchNameController =
      TextEditingController();
  TextEditingController withdrawalRoutingNumberController =
      TextEditingController();

  TextEditingController transferAmountController = TextEditingController();

  Future<void> getFlexiblePackages(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _flexibleInvestmentModel = null;
      if (isUpdate) {
        update();
      }
    }
    Response response = await investmentRepo.getFlexiblePackageList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _flexibleInvestmentModel =
            PaginatedInvestmentModel.fromJson(response.body);
      } else {
        _flexibleInvestmentModel!.packages!
            .addAll(PaginatedInvestmentModel.fromJson(response.body).packages!);
        _flexibleInvestmentModel!.offset =
            PaginatedInvestmentModel.fromJson(response.body).offset;
        _flexibleInvestmentModel!.totalSize =
            PaginatedInvestmentModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getLockedInPackages(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _lockedInInvestmentModel = null;
      if (isUpdate) {
        update();
      }
    }
    Response response = await investmentRepo.getLockedInPackageList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _lockedInInvestmentModel =
            PaginatedInvestmentModel.fromJson(response.body);
      } else {
        _lockedInInvestmentModel!.packages!
            .addAll(PaginatedInvestmentModel.fromJson(response.body).packages!);
        _lockedInInvestmentModel!.offset =
            PaginatedInvestmentModel.fromJson(response.body).offset;
        _lockedInInvestmentModel!.totalSize =
            PaginatedInvestmentModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<InvestmentModel> getInvestmentPackageDetails(int packageId) async {
    Response response = await investmentRepo.getInvestmentPackage(packageId);
    if (response.statusCode == 200) {
      _investmentModel = InvestmentModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return _investmentModel!;
  }

  Future<MyInvestmentModel> getMyInvestmentPackageDetails(int packageId) async {
    Response response = await investmentRepo.getMyInvestmentPackage(packageId);
    if (response.statusCode == 200) {
      _myInvestmentDetailsModel = MyInvestmentModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return _myInvestmentDetailsModel!;
  }

  Future<void> investInPackage(int packageId, String paymentMethod) async {
    update();
    Response response = await investmentRepo.investInPackage(
      {'package_id': packageId, 'payment_method': paymentMethod},
    );
    if (response.statusCode == 200) {
      String redirectUrl = response.body['redirect_link'];
      Get.back();
      if (redirectUrl == '') {
        Get.snackbar('Success', 'Investment successful',
            snackPosition: SnackPosition.BOTTOM);
        getMyInvestment(1);
        return;
      }
      if (GetPlatform.isWeb) {
        String? hostname = html.window.location.hostname;
        String protocol = html.window.location.protocol;
        redirectUrl +=
            '&callback=$protocol//$hostname${RouteHelper.investmentAfterPayment}&status=';
        html.window.open(redirectUrl, "_blank");
      } else {
        // Get.toNamed(RouteHelper.getPaymentRoute('0', 0, '', 0, false, '',
        //     investmentPaymentUrl: redirectUrl, guestId: ''));
        // await launchUrlString(redirectUrl);
        Get.to(InvestmentPaymentWebView(investmentPaymentUrl: redirectUrl));
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void changeDigitalPaymentName(String name, {bool isUpdate = true}) {
    _digitalPaymentName = name;
    if (isUpdate) {
      update();
    }
  }

  void changeWithdrawalMethod(String name, {bool isUpdate = true}) {
    _withdrawalMethod = name;
    if (isUpdate) {
      update();
    }
  }

  Future<void> getMyInvestment(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _myInvestmentModel = null;
      if (isUpdate) {
        update();
      }
    }
    Response response = await investmentRepo.getMyInvestment(offset);
    if (response.statusCode == 200) {
      var investments = response.body['investments'];
      var withdrawals = response.body['withdrawals'];
      var investmentWallets = response.body['investment_wallet'];

      if (offset == 1) {
        _myInvestmentModel = PaginatedMyInvestmentModel.fromJson(investments);
        _withdrawalModel = PaginatedWithdrawalModel.fromJson(withdrawals);
        _investmentWalletModel =
            InvestmentWalletModel.fromJson(investmentWallets);
      } else {
        _myInvestmentModel!.investments!.addAll(
            PaginatedMyInvestmentModel.fromJson(investments).investments!);
        _myInvestmentModel!.offset =
            PaginatedMyInvestmentModel.fromJson(investments).offset;
        _myInvestmentModel!.totalSize =
            PaginatedMyInvestmentModel.fromJson(investments).totalSize;

        _withdrawalModel!.withdrawals!.addAll(
            PaginatedWithdrawalModel.fromJson(withdrawals).withdrawals!);
        _withdrawalModel!.offset =
            PaginatedWithdrawalModel.fromJson(withdrawals).offset;
        _withdrawalModel!.totalSize =
            PaginatedWithdrawalModel.fromJson(withdrawals).totalSize;

        _investmentWalletModel =
            InvestmentWalletModel.fromJson(investmentWallets);
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> redeemInvestment(int investmentId) async {
    Response response = await investmentRepo.redeemInvestment(investmentId);
    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Investment redeemed successfully',
          snackPosition: SnackPosition.BOTTOM);
      myInvestmentDetailsModel!.redeemedAt = response.body['redeemed_at'];
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> sendWithdrawRequest() async {
    Map<String, dynamic> data = {
      'withdrawal_amount': withdrawalAmountController.text,
      'method_type': withdrawalMethod,
    };
    if (withdrawalMethod == 'bank') {
      if (withdrawalAccountNumberController.text.isEmpty &&
          withdrawalBankNameController.text.isEmpty) {
        Get.snackbar('Error', 'Account number and bank name is required',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      data['account_number'] = withdrawalAccountNumberController.text;
      data['account_name'] = withdrawalAccountNameController.text;
      data['bank_name'] = withdrawalBankNameController.text;
      data['branch_name'] = withdrawalBranchNameController.text;
      data['routing_number'] = withdrawalRoutingNumberController.text;
    } else {
      if (withdrawalMobileNumberController.text.isEmpty) {
        Get.snackbar('Error', 'Mobile number is required',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      data['mobile_number'] = withdrawalMobileNumberController.text;
    }
    Response response = await investmentRepo.sendWithdrawRequest(data);
    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success',
          'Withdrawal request sent successfully. You can check the transaction on your wallet transaction history.',
          snackPosition: SnackPosition.BOTTOM);
      withdrawalAmountController.clear();
      withdrawalMobileNumberController.clear();
      withdrawalAccountNumberController.clear();
      withdrawalAccountNameController.clear();
      withdrawalBankNameController.clear();
      withdrawalBranchNameController.clear();
      withdrawalRoutingNumberController.clear();
      getMyInvestment(1);
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> transferToDWallet() async {
    Map<String, dynamic> data = {
      'amount': transferAmountController.text,
    };
    Response response = await investmentRepo.transferToDWallet(data);
    if (response.statusCode == 200) {
      Get.back();
      Get.snackbar('Success', 'Transferred successfully',
          snackPosition: SnackPosition.BOTTOM);
      transferAmountController.clear();
      getMyInvestment(1);
    } else {
      ApiChecker.checkApi(response);
    }
  }
}
