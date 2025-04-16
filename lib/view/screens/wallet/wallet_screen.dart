import 'package:dokandar/controller/auth_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/controller/wallet_controller.dart';
import 'package:dokandar/helper/responsive_helper.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/styles.dart';
import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/base/footer_view.dart';
import 'package:dokandar/view/base/menu_drawer.dart';
import 'package:dokandar/view/base/not_logged_in_screen.dart';
import 'package:dokandar/view/base/web_page_title_widget.dart';
import 'package:dokandar/view/screens/wallet/widget/bonus_banner.dart';
import 'package:dokandar/view/screens/wallet/widget/wallet_bottom_sheet.dart';
import 'package:dokandar/view/screens/wallet/widget/wallet_card_widget.dart';
import 'package:dokandar/view/screens/wallet/widget/wallet_history_widget.dart';
import 'package:dokandar/view/screens/wallet/widget/web_bonus_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WalletScreen extends StatefulWidget {
  final bool fromWallet;
  final String? fundStatus;
  final String? token;

  const WalletScreen(
      {Key? key, required this.fromWallet, this.fundStatus, this.token})
      : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<WalletController>().insertFilterList();
      Get.find<WalletController>().setWalletFilerType('all', isUpdate: false);

      if ((widget.fundStatus == 'success' ||
              widget.fundStatus == 'fail' ||
              widget.fundStatus == 'cancel') &&
          Get.find<WalletController>().getWalletAccessToken() != widget.token) {
        if (widget.fundStatus == 'success') {
          Get.find<UserController>().getUserInfo();
          Get.find<WalletController>()
              .getWalletTransactionList('1', true, widget.fromWallet, 'all');
        }

        Future.delayed(const Duration(seconds: 2), () {
          Get.showSnackbar(GetSnackBar(
            backgroundColor:
                widget.fundStatus == 'success' ? Colors.green : Colors.red,
            message: widget.fundStatus == 'success'
                ? 'fund_successfully_added_to_wallet'.tr
                : 'fund_not_added_to_wallet'.tr,
            maxWidth: 500,
            duration: const Duration(seconds: 3),
            snackStyle: SnackStyle.FLOATING,
            margin: const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
            borderRadius: Dimensions.radiusExtraLarge,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
          ));
        }).then((value) {
          Get.find<WalletController>().setWalletAccessToken(widget.token ?? '');
        });
      }

      Get.find<UserController>().getUserInfo();
      if (widget.fromWallet) {
        Get.find<WalletController>().getWalletBonusList(isUpdate: false);
      }
      Get.find<WalletController>().getWalletTransactionList(
          '1', false, widget.fromWallet, Get.find<WalletController>().type);
      Get.find<WalletController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            Get.find<WalletController>().transactionList != null &&
            !Get.find<WalletController>().isLoading) {
          int pageSize =
              (Get.find<WalletController>().popularPageSize! / 10).ceil();
          if (Get.find<WalletController>().offset < pageSize) {
            Get.find<WalletController>()
                .setOffset(Get.find<WalletController>().offset + 1);
            if (kDebugMode) {
              // print('end of the page');
            }
            Get.find<WalletController>().showBottomLoader();
            Get.find<WalletController>().getWalletTransactionList(
                Get.find<WalletController>().offset.toString(),
                false,
                widget.fromWallet,
                Get.find<WalletController>().type);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
          title: widget.fromWallet ? 'wallet'.tr : 'loyalty_points'.tr,
          backButton: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoggedIn &&
              !ResponsiveHelper.isDesktop(context) &&
              !widget.fromWallet
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              label: Text('convert_to_wallet_money'.tr,
                  style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault)),
              onPressed: () {
                Get.dialog(
                  Dialog(
                      backgroundColor: Colors.transparent,
                      child: WalletBottomSheet(
                        fromWallet: widget.fromWallet,
                        amount: Get.find<UserController>()
                                    .userInfoModel!
                                    .loyaltyPoint ==
                                null
                            ? '0'
                            : Get.find<UserController>()
                                .userInfoModel!
                                .loyaltyPoint
                                .toString(),
                      )),
                );
              },
            )
          : null,
      body: GetBuilder<UserController>(builder: (userController) {
        return isLoggedIn
            ? userController.userInfoModel != null
                ? SafeArea(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        Get.find<WalletController>().setWalletFilerType('all');
                        Get.find<WalletController>().getWalletTransactionList(
                            '1', true, widget.fromWallet, 'all');
                        Get.find<UserController>().getUserInfo();
                      },
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            WebScreenTitleWidget(
                                title: widget.fromWallet
                                    ? 'wallet'.tr
                                    : 'loyalty_points'.tr),
                            FooterView(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: GetBuilder<WalletController>(
                                    builder: (walletController) {
                                  return ResponsiveHelper.isDesktop(context)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: Dimensions
                                                  .paddingSizeDefault),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    flex: 4,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            decoration: ResponsiveHelper
                                                                    .isDesktop(
                                                                        context)
                                                                ? BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusSmall),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .black12,
                                                                          blurRadius:
                                                                              5,
                                                                          spreadRadius:
                                                                              1)
                                                                    ],
                                                                  )
                                                                : null,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeLarge),
                                                            child: WalletCardWidget(
                                                                fromWallet: widget
                                                                    .fromWallet,
                                                                tooltipController:
                                                                    tooltipController)),
                                                      ],
                                                    )),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeDefault),
                                                Expanded(
                                                    flex: 6,
                                                    child: Column(
                                                      children: [
                                                        widget.fromWallet
                                                            ? const WebBonusBannerView()
                                                            : const SizedBox(),
                                                        Container(
                                                            decoration: ResponsiveHelper
                                                                    .isDesktop(
                                                                        context)
                                                                ? BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusSmall),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .black12,
                                                                          blurRadius:
                                                                              5,
                                                                          spreadRadius:
                                                                              1)
                                                                    ],
                                                                  )
                                                                : null,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeLarge),
                                                            child: WalletHistoryWidget(
                                                                fromWallet: widget
                                                                    .fromWallet))
                                                      ],
                                                    )),
                                              ]),
                                        )
                                      : Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeLarge),
                                            child: WalletCardWidget(
                                                fromWallet: widget.fromWallet,
                                                tooltipController:
                                                    tooltipController),
                                          ),
                                          widget.fromWallet
                                              ? const BonusBanner()
                                              : const SizedBox(),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeLarge),
                                            child: WalletHistoryWidget(
                                                fromWallet: widget.fromWallet),
                                          )
                                        ]);
                                }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator())
            : NotLoggedInScreen(callBack: (value) {
                initCall();
                setState(() {});
              });
      }),
    );
  }
}

class WalletShimmer extends StatelessWidget {
  final WalletController walletController;

  const WalletShimmer({Key? key, required this.walletController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.1,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding:
          EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 10,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 10),
                          Container(
                              height: 10,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              height: 10,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 10),
                          Container(
                              height: 10,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2))),
                        ]),
                  ],
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: Divider(color: Theme.of(context).disabledColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}
