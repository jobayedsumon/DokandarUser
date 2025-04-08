import 'package:dokandar/controller/auth_controller.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/controller/wishlist_controller.dart';
import 'package:dokandar/helper/date_converter.dart';
import 'package:dokandar/helper/price_converter.dart';
import 'package:dokandar/helper/responsive_helper.dart';
import 'package:dokandar/helper/route_helper.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/images.dart';
import 'package:dokandar/util/styles.dart';
import 'package:dokandar/view/base/confirmation_dialog.dart';
import 'package:dokandar/view/base/custom_image.dart';
import 'package:dokandar/view/screens/auth/sign_in_screen.dart';
import 'package:dokandar/view/screens/menu/widget/portion_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuScreenNew extends StatefulWidget {
  const MenuScreenNew({Key? key}) : super(key: key);

  @override
  State<MenuScreenNew> createState() => _MenuScreenNewState();
}

class _MenuScreenNewState extends State<MenuScreenNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<UserController>(builder: (userController) {
        final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

        return Column(children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtremeLarge,
                right: Dimensions.paddingSizeExtremeLarge,
                top: 50,
                bottom: Dimensions.paddingSizeExtremeLarge,
              ),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(1),
                  child: ClipOval(
                      child: CustomImage(
                    placeholder: Images.guestIconLight,
                    image:
                        '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                        '/${(userController.userInfoModel != null && isLoggedIn) ? userController.userInfoModel!.image : ''}',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  )),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn
                              ? '${userController.userInfoModel?.fName} ${userController.userInfoModel?.lName}'
                              : 'guest_user'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).cardColor),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        isLoggedIn
                            ? Text(
                                userController.userInfoModel != null
                                    ? DateConverter.containTAndZToUTCFormat(
                                        userController
                                            .userInfoModel!.createdAt!)
                                    : '',
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).cardColor),
                              )
                            : InkWell(
                                onTap: () async {
                                  if (!ResponsiveHelper.isDesktop(context)) {
                                    await Get.toNamed(
                                        RouteHelper.getSignInRoute(
                                            Get.currentRoute));
                                  } else {
                                    Get.dialog(const SignInScreen(
                                        exitFromApp: true, backFromThis: true));
                                  }
                                },
                                child: Text(
                                  'login_to_view_all_feature'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).cardColor),
                                ),
                              ),
                      ]),
                ),
              ]),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Ink(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Column(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'general'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.profileIcon,
                          title: 'profile'.tr,
                          route: RouteHelper.getProfileRoute()),
                      PortionWidget(
                          icon: Images.addressIcon,
                          title: 'my_address'.tr,
                          route: RouteHelper.getAddressRoute()),
                      PortionWidget(
                          icon: Images.languageIcon,
                          title: 'language'.tr,
                          hideDivider: true,
                          route: RouteHelper.getLanguageRoute('menu')),
                    ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'Investment'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                        icon: Images.walletIcon,
                        title: 'Investments'.tr,
                        route: RouteHelper.getInvestmentRoute(),
                      ),
                      PortionWidget(
                        icon: Images.walletIcon,
                        title: 'My Investments'.tr,
                        route: RouteHelper.getMyInvestmentRoute(),
                      ),
                    ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'promotional_activity'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                        icon: Images.couponIcon,
                        title: 'coupon'.tr,
                        route: RouteHelper.getCouponRoute(),
                        hideDivider: Get.find<SplashController>()
                                        .configModel!
                                        .loyaltyPointStatus ==
                                    1 ||
                                Get.find<SplashController>()
                                        .configModel!
                                        .customerWalletStatus ==
                                    1
                            ? false
                            : true,
                      ),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .loyaltyPointStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.pointIcon,
                              title: 'loyalty_points'.tr,
                              route: RouteHelper.getWalletRoute(false),
                              hideDivider: Get.find<SplashController>()
                                          .configModel!
                                          .customerWalletStatus ==
                                      1
                                  ? false
                                  : true,
                              suffix: !isLoggedIn
                                  ? null
                                  : '${userController.userInfoModel?.loyaltyPoint != null ? userController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .customerWalletStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.walletIcon,
                              title: 'my_wallet'.tr,
                              hideDivider: true,
                              route: RouteHelper.getWalletRoute(true),
                              suffix: !isLoggedIn
                                  ? null
                                  : PriceConverter.convertPrice(
                                      userController.userInfoModel != null
                                          ? userController
                                              .userInfoModel!.walletBalance
                                          : 0),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                (Get.find<SplashController>().configModel!.refEarningStatus ==
                            1) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleDmRegistration! &&
                            !ResponsiveHelper.isDesktop(context)) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleStoreRegistration! &&
                            !ResponsiveHelper.isDesktop(context))
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeDefault,
                                  right: Dimensions.paddingSizeDefault),
                              child: Text(
                                'earnings'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5)),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 800 : 200]!,
                                      spreadRadius: 1,
                                      blurRadius: 5)
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeDefault),
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              child: Column(children: [
                                (Get.find<SplashController>()
                                            .configModel!
                                            .refEarningStatus ==
                                        1)
                                    ? PortionWidget(
                                        icon: Images.referIcon,
                                        title: 'refer_and_earn'.tr,
                                        route:
                                            RouteHelper.getReferAndEarnRoute(),
                                        hideDivider: (Get.find<
                                                            SplashController>()
                                                        .configModel!
                                                        .toggleDmRegistration! &&
                                                    !ResponsiveHelper.isDesktop(
                                                        context)) ||
                                                (Get.find<SplashController>()
                                                        .configModel!
                                                        .toggleStoreRegistration! &&
                                                    !ResponsiveHelper.isDesktop(
                                                        context))
                                            ? false
                                            : true,
                                      )
                                    : const SizedBox(),
                                (Get.find<SplashController>()
                                            .configModel!
                                            .toggleDmRegistration! &&
                                        !ResponsiveHelper.isDesktop(context))
                                    ? PortionWidget(
                                        icon: Images.dmIcon,
                                        title: 'join_as_a_delivery_man'.tr,
                                        route: RouteHelper
                                            .getDeliverymanRegistrationRoute(),
                                        hideDivider: (Get.find<
                                                        SplashController>()
                                                    .configModel!
                                                    .toggleStoreRegistration! &&
                                                !ResponsiveHelper.isDesktop(
                                                    context))
                                            ? false
                                            : true,
                                      )
                                    : const SizedBox(),
                                (Get.find<SplashController>()
                                            .configModel!
                                            .toggleStoreRegistration! &&
                                        !ResponsiveHelper.isDesktop(context))
                                    ? PortionWidget(
                                        icon: Images.storeIcon,
                                        title: 'open_store'.tr,
                                        hideDivider: true,
                                        route: RouteHelper
                                            .getRestaurantRegistrationRoute(),
                                      )
                                    : const SizedBox(),
                              ]),
                            )
                          ])
                    : const SizedBox(),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault),
                    child: Text(
                      'help_and_support'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      PortionWidget(
                          icon: Images.chatIcon,
                          title: 'live_chat'.tr,
                          route: RouteHelper.getConversationRoute()),
                      PortionWidget(
                          icon: Images.helpIcon,
                          title: 'help_and_support'.tr,
                          route: RouteHelper.getSupportRoute()),
                      PortionWidget(
                          icon: Images.aboutIcon,
                          title: 'about_us'.tr,
                          route: RouteHelper.getHtmlRoute('about-us')),
                      PortionWidget(
                          icon: Images.termsIcon,
                          title: 'terms_conditions'.tr,
                          route:
                              RouteHelper.getHtmlRoute('terms-and-condition')),
                      PortionWidget(
                          icon: Images.privacyIcon,
                          title: 'privacy_policy'.tr,
                          route: RouteHelper.getHtmlRoute('privacy-policy')),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .refundPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.refundIcon,
                              title: 'refund_policy'.tr,
                              route: RouteHelper.getHtmlRoute('refund-policy'),
                              hideDivider: (Get.find<SplashController>()
                                              .configModel!
                                              .cancellationPolicyStatus ==
                                          1) ||
                                      (Get.find<SplashController>()
                                              .configModel!
                                              .shippingPolicyStatus ==
                                          1)
                                  ? false
                                  : true,
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .cancellationPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.cancelationIcon,
                              title: 'cancellation_policy'.tr,
                              route: RouteHelper.getHtmlRoute(
                                  'cancellation-policy'),
                              hideDivider: (Get.find<SplashController>()
                                          .configModel!
                                          .shippingPolicyStatus ==
                                      1)
                                  ? false
                                  : true,
                            )
                          : const SizedBox(),
                      (Get.find<SplashController>()
                                  .configModel!
                                  .shippingPolicyStatus ==
                              1)
                          ? PortionWidget(
                              icon: Images.shippingIcon,
                              title: 'shipping_policy'.tr,
                              hideDivider: true,
                              route:
                                  RouteHelper.getHtmlRoute('shipping-policy'),
                            )
                          : const SizedBox(),
                    ]),
                  )
                ]),
                InkWell(
                  onTap: () {
                    if (Get.find<AuthController>().isLoggedIn()) {
                      Get.dialog(
                          ConfirmationDialog(
                              icon: Images.support,
                              description: 'are_you_sure_to_logout'.tr,
                              isLogOut: true,
                              onYesPressed: () {
                                Get.find<UserController>().clearUserInfo();
                                Get.find<AuthController>().clearSharedData();
                                Get.find<AuthController>().socialLogout();
                                Get.find<WishListController>().removeWishes();
                                if (ResponsiveHelper.isDesktop(context)) {
                                  Get.offAllNamed(
                                      RouteHelper.getInitialRoute());
                                } else {
                                  Get.offAllNamed(RouteHelper.getSignInRoute(
                                      RouteHelper.splash));
                                }
                              }),
                          useSafeArea: false);
                    } else {
                      Get.find<WishListController>().removeWishes();
                      Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: Icon(Icons.power_settings_new_sharp,
                                size: 18, color: Theme.of(context).cardColor),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Text(
                              Get.find<AuthController>().isLoggedIn()
                                  ? 'logout'.tr
                                  : 'sign_in'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge))
                        ]),
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtremeLarge
                        : 100),
              ]),
            ),
          )),
        ]);
      }),
    );
  }
}
