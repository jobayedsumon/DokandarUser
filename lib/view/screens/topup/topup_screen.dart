import 'package:dokandar/controller/auth_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/helper/route_helper.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/styles.dart';
import 'package:dokandar/util/topup_constants.dart';
import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/base/footer_view.dart';
import 'package:dokandar/view/base/menu_drawer.dart';
import 'package:dokandar/view/base/not_logged_in_screen.dart';
import 'package:dokandar/view/base/web_page_title_widget.dart';
import 'package:dokandar/view/screens/topup/widgets/topup_balance_header.dart';
import 'package:dokandar/view/screens/topup/widgets/topup_service_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({Key? key}) : super(key: key);

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _init();
  }

  void _init() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'topup_services'.tr),
      body: isLoggedIn
          ? Column(
              children: [
                const TopupBalanceHeader(),
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).disabledColor,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(text: 'mobile_recharge'.tr),
                    Tab(text: 'drive_pack'.tr),
                    Tab(text: 'bill_payment'.tr),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRechargeTab(),
                      _buildDataPackTab(),
                      _buildBillTab(),
                    ],
                  ),
                ),
              ],
            )
          : NotLoggedInScreen(callBack: (value) {
              _init();
              setState(() {});
            }),
    );
  }

  Widget _buildRechargeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: FooterView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),
            WebScreenTitleWidget(title: 'mobile_recharge'.tr),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'select_operator'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...TopupConstants.mobileOperators.map((op) {
              return TopupServiceTile(
                icon: Icons.phone_android,
                title: op['name']!,
                subtitle: op['code']!,
                onTap: () {
                  Get.toNamed(RouteHelper.getTopupFormRoute(
                    TopupConstants.tabRecharge,
                    op['code']!,
                  ));
                },
                hideDivider: op == TopupConstants.mobileOperators.last,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: FooterView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),
            WebScreenTitleWidget(title: 'drive_pack'.tr),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'select_operator_for_data_pack'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...TopupConstants.mobileOperators.map((op) {
              return TopupServiceTile(
                icon: Icons.signal_cellular_alt,
                title: op['name']!,
                subtitle: op['code']!,
                onTap: () {
                  Get.toNamed(RouteHelper.getTopupFormRoute(
                    TopupConstants.tabDataPack,
                    op['code']!,
                  ));
                },
                hideDivider: op == TopupConstants.mobileOperators.last,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: FooterView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),
            WebScreenTitleWidget(title: 'bill_payment'.tr),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'select_biller'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...TopupConstants.billOperators.map((bill) {
              return TopupServiceTile(
                icon: _billIcon(bill['type']),
                title: bill['name']!,
                subtitle: bill['type']!,
                onTap: () {
                  Get.toNamed(RouteHelper.getTopupFormRoute(
                    TopupConstants.tabBill,
                    bill['code']!,
                  ));
                },
                hideDivider: bill == TopupConstants.billOperators.last,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _billIcon(String? type) {
    switch (type) {
      case 'electricity':
        return Icons.electrical_services;
      case 'gas':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.receipt_long;
    }
  }
}
