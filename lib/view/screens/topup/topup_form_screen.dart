import 'package:dokandar/controller/topup_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/helper/price_converter.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/styles.dart';
import 'package:dokandar/util/topup_constants.dart';
import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/base/custom_button.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:dokandar/view/base/custom_text_field.dart';
import 'package:dokandar/view/base/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopupFormScreen extends StatefulWidget {
  final String type;
  final String operatorCode;

  const TopupFormScreen({Key? key, required this.type, required this.operatorCode}) : super(key: key);

  @override
  State<TopupFormScreen> createState() => _TopupFormScreenState();
}

class _TopupFormScreenState extends State<TopupFormScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _monthController = TextEditingController();
  final _noteController = TextEditingController();
  String _mobileType = 'prepaid';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TopupController>().resetForm();
      Get.find<TopupController>().setOperator(widget.operatorCode);
      if (widget.type == TopupConstants.tabDataPack) {
        Get.find<TopupController>().getDrives(type: 'drive');
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _accountController.dispose();
    _monthController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecharge = widget.type == TopupConstants.tabRecharge;
    final isDataPack = widget.type == TopupConstants.tabDataPack;
    final isBill = widget.type == TopupConstants.tabBill;
    final operatorName = _operatorName(widget.operatorCode, isBill);

    return Scaffold(
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        title: isRecharge
            ? 'mobile_recharge'.tr
            : isDataPack
                ? 'drive_pack'.tr
                : 'bill_payment'.tr,
      ),
      body: GetBuilder<TopupController>(builder: (topupController) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context, operatorName),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              if (isRecharge) ..._buildRechargeFields(topupController),
              if (isDataPack) ..._buildDataPackFields(topupController),
              if (isBill) ..._buildBillFields(topupController),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomButton(
                buttonText: isBill ? 'pay_bill'.tr : 'recharge_now'.tr,
                isLoading: topupController.isLoading,
                onPressed: () => _onSubmit(topupController),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(BuildContext context, String operatorName) {
    final walletBalance = Get.find<UserController>().userInfoModel?.walletBalance ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            operatorName,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            '${'available_balance'.tr}: ${PriceConverter.convertPrice(walletBalance)}',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRechargeFields(TopupController controller) {
    return [
      Text(
        'connection_type'.tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Row(
        children: [
          _typeChip('prepaid', 'prepaid'.tr),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          _typeChip('postpaid', 'postpaid'.tr),
        ],
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomTextField(
        titleText: 'mobile_number'.tr,
        hintText: 'enter_11_digit_mobile'.tr,
        showTitle: true,
        controller: _phoneController,
        inputType: TextInputType.phone,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomTextField(
        titleText: 'amount'.tr,
        hintText: 'enter_amount'.tr,
        showTitle: true,
        controller: _amountController,
        inputType: TextInputType.number,
        isAmount: true,
      ),
    ];
  }

  List<Widget> _buildDataPackFields(TopupController controller) {
    return [
      CustomTextField(
        titleText: 'mobile_number'.tr,
        hintText: 'enter_11_digit_mobile'.tr,
        showTitle: true,
        controller: _phoneController,
        inputType: TextInputType.phone,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      Text(
        'select_data_pack'.tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      if (controller.isLoading && controller.driveList.isEmpty)
        const Center(child: CircularProgressIndicator())
      else if (controller.driveList.isEmpty)
        Text(
          'no_data_packs_found'.tr,
          style: robotoRegular.copyWith(
            color: Theme.of(context).disabledColor,
          ),
        )
      else
        ...controller.driveList.map((drive) {
          final isSelected = controller.selectedDrive?.id == drive.id;
          return InkWell(
            onTap: () => controller.setSelectedDrive(drive),
            child: Container(
              margin: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drive.name ?? '',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        if (drive.description?.isNotEmpty ?? false)
                          Text(
                            drive.description!,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    PriceConverter.convertPrice((drive.amount ?? 0).toDouble()),
                    style: robotoBold.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
    ];
  }

  List<Widget> _buildBillFields(TopupController controller) {
    return [
      CustomTextField(
        titleText: 'account_number'.tr,
        hintText: 'biller_account_number'.tr,
        showTitle: true,
        controller: _accountController,
        inputType: TextInputType.text,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomTextField(
        titleText: 'contact_number'.tr,
        hintText: 'enter_contact_number'.tr,
        showTitle: true,
        controller: _phoneController,
        inputType: TextInputType.phone,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomTextField(
        titleText: 'billing_month'.tr,
        hintText: 'billing_month'.tr,
        showTitle: true,
        controller: _monthController,
        inputType: TextInputType.text,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomTextField(
        titleText: 'amount'.tr,
        hintText: 'enter_amount'.tr,
        showTitle: true,
        controller: _amountController,
        inputType: TextInputType.number,
        isAmount: true,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      CustomTextField(
        titleText: 'note'.tr,
        hintText: 'optional_note'.tr,
        showTitle: true,
        controller: _noteController,
        inputType: TextInputType.text,
        maxLines: 2,
      ),
    ];
  }

  Widget _typeChip(String value, String label) {
    final isSelected = _mobileType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _mobileType = value);
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: robotoMedium.copyWith(
        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );
  }

  Future<void> _onSubmit(TopupController controller) async {
    final isRecharge = widget.type == TopupConstants.tabRecharge;
    final isDataPack = widget.type == TopupConstants.tabDataPack;
    final isBill = widget.type == TopupConstants.tabBill;

    if (isRecharge) {
      final phone = _phoneController.text.trim();
      final amount = num.tryParse(_amountController.text.trim()) ?? 0;
      if (phone.length != 11 || !phone.startsWith('01')) {
        showCustomSnackBar('invalid_phone_number'.tr);
        return;
      }
      if (amount < 9) {
        showCustomSnackBar('minimum_amount_is_9'.tr);
        return;
      }
      controller.setType(_mobileType);
      final ok = await controller.recharge(number: phone, amount: amount);
      if (ok && mounted) Navigator.pop(context);
      return;
    }

    if (isDataPack) {
      final phone = _phoneController.text.trim();
      final drive = controller.selectedDrive;
      if (drive == null) {
        showCustomSnackBar('please_select_data_pack'.tr);
        return;
      }
      if (phone.length != 11 || !phone.startsWith('01')) {
        showCustomSnackBar('invalid_phone_number'.tr);
        return;
      }
      final ok = await controller.recharge(
        number: phone,
        amount: drive.amount ?? 0,
        packageId: drive.id,
      );
      if (ok && mounted) Navigator.pop(context);
      return;
    }

    if (isBill) {
      final account = _accountController.text.trim();
      final phone = _phoneController.text.trim();
      final month = _monthController.text.trim();
      final amount = num.tryParse(_amountController.text.trim()) ?? 0;
      final note = _noteController.text.trim();
      if (account.isEmpty || month.isEmpty || amount <= 0) {
        showCustomSnackBar('please_fill_required_fields'.tr);
        return;
      }
      if (phone.length != 11 || !phone.startsWith('01')) {
        showCustomSnackBar('invalid_phone_number'.tr);
        return;
      }
      final ok = await controller.payBill(
        billOperator: widget.operatorCode,
        billNumber: account,
        billAmount: amount,
        mobileNumber: phone,
        monthName: month,
        note: note.isNotEmpty ? note : null,
      );
      if (ok && mounted) Navigator.pop(context);
    }
  }

  String _operatorName(String code, bool isBill) {
    if (isBill) {
      final match = TopupConstants.billOperators.firstWhereOrNull(
        (b) => b['code'] == code,
      );
      return match?['name'] ?? code;
    }
    final match = TopupConstants.mobileOperators.firstWhereOrNull(
      (o) => o['code'] == code,
    );
    return match?['name'] ?? code;
  }
}
