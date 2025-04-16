import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dokandar/controller/auth_controller.dart';
import 'package:dokandar/controller/localization_controller.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/data/model/body/store_body.dart';
import 'package:dokandar/data/model/body/translation.dart';
import 'package:dokandar/data/model/response/config_model.dart';
import 'package:dokandar/helper/responsive_helper.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/util/styles.dart';
import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/base/custom_button.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:dokandar/view/base/custom_text_field.dart';
import 'package:dokandar/view/base/footer_view.dart';
import 'package:dokandar/view/base/menu_drawer.dart';
import 'package:dokandar/view/base/web_page_title_widget.dart';
import 'package:dokandar/view/screens/auth/widget/custom_time_picker.dart';
import 'package:dokandar/view/screens/auth/widget/pass_view.dart';
import 'package:dokandar/view/screens/auth/widget/select_location_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<StoreRegistrationScreen> createState() =>
      _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _nameController = [];
  final List<TextEditingController> _addressController = [];
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final List<FocusNode> _nameFocus = [];
  final List<FocusNode> _addressFocus = [];
  final FocusNode _vatFocus = FocusNode();
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final List<Language>? _languageList =
      Get.find<SplashController>().configModel!.language;

  String? _countryDialCode;
  bool firstTime = true;
  TabController? _tabController;
  final List<Tab> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _languageList!.length, initialIndex: 0, vsync: this);
    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!)
        .dialCode;
    for (var language in _languageList!) {
      if (kDebugMode) {
        // print(language);
      }
      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _nameFocus.add(FocusNode());
      _addressFocus.add(FocusNode());
    }
    Get.find<AuthController>().storeStatusChange(0.4, isUpdate: false);
    Get.find<AuthController>().getZoneList();
    Get.find<AuthController>().selectModuleIndex(-1, canUpdate: false);

    for (var language in _languageList!) {
      _tabs.add(Tab(text: language.value));
    }

    if (Get.find<AuthController>().showPassView) {
      Get.find<AuthController>().showHidePass(isUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'store_registration'.tr,
          onBackPressed: () {
            if (Get.find<AuthController>().dmStatus == 0.4 && firstTime) {
              Get.find<AuthController>().storeStatusChange(0.4);
              firstTime = false;
            } else {
              Get.back();
            }
          }),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body:
          SafeArea(child: GetBuilder<AuthController>(builder: (authController) {
        if (authController.storeAddress != null && _languageList!.isNotEmpty) {
          _addressController[0].text = authController.storeAddress.toString();
        }

        return Column(children: [
          WebScreenTitleWidget(title: 'join_as_store'.tr),
          ResponsiveHelper.isDesktop(context)
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authController.storeStatus == 0.4
                              ? 'provide_store_information_to_proceed_next'.tr
                              : 'provide_owner_information_to_confirm'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        LinearProgressIndicator(
                          backgroundColor: Theme.of(context).disabledColor,
                          minHeight: 2,
                          value: authController.storeStatus,
                        ),
                      ]),
                ),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.isDesktop(context)
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: Dimensions.paddingSizeDefault),
              child: FooterView(
                child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: ResponsiveHelper.isDesktop(context)
                        ? webView(authController)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Visibility(
                                  visible: authController.storeStatus == 0.4,
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(
                                        flex: 4,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                  child: authController
                                                              .pickedLogo !=
                                                          null
                                                      ? GetPlatform.isWeb
                                                          ? Image.network(
                                                              authController
                                                                  .pickedLogo!
                                                                  .path,
                                                              width: 150,
                                                              height: 120,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.file(
                                                              File(authController
                                                                  .pickedLogo!
                                                                  .path),
                                                              width: 150,
                                                              height: 120,
                                                              fit: BoxFit.cover,
                                                            )
                                                      : SizedBox(
                                                          width: 150,
                                                          height: 120,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    size: 38,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor),
                                                                const SizedBox(
                                                                    height: Dimensions
                                                                        .paddingSizeSmall),
                                                                Text(
                                                                  'upload_store_logo'
                                                                      .tr,
                                                                  style: robotoMedium
                                                                      .copyWith(
                                                                          color:
                                                                              Theme.of(context).disabledColor),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ]),
                                                        ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                top: 0,
                                                left: 0,
                                                child: InkWell(
                                                  onTap: () => authController
                                                      .pickImage(true, false),
                                                  child: DottedBorder(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    strokeWidth: 1,
                                                    strokeCap: StrokeCap.butt,
                                                    dashPattern: const [5, 5],
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    borderType:
                                                        BorderType.RRect,
                                                    radius:
                                                        const Radius.circular(
                                                            Dimensions
                                                                .radiusDefault),
                                                    child: Center(
                                                      child: Visibility(
                                                        visible: authController
                                                                .pickedLogo !=
                                                            null,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(25),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 2,
                                                                color: Colors
                                                                    .white),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                              Icons.camera_alt,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ])),
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                      Expanded(
                                        flex: 6,
                                        child: Stack(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              child: authController
                                                          .pickedCover !=
                                                      null
                                                  ? GetPlatform.isWeb
                                                      ? Image.network(
                                                          authController
                                                              .pickedCover!
                                                              .path,
                                                          width: context.width,
                                                          height: 120,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.file(
                                                          File(authController
                                                              .pickedCover!
                                                              .path),
                                                          width: context.width,
                                                          height: 120,
                                                          fit: BoxFit.cover,
                                                        )
                                                  : SizedBox(
                                                      width: context.width,
                                                      height: 120,
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .camera_alt,
                                                                size: 38,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall),
                                                            Text(
                                                              'upload_store_cover'
                                                                  .tr,
                                                              style: robotoMedium.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ]),
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            top: 0,
                                            left: 0,
                                            child: InkWell(
                                              onTap: () => authController
                                                  .pickImage(false, false),
                                              child: DottedBorder(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                strokeWidth: 1,
                                                strokeCap: StrokeCap.butt,
                                                dashPattern: const [5, 5],
                                                padding:
                                                    const EdgeInsets.all(0),
                                                borderType: BorderType.RRect,
                                                radius: const Radius.circular(
                                                    Dimensions.radiusDefault),
                                                child: Center(
                                                  child: Visibility(
                                                    visible: authController
                                                            .pickedCover !=
                                                        null,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              25),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 3,
                                                            color:
                                                                Colors.white),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                          Icons.camera_alt,
                                                          color: Colors.white,
                                                          size: 50),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ]),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge),
                                    ListView.builder(
                                        itemCount: _languageList!.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions
                                                    .paddingSizeExtraLarge),
                                            child: CustomTextField(
                                              titleText:
                                                  '${'store_name'.tr} (${_languageList?[index].value!})',
                                              controller:
                                                  _nameController[index],
                                              focusNode: _nameFocus[index],
                                              nextFocus: index !=
                                                      _languageList!.length - 1
                                                  ? _nameFocus[index + 1]
                                                  : _addressFocus[0],
                                              inputType: TextInputType.name,
                                              capitalization:
                                                  TextCapitalization.words,
                                            ),
                                          );
                                        }),
                                    authController.zoneList != null
                                        ? const SelectLocationView(
                                            fromView: true)
                                        : const Center(
                                            child: CircularProgressIndicator()),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    ListView.builder(
                                        itemCount: _languageList?.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions
                                                    .paddingSizeExtraLarge),
                                            child: CustomTextField(
                                              titleText:
                                                  '${'store_address'.tr} (${_languageList?[index].value!})',
                                              controller:
                                                  _addressController[index],
                                              focusNode: _addressFocus[index],
                                              nextFocus: index !=
                                                      _languageList!.length - 1
                                                  ? _addressFocus[index + 1]
                                                  : _vatFocus,
                                              inputType: TextInputType.text,
                                              capitalization:
                                                  TextCapitalization.sentences,
                                              maxLines: 3,
                                            ),
                                          );
                                        }),
                                    CustomTextField(
                                      titleText: 'vat_tax'.tr,
                                      controller: _vatController,
                                      focusNode: _vatFocus,
                                      inputAction: TextInputAction.done,
                                      inputType: TextInputType.number,
                                      isAmount: true,
                                    ),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge),
                                    InkWell(
                                      onTap: () {
                                        Get.dialog(const CustomTimePicker());
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeLarge),
                                        child: Row(children: [
                                          Expanded(
                                              child: Text(
                                            '${authController.storeMinTime} : ${authController.storeMaxTime} ${authController.storeTimeUnit}',
                                            style: robotoMedium,
                                          )),
                                          Icon(
                                            Icons.access_time_filled,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )
                                        ]),
                                      ),
                                    )
                                  ]),
                                ),
                                Visibility(
                                  visible: authController.storeStatus != 0.4,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                              child: CustomTextField(
                                            titleText: 'first_name'.tr,
                                            controller: _fNameController,
                                            focusNode: _fNameFocus,
                                            nextFocus: _lNameFocus,
                                            inputType: TextInputType.name,
                                            capitalization:
                                                TextCapitalization.words,
                                          )),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Expanded(
                                              child: CustomTextField(
                                            titleText: 'last_name'.tr,
                                            controller: _lNameController,
                                            focusNode: _lNameFocus,
                                            nextFocus: _phoneFocus,
                                            inputType: TextInputType.name,
                                            capitalization:
                                                TextCapitalization.words,
                                          )),
                                        ]),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),
                                        CustomTextField(
                                          titleText: ResponsiveHelper.isDesktop(
                                                  context)
                                              ? 'phone'.tr
                                              : 'enter_phone_number'.tr,
                                          controller: _phoneController,
                                          focusNode: _phoneFocus,
                                          nextFocus: _emailFocus,
                                          inputType: TextInputType.phone,
                                          isPhone: true,
                                          showTitle: ResponsiveHelper.isDesktop(
                                              context),
                                          onCountryChanged:
                                              (CountryCode countryCode) {
                                            _countryDialCode =
                                                countryCode.dialCode;
                                          },
                                          countryDialCode: _countryDialCode !=
                                                  null
                                              ? CountryCode.fromCountryCode(
                                                      Get.find<
                                                              SplashController>()
                                                          .configModel!
                                                          .country!)
                                                  .code
                                              : Get.find<
                                                      LocalizationController>()
                                                  .locale
                                                  .countryCode,
                                        ),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),
                                        CustomTextField(
                                          titleText: 'email'.tr,
                                          controller: _emailController,
                                          focusNode: _emailFocus,
                                          nextFocus: _passwordFocus,
                                          inputType: TextInputType.emailAddress,
                                        ),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),
                                        CustomTextField(
                                          titleText: 'password'.tr,
                                          controller: _passwordController,
                                          focusNode: _passwordFocus,
                                          nextFocus: _confirmPasswordFocus,
                                          inputType:
                                              TextInputType.visiblePassword,
                                          isPassword: true,
                                          onChanged: (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              if (!authController
                                                  .showPassView) {
                                                authController.showHidePass();
                                              }
                                              authController
                                                  .validPassCheck(value);
                                            } else {
                                              if (authController.showPassView) {
                                                authController.showHidePass();
                                              }
                                            }
                                          },
                                        ),
                                        authController.showPassView
                                            ? const PassView()
                                            : const SizedBox(),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),
                                        CustomTextField(
                                          titleText: 'confirm_password'.tr,
                                          controller:
                                              _confirmPasswordController,
                                          focusNode: _confirmPasswordFocus,
                                          inputType:
                                              TextInputType.visiblePassword,
                                          inputAction: TextInputAction.done,
                                          isPassword: true,
                                        ),
                                      ]),
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                              ])),
              ),
            ),
          ),
          (ResponsiveHelper.isDesktop(context))
              ? const SizedBox()
              : buttonView(),
        ]);
      })),
    );
  }

  Widget webView(AuthController authController) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(children: [
            Container(
              height: 40,
              width: 500,
              color: Colors.transparent,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).disabledColor,
                unselectedLabelStyle: robotoRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontSize: Dimensions.fontSizeSmall),
                labelStyle: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor),
                labelPadding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.radiusDefault, vertical: 0),
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: _tabs,
                onTap: (int? value) {
                  setState(() {});
                },
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CustomTextField(
                      titleText:
                          '${'store_name'.tr} (${_languageList![_tabController!.index].value!})',
                      controller: _nameController[_tabController!.index],
                      focusNode: _nameFocus[_tabController!.index],
                      nextFocus:
                          _tabController!.index != _languageList!.length - 1
                              ? _addressFocus[_tabController!.index]
                              : _addressFocus[0],
                      inputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                      showTitle: true,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextField(
                      titleText:
                          '${'store_address'.tr} (${_languageList?[_tabController!.index].value!})',
                      controller: _addressController[_tabController!.index],
                      focusNode: _addressFocus[_tabController!.index],
                      nextFocus:
                          _tabController!.index != _languageList!.length - 1
                              ? _addressFocus[_tabController!.index + 1]
                              : _vatFocus,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      showTitle: ResponsiveHelper.isDesktop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    authController.zoneList != null
                        ? const SelectLocationView(
                            fromView: true, mapView: true)
                        : const Center(child: CircularProgressIndicator()),
                  ],
                ),
              )
            ],
          ),
          // const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.person),
            Text('general_information'.tr,
                style:
                    robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))
          ]),
          const Divider(),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(
                child: Column(children: [
              Row(children: [
                Expanded(
                    child: CustomTextField(
                  titleText: 'vat_tax'.tr,
                  controller: _vatController,
                  focusNode: _vatFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.number,
                  isAmount: true,
                  showTitle: true,
                )),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('delivery_time'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      InkWell(
                        onTap: () {
                          Get.dialog(const CustomTimePicker());
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge),
                          child: Row(children: [
                            Expanded(
                                child: Text(
                              '${authController.storeMinTime} : ${authController.storeMaxTime} ${authController.storeTimeUnit}',
                              style: robotoMedium,
                            )),
                            Icon(
                              Icons.access_time_filled,
                              color: Theme.of(context).primaryColor,
                            )
                          ]),
                        ),
                      ),
                    ])),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              authController.zoneList != null
                  ? const SelectLocationView(
                      fromView: true, zoneModuleView: true)
                  : const Center(child: CircularProgressIndicator()),
            ])),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Expanded(
                      flex: 4,
                      child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                Text('logo'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeExtraSmall)),
                                Text(' (1:1)',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).primaryColor))
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Stack(children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    child: authController.pickedLogo != null
                                        ? GetPlatform.isWeb
                                            ? Image.network(
                                                authController.pickedLogo!.path,
                                                width: 150,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(authController
                                                    .pickedLogo!.path),
                                                width: 150,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                        : SizedBox(
                                            width: 150,
                                            height: 120,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.camera_alt,
                                                      size: 38,
                                                      color: Theme.of(context)
                                                          .disabledColor),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                    'upload_store_logo'.tr,
                                                    style:
                                                        robotoMedium.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ]),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () =>
                                        authController.pickImage(true, false),
                                    child: DottedBorder(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(
                                          Dimensions.radiusDefault),
                                      child: Center(
                                        child: Visibility(
                                          visible:
                                              authController.pickedLogo != null,
                                          child: Container(
                                            padding: const EdgeInsets.all(25),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2,
                                                  color: Colors.white),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.camera_alt,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ])
                            ],
                          ))),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('cover_image'.tr,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall)),
                            Text(' (2:1)',
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).primaryColor))
                          ]),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                child: authController.pickedCover != null
                                    ? GetPlatform.isWeb
                                        ? Image.network(
                                            authController.pickedCover!.path,
                                            width: context.width,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(authController
                                                .pickedCover!.path),
                                            width: context.width,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                    : SizedBox(
                                        width: context.width,
                                        height: 120,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt,
                                                  size: 38,
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              Text(
                                                'upload_store_cover'.tr,
                                                style: robotoMedium.copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor),
                                                textAlign: TextAlign.center,
                                              ),
                                            ]),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              top: 0,
                              left: 0,
                              child: InkWell(
                                onTap: () =>
                                    authController.pickImage(false, false),
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.butt,
                                  dashPattern: const [5, 5],
                                  padding: const EdgeInsets.all(0),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(
                                      Dimensions.radiusDefault),
                                  child: Center(
                                    child: Visibility(
                                      visible:
                                          authController.pickedCover != null,
                                      child: Container(
                                        padding: const EdgeInsets.all(25),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 3, color: Colors.white),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white, size: 50),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ])
                        ],
                      )),
                ])),
          ]),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.person),
            Text('owner_information'.tr,
                style:
                    robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))
          ]),
          const Divider(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(children: [
            Expanded(
                child: CustomTextField(
              titleText: 'first_name'.tr,
              controller: _fNameController,
              focusNode: _fNameFocus,
              nextFocus: _lNameFocus,
              inputType: TextInputType.name,
              capitalization: TextCapitalization.words,
              showTitle: ResponsiveHelper.isDesktop(context),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
                child: CustomTextField(
              titleText: 'last_name'.tr,
              controller: _lNameController,
              focusNode: _lNameFocus,
              nextFocus: _phoneFocus,
              inputType: TextInputType.name,
              capitalization: TextCapitalization.words,
              showTitle: ResponsiveHelper.isDesktop(context),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: CustomTextField(
                titleText: 'phone'.tr,
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _emailFocus,
                inputType: TextInputType.phone,
                isPhone: true,
                showTitle: ResponsiveHelper.isDesktop(context),
                onCountryChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                },
                countryDialCode: _countryDialCode != null
                    ? CountryCode.fromCountryCode(
                            Get.find<SplashController>().configModel!.country!)
                        .code
                    : Get.find<LocalizationController>().locale.countryCode,
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.lock),
            Text('login_info'.tr,
                style:
                    robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))
          ]),
          const Divider(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: CustomTextField(
                titleText: 'email'.tr,
                controller: _emailController,
                focusNode: _emailFocus,
                nextFocus: _passwordFocus,
                inputType: TextInputType.emailAddress,
                showTitle: ResponsiveHelper.isDesktop(context),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                children: [
                  CustomTextField(
                    titleText: 'password'.tr,
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    nextFocus: _confirmPasswordFocus,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!authController.showPassView) {
                          authController.showHidePass();
                        }
                        authController.validPassCheck(value);
                      } else {
                        if (authController.showPassView) {
                          authController.showHidePass();
                        }
                      }
                    },
                    showTitle: ResponsiveHelper.isDesktop(context),
                  ),
                  authController.showPassView
                      ? const PassView()
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
                child: CustomTextField(
              titleText: 'confirm_password'.tr,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              inputType: TextInputType.visiblePassword,
              inputAction: TextInputAction.done,
              isPassword: true,
              showTitle: ResponsiveHelper.isDesktop(context),
            )),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Theme.of(context).hintColor)),
          width: 165,
          child: CustomButton(
            transparent: true,
            textColor: Theme.of(context).hintColor,
            radius: Dimensions.radiusSmall,
            onPressed: () {
              _phoneController.text = '';
              _emailController.text = '';
              _fNameController.text = '';
              _lNameController.text = '';
              _lNameController.text = '';
              _vatController.text = '';
              _passwordController.text = '';
              _confirmPasswordController.text = '';
              for (int i = 0; i < _nameController.length; i++) {
                _nameController[i].text = '';
              }
              for (int i = 0; i < _addressController.length; i++) {
                _addressController[i].text = '';
              }
              authController.resetStoreRegistration();

              //userController.initData(isUpdate: true);
            },
            buttonText: 'reset'.tr,
            isBold: false,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeLarge),
        SizedBox(width: 165, child: buttonView()),
      ])
    ]);
  }

  Widget buttonView() {
    return GetBuilder<AuthController>(builder: (authController) {
      return CustomButton(
        isBold: ResponsiveHelper.isDesktop(context) ? false : true,
        radius: ResponsiveHelper.isDesktop(context)
            ? Dimensions.radiusSmall
            : Dimensions.radiusDefault,
        isLoading: authController.isLoading,
        margin: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
            ? 0
            : Dimensions.paddingSizeSmall),
        buttonText: authController.storeStatus == 0.4 &&
                !ResponsiveHelper.isDesktop(context)
            ? 'next'.tr
            : 'submit'.tr,
        onPressed: () {
          bool defaultDataNull = false;
          for (int index = 0; index < _languageList!.length; index++) {
            if (_languageList?[index].key == 'en') {
              if (_nameController[index].text.trim().isEmpty ||
                  _addressController[index].text.trim().isEmpty) {
                defaultDataNull = true;
              }
              break;
            }
          }
          String vat = _vatController.text.trim();
          String minTime = authController.storeMinTime;
          String maxTime = authController.storeMaxTime;
          String fName = _fNameController.text.trim();
          String lName = _lNameController.text.trim();
          String phone = _phoneController.text.trim();
          String email = _emailController.text.trim();
          String password = _passwordController.text.trim();
          String confirmPassword = _confirmPasswordController.text.trim();
          bool valid = false;
          try {
            double.parse(maxTime);
            double.parse(minTime);
            valid = true;
          } on FormatException {
            valid = false;
          }

          if (authController.storeStatus == 0.4 &&
              !ResponsiveHelper.isDesktop(context)) {
            if (authController.pickedLogo == null) {
              showCustomSnackBar('select_store_logo'.tr);
            } else if (authController.pickedCover == null) {
              showCustomSnackBar('select_store_cover_photo'.tr);
            } else if (defaultDataNull) {
              showCustomSnackBar('enter_store_name'.tr);
            } else if (authController.selectedModuleIndex == -1) {
              showCustomSnackBar('please_select_module_first'.tr);
            } else if (authController.selectedZoneIndex == -1) {
              showCustomSnackBar('please_select_zone'.tr);
            }
            /*else if(address.isEmpty) {
              showCustomSnackBar('enter_store_address'.tr);
            }*/
            else if (vat.isEmpty) {
              showCustomSnackBar('enter_vat_amount'.tr);
            } else if (minTime.isEmpty) {
              showCustomSnackBar('enter_minimum_delivery_time'.tr);
            } else if (maxTime.isEmpty) {
              showCustomSnackBar('enter_maximum_delivery_time'.tr);
            } else if (!valid) {
              showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
            } else if (valid && double.parse(minTime) > double.parse(maxTime)) {
              showCustomSnackBar(
                  'maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'
                      .tr);
            } else if (authController.restaurantLocation == null) {
              showCustomSnackBar('set_store_location'.tr);
            } else {
              authController.storeStatusChange(0.8);
              firstTime = true;
            }
          } else {
            if (ResponsiveHelper.isDesktop(context)) {
              if (defaultDataNull) {
                showCustomSnackBar('enter_store_name'.tr);
              }
              /*else if(address.isEmpty) {
                showCustomSnackBar('enter_store_address'.tr);
              }*/
              else if (vat.isEmpty) {
                showCustomSnackBar('enter_vat_amount'.tr);
              } else if (minTime.isEmpty) {
                showCustomSnackBar('enter_minimum_delivery_time'.tr);
              } else if (maxTime.isEmpty) {
                showCustomSnackBar('enter_maximum_delivery_time'.tr);
              } else if (!valid) {
                showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
              } else if (valid &&
                  double.parse(minTime) > double.parse(maxTime)) {
                showCustomSnackBar(
                    'maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'
                        .tr);
              } else if (authController.pickedLogo == null) {
                showCustomSnackBar('select_store_logo'.tr);
              } else if (authController.pickedCover == null) {
                showCustomSnackBar('select_store_cover_photo'.tr);
              } else if (authController.restaurantLocation == null) {
                showCustomSnackBar('set_store_location'.tr);
              }
            }
            if (fName.isEmpty) {
              showCustomSnackBar('enter_your_first_name'.tr);
            } else if (lName.isEmpty) {
              showCustomSnackBar('enter_your_last_name'.tr);
            } else if (phone.isEmpty) {
              showCustomSnackBar('enter_phone_number'.tr);
            } else if (email.isEmpty) {
              showCustomSnackBar('enter_email_address'.tr);
            } else if (!GetUtils.isEmail(email)) {
              showCustomSnackBar('enter_a_valid_email_address'.tr);
            } else if (password.isEmpty) {
              showCustomSnackBar('enter_password'.tr);
            } else if (password.length < 6) {
              showCustomSnackBar('password_should_be'.tr);
            } else if (password != confirmPassword) {
              showCustomSnackBar('confirm_password_does_not_matched'.tr);
            } else {
              List<Translation> translation = [];
              for (int index = 0; index < _languageList!.length; index++) {
                translation.add(Translation(
                  locale: _languageList?[index].key,
                  key: 'name',
                  value: _nameController[index].text.trim().isNotEmpty
                      ? _nameController[index].text.trim()
                      : _nameController[0].text.trim(),
                ));
                translation.add(Translation(
                  locale: _languageList?[index].key,
                  key: 'address',
                  value: _addressController[index].text.trim().isNotEmpty
                      ? _addressController[index].text.trim()
                      : _addressController[0].text.trim(),
                ));
              }

              authController.registerStore(StoreBody(
                translation: jsonEncode(translation),
                tax: vat,
                minDeliveryTime: minTime,
                maxDeliveryTime: maxTime,
                lat: authController.restaurantLocation!.latitude.toString(),
                email: email,
                lng: authController.restaurantLocation!.longitude.toString(),
                fName: fName,
                lName: lName,
                phone: _countryDialCode! + phone,
                password: password,
                zoneId: authController
                    .zoneList![authController.selectedZoneIndex!].id
                    .toString(),
                moduleId: authController
                    .moduleList![authController.selectedModuleIndex!].id
                    .toString(),
                deliveryTimeType: authController.storeTimeUnit,
              ));
            }
          }
        },
      );
    });
  }
}
