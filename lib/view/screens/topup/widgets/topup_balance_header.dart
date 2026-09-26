import 'package:dokandar/controller/topup_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/helper/price_converter.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopupBalanceHeader extends StatelessWidget {
  const TopupBalanceHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(builder: (userController) {
      final walletBalance = userController.userInfoModel?.walletBalance ?? 0;
      return GetBuilder<TopupController>(builder: (topupController) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'your_d_wallet_balance'.tr,
                style: robotoRegular.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                PriceConverter.convertPrice(walletBalance),
                style: robotoBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (topupController.topupBalance > 0)
                Text(
                  '${'topup_balance'.tr}: ${PriceConverter.convertPrice(topupController.topupBalance)}',
                  style: robotoRegular.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
            ],
          ),
        );
      });
    });
  }
}
