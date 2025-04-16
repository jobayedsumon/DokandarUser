import 'package:country_code_picker/country_code_picker.dart';
import 'package:dokandar/controller/auth_controller.dart';
import 'package:dokandar/controller/cart_controller.dart';
import 'package:dokandar/controller/coupon_controller.dart';
import 'package:dokandar/controller/localization_controller.dart';
import 'package:dokandar/controller/parcel_controller.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/controller/store_controller.dart';
import 'package:dokandar/controller/user_controller.dart';
import 'package:dokandar/data/api/api_checker.dart';
import 'package:dokandar/data/api/api_client.dart';
import 'package:dokandar/data/model/body/place_order_body.dart';
import 'package:dokandar/data/model/response/address_model.dart';
import 'package:dokandar/data/model/response/distance_model.dart';
import 'package:dokandar/data/model/response/offline_method_model.dart';
import 'package:dokandar/data/model/response/order_cancellation_body.dart';
import 'package:dokandar/data/model/response/order_details_model.dart';
import 'package:dokandar/data/model/response/order_model.dart';
import 'package:dokandar/data/model/response/refund_model.dart';
import 'package:dokandar/data/model/response/response_model.dart';
import 'package:dokandar/data/model/response/store_model.dart';
import 'package:dokandar/data/model/response/timeslote_model.dart';
import 'package:dokandar/data/repository/order_repo.dart';
import 'package:dokandar/helper/date_converter.dart';
import 'package:dokandar/helper/network_info.dart';
import 'package:dokandar/helper/price_converter.dart';
import 'package:dokandar/helper/responsive_helper.dart';
import 'package:dokandar/helper/route_helper.dart';
import 'package:dokandar/util/app_constants.dart';
import 'package:dokandar/view/base/custom_snackbar.dart';
import 'package:dokandar/view/screens/checkout/widget/order_successfull_dialog.dart';
import 'package:dokandar/view/screens/checkout/widget/partial_pay_dialog.dart';
import 'package:dokandar/view/screens/home/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class OrderController extends GetxController implements GetxService {
  final OrderRepo orderRepo;

  OrderController({required this.orderRepo});

  PaginatedOrderModel? _runningOrderModel;
  PaginatedOrderModel? _historyOrderModel;
  List<OrderDetailsModel>? _orderDetails;
  int _paymentMethodIndex = -1;
  OrderModel? _trackModel;
  ResponseModel? _responseModel;
  bool _isLoading = false;
  bool _showCancelled = false;
  String? _orderType = 'delivery';
  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? _allTimeSlots;
  int _selectedDateSlot = 0;
  int _selectedTimeSlot = 0;
  double? _distance;
  int? _addressIndex = 0;
  XFile? _orderAttachment;
  Uint8List? _rawAttachment;
  double _tips = 0.0;
  int _selectedTips = 0;
  bool _canShowTipsField = false;
  bool _showBottomSheet = true;
  bool _showOneOrder = true;
  List<String?>? _refundReasons;
  int _selectedReasonIndex = 0;
  XFile? _refundImage;
  bool _acceptTerms = true;
  double? _extraCharge;
  String? _cancelReason;
  List<CancellationData>? _orderCancelReasons;
  bool _isDmTipSave = false;
  String _preferableTime = '';
  int _selectedInstruction = -1;
  bool _isExpanded = false;
  bool _isPartialPay = false;
  final TextEditingController couponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController tipController = TextEditingController();
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  bool _isExpand = false;
  int? _mostDmTipAmount;
  String? _digitalPaymentName;
  double _viewTotalPrice = 0;
  AddressModel? _guestAddress;
  List<OfflineMethodModel>? _offlineMethodList;
  int _selectedOfflineBankIndex = 0;
  List<TextEditingController> informationControllerList = [];
  List<FocusNode> informationFocusList = [];
  String? countryDialCode =
      Get.find<AuthController>().getUserCountryCode().isNotEmpty
          ? Get.find<AuthController>().getUserCountryCode()
          : CountryCode.fromCountryCode(
                      Get.find<SplashController>().configModel!.country!)
                  .dialCode ??
              Get.find<LocalizationController>().locale.countryCode;

  PaginatedOrderModel? get runningOrderModel => _runningOrderModel;

  PaginatedOrderModel? get historyOrderModel => _historyOrderModel;

  List<OrderDetailsModel>? get orderDetails => _orderDetails;

  int get paymentMethodIndex => _paymentMethodIndex;

  OrderModel? get trackModel => _trackModel;

  ResponseModel? get responseModel => _responseModel;

  bool get isLoading => _isLoading;

  bool get showCancelled => _showCancelled;

  String? get orderType => _orderType;

  List<TimeSlotModel>? get timeSlots => _timeSlots;

  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;

  int get selectedDateSlot => _selectedDateSlot;

  int get selectedTimeSlot => _selectedTimeSlot;

  double? get distance => _distance;

  int? get addressIndex => _addressIndex;

  XFile? get orderAttachment => _orderAttachment;

  Uint8List? get rawAttachment => _rawAttachment;

  double get tips => _tips;

  int get selectedTips => _selectedTips;

  bool get showBottomSheet => _showBottomSheet;

  bool get showOneOrder => _showOneOrder;

  int get selectedReasonIndex => _selectedReasonIndex;

  XFile? get refundImage => _refundImage;

  List<String?>? get refundReasons => _refundReasons;

  bool get acceptTerms => _acceptTerms;

  double? get extraCharge => _extraCharge;

  String? get cancelReason => _cancelReason;

  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;

  bool get isDmTipSave => _isDmTipSave;

  String get preferableTime => _preferableTime;

  int get selectedInstruction => _selectedInstruction;

  bool get isExpanded => _isExpanded;

  bool get canShowTipsField => _canShowTipsField;

  bool get isPartialPay => _isPartialPay;

  bool get isExpand => _isExpand;

  int? get mostDmTipAmount => _mostDmTipAmount;

  String? get digitalPaymentName => _digitalPaymentName;

  double? get viewTotalPrice => _viewTotalPrice;

  AddressModel? get guestAddress => _guestAddress;

  List<OfflineMethodModel>? get offlineMethodList => _offlineMethodList;

  int get selectedOfflineBankIndex => _selectedOfflineBankIndex;

  void selectOfflineBank(int index, {bool canUpdate = true}) {
    _selectedOfflineBankIndex = index;
    if (canUpdate) {
      update();
    }
  }

  void setTotalAmount(double amount) {
    _viewTotalPrice = amount;
  }

  void setGuestAddress(AddressModel? address, {bool isUpdate = true}) {
    _guestAddress = address;
    if (isUpdate) {
      update();
    }
  }

  void changeDigitalPaymentName(String name) {
    _digitalPaymentName = name;
    update();
  }

  void changePartialPayment({bool isUpdate = true}) {
    _isPartialPay = !_isPartialPay;
    if (isUpdate) {
      update();
    }
  }

  void showTipsField() {
    _canShowTipsField = !_canShowTipsField;
    update();
  }

  void setInstruction(int index) {
    if (_selectedInstruction == index) {
      _selectedInstruction = -1;
    } else {
      _selectedInstruction = index;
    }
    update();
  }

  void expandedUpdate(bool status) {
    _isExpanded = status;
    update();
  }

  void setPreferenceTimeForView(String time, {bool isUpdate = true}) {
    _preferableTime = time;
    if (isUpdate) {
      update();
    }
  }

  Future<void> getOfflineMethodList() async {
    Response response = await orderRepo.getOfflineMethodList();
    if (response.statusCode == 200) {
      _offlineMethodList = [];

      response.body?.forEach((method) =>
          _offlineMethodList!.add(OfflineMethodModel.fromJson(method)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void changesMethod({bool canUpdate = true}) {
    List<MethodInformations>? methodInformation =
        offlineMethodList![selectedOfflineBankIndex].methodInformations!;

    informationControllerList = [];
    informationFocusList = [];

    for (int index = 0; index < methodInformation.length; index++) {
      informationControllerList.add(TextEditingController());
      informationFocusList.add(FocusNode());
    }
    if (canUpdate) {
      update();
    }
  }

  Future<double?> applyPromoCode(dynamic value, double price, double discount,
      double addOns, double deliveryCharge, double totalPrice) async {
    if (value != null) {
      couponController.text = value.toString();
    }
    if (couponController.text.isNotEmpty) {
      if (Get.find<CouponController>().discount! < 1 &&
          !Get.find<CouponController>().freeDelivery) {
        if (couponController.text.isNotEmpty &&
            !Get.find<CouponController>().isLoading) {
          Get.find<CouponController>()
              .applyCoupon(couponController.text, (price - discount) + addOns,
                  deliveryCharge, Get.find<StoreController>().store!.id)
              .then((discount) {
            if (discount! > 0) {
              couponController.text = 'coupon_applied'.tr;
              showCustomSnackBar(
                '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                isError: false,
              );
              // print('==s=fff=== > ${Get.find<CouponController>().discount!}');
              // await canApplyPartialPay(totalPrice, discount);
            }
          });
        } else if (couponController.text.isEmpty) {
          showCustomSnackBar('enter_a_coupon_code'.tr);
        }
      } else {
        Get.find<CouponController>().removeCouponData(true);
        couponController.text = '';
      }
    }
    return 1;
  }

  Future<bool> checkBalanceStatus(double totalPrice, double discount) async {
    totalPrice = (totalPrice - discount);
    if (Get.find<OrderController>().isPartialPay) {
      Get.find<OrderController>().changePartialPayment();
    }
    Get.find<OrderController>().setPaymentMethod(-1);
    if ((Get.find<UserController>().userInfoModel!.walletBalance! <
            totalPrice) &&
        (Get.find<UserController>().userInfoModel!.walletBalance! != 0.0)) {
      Get.dialog(
        PartialPayDialog(isPartialPay: true, totalPrice: totalPrice),
        useSafeArea: false,
      );
    } else {
      Get.dialog(
        PartialPayDialog(isPartialPay: false, totalPrice: totalPrice),
        useSafeArea: false,
      );
    }
    update();
    return true;
  }

  Future<void> getOrderCancelReasons() async {
    Response response = await orderRepo.getCancelReasons();
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody =
          OrderCancellationBody.fromJson(response.body);
      _orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        _orderCancelReasons!.add(element);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setOrderCancelReason(String? reason) {
    _cancelReason = reason;
    update();
  }

  Future<double?> getExtraCharge(double? distance) async {
    _extraCharge = null;
    Response response = await orderRepo.getExtraCharge(distance);
    if (response.statusCode == 200) {
      _extraCharge = double.parse(response.body.toString());
    } else {
      _extraCharge = 0;
    }
    return _extraCharge;
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void selectReason(int index, {bool isUpdate = true}) {
    _selectedReasonIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void showOrders() {
    _showOneOrder = !_showOneOrder;
    update();
  }

  void showRunningOrders({bool canUpdate = true}) {
    _showBottomSheet = !_showBottomSheet;
    if (canUpdate) {
      update();
    }
  }

  void pickRefundImage(bool isRemove) async {
    if (isRemove) {
      _refundImage = null;
    } else {
      _refundImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      update();
    }
  }

  // Future<void> pickPrescriptionImage(bool isCamera) async {
  //   _prescriptionImage = await ImagePicker().pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 50);
  //   if(_prescriptionImage != null) {
  //     _prescriptionImage = await NetworkInfo.compressImage(_prescriptionImage);
  //     _rawPrescription = await _prescriptionImage.readAsBytes();
  //   }
  //   update();print("update - 1");
  // }

  Future<void> getRefundReasons() async {
    _selectedReasonIndex = 0;
    Response response = await orderRepo.getRefundReasons();
    if (response.statusCode == 200) {
      RefundModel refundModel = RefundModel.fromJson(response.body);
      _refundReasons = [];
      _refundReasons!.insert(0, 'select_an_option');
      for (var element in refundModel.refundReasons!) {
        _refundReasons!.add(element.reason);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getDmTipMostTapped() async {
    _mostDmTipAmount = 0;
    Response response = await orderRepo.getDmTipMostTapped();
    if (response.statusCode == 200) {
      _mostDmTipAmount = response.body['most_tips_amount'];
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> submitRefundRequest(String note, String? orderId) async {
    if (_selectedReasonIndex == 0) {
      showCustomSnackBar('please_select_reason'.tr);
    } else {
      _isLoading = true;
      update();
      Map<String, String> body = {};
      body.addAll(<String, String>{
        'customer_reason': _refundReasons![selectedReasonIndex]!,
        'order_id': orderId!,
        'customer_note': note,
      });
      Response response =
          await orderRepo.submitRefundRequest(body, _refundImage);
      if (response.statusCode == 200) {
        showCustomSnackBar(response.body['message'], isError: false);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      } else {
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }
  }

  Future<void> getRunningOrders(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _runningOrderModel = null;
      if (isUpdate) {
        update();
      }
    }
    Response response = await orderRepo.getRunningOrderList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _runningOrderModel = PaginatedOrderModel.fromJson(response.body);
      } else {
        _runningOrderModel!.orders!
            .addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _runningOrderModel!.offset =
            PaginatedOrderModel.fromJson(response.body).offset;
        _runningOrderModel!.totalSize =
            PaginatedOrderModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getHistoryOrders(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _historyOrderModel = null;
      if (isUpdate) {
        update();
      }
    }
    Response response = await orderRepo.getHistoryOrderList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _historyOrderModel = PaginatedOrderModel.fromJson(response.body);
      } else {
        _historyOrderModel!.orders!
            .addAll(PaginatedOrderModel.fromJson(response.body).orders!);
        _historyOrderModel!.offset =
            PaginatedOrderModel.fromJson(response.body).offset;
        _historyOrderModel!.totalSize =
            PaginatedOrderModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;

    if (_trackModel == null ||
        (_trackModel!.orderType != 'parcel' &&
            !_trackModel!.prescriptionOrder!)) {
      Response response = await orderRepo.getOrderDetails(
          orderID,
          Get.find<AuthController>().isLoggedIn()
              ? null
              : Get.find<AuthController>().getGuestId());
      _isLoading = false;
      if (response.statusCode == 200) {
        _orderDetails = [];
        response.body.forEach((orderDetail) =>
            _orderDetails!.add(OrderDetailsModel.fromJson(orderDetail)));
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      _isLoading = false;
      _orderDetails = [];
    }
    update();
    return _orderDetails;
  }

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if (isUpdate) {
      update();
    }
  }

  Future<void> addTips(double tips) async {
    _tips = tips;
    update();
  }

  Future<ResponseModel?> trackOrder(
      String? orderID, OrderModel? orderModel, bool fromTracking,
      {String? contactNumber, bool? fromGuestInput = false}) async {
    _trackModel = null;
    _responseModel = null;
    if (!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if (orderModel == null) {
      _isLoading = true;
      // if(contactNumber != null && fromGuestInput!) {
      //   update();
      // }
      Response response = await orderRepo.trackOrder(
        orderID,
        Get.find<AuthController>().isLoggedIn()
            ? null
            : Get.find<AuthController>().getGuestId(),
        contactNumber: contactNumber,
      );
      if (response.statusCode == 200) {
        _trackModel = OrderModel.fromJson(response.body);
        _responseModel = ResponseModel(true, response.body.toString());
      } else {
        _responseModel = ResponseModel(false, response.statusText);
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    } else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
    }
    return _responseModel;
  }

  Future<ResponseModel?> timerTrackOrder(String orderID,
      {String? contactNumber}) async {
    _showCancelled = false;

    Response response = await orderRepo.trackOrder(
      orderID,
      Get.find<AuthController>().isLoggedIn()
          ? null
          : Get.find<AuthController>().getGuestId(),
      contactNumber: contactNumber,
    );
    if (response.statusCode == 200) {
      _trackModel = OrderModel.fromJson(response.body);
      _responseModel = ResponseModel(true, response.body.toString());
    } else {
      _responseModel = ResponseModel(false, response.statusText);
      ApiChecker.checkApi(response);
    }
    update();

    return _responseModel;
  }

  Future<String> placeOrder(
      PlaceOrderBody placeOrderBody,
      int? zoneID,
      double amount,
      double? maximumCodOrderAmount,
      bool fromCart,
      bool isCashOnDeliveryActive,
      {bool forParcel = false,
      bool isOfflinePay = false}) async {
    _isLoading = true;
    update();
    String orderID = '';
    Response response =
        await orderRepo.placeOrder(placeOrderBody, _orderAttachment);
    _isLoading = false;
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      orderID = response.body['order_id'].toString();
      if (!isOfflinePay) {
        if (forParcel) {
          parcelCallback(
              true,
              message,
              orderID,
              zoneID,
              amount,
              maximumCodOrderAmount,
              isCashOnDeliveryActive,
              placeOrderBody.contactPersonNumber);
        } else {
          callback(
              true,
              message,
              orderID,
              zoneID,
              amount,
              maximumCodOrderAmount,
              fromCart,
              isCashOnDeliveryActive,
              placeOrderBody.contactPersonNumber!);
        }
      } else {
        Get.find<CartController>().getCartDataOnline();
      }
      _orderAttachment = null;
      _rawAttachment = null;
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      if (!isOfflinePay) {
        if (forParcel) {
          parcelCallback(
              false,
              response.statusText,
              '-1',
              zoneID,
              amount,
              maximumCodOrderAmount,
              isCashOnDeliveryActive,
              placeOrderBody.contactPersonNumber);
        } else {
          callback(
              false,
              response.statusText,
              '-1',
              zoneID,
              amount,
              maximumCodOrderAmount,
              fromCart,
              isCashOnDeliveryActive,
              placeOrderBody.contactPersonNumber);
        }
      } else {
        showCustomSnackBar(response.statusText);
      }
    }
    update();

    return orderID;
  }

  Future<void> parcelCallback(
    bool isSuccess,
    String? message,
    String orderID,
    int? zoneID,
    double orderAmount,
    double? maxCodAmount,
    bool isCashOnDeliveryActive,
    String? contactNumber,
  ) async {
    Get.find<ParcelController>().startLoader(false);
    if (isSuccess) {
      if (Get.find<OrderController>().isDmTipSave) {
        Get.find<AuthController>().saveDmTipIndex(
            Get.find<OrderController>().selectedTips.toString());
      }
      Get.find<OrderController>().setGuestAddress(null);
      if (Get.find<ParcelController>().paymentIndex == 2) {
        if (GetPlatform.isWeb) {
          // Get.back();
          await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          // print('===customer id: ${Get.find<UserController>().userInfoModel?.id} /// guest id: ${Get.find<AuthController>().getGuestId()}');
          String selectedUrl =
              '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<UserController>().userInfoModel?.id ?? Get.find<AuthController>().getGuestId()}'
              '&payment_method=${Get.find<ParcelController>().digitalPaymentName}&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl, "_self");
        } else {
          Get.offNamed(RouteHelper.getPaymentRoute(
            orderID,
            Get.find<UserController>().userInfoModel?.id ?? 0,
            'parcel',
            orderAmount,
            isCashOnDeliveryActive,
            Get.find<ParcelController>().digitalPaymentName,
            guestId: Get.find<AuthController>().getGuestId(),
            contactNumber: contactNumber,
          ));
        }
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
      }
      Get.find<OrderController>().updateTips(0, notify: false);
    } else {
      showCustomSnackBar(message);
    }
  }

  void callback(
    bool isSuccess,
    String? message,
    String orderID,
    int? zoneID,
    double amount,
    double? maximumCodOrderAmount,
    bool fromCart,
    bool isCashOnDeliveryActive,
    String? contactNumber,
  ) async {
    if (isSuccess) {
      if (fromCart) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<OrderController>().setGuestAddress(null);
      if (!Get.find<OrderController>().showBottomSheet) {
        Get.find<OrderController>().showRunningOrders(canUpdate: false);
      }
      if (Get.find<OrderController>().isDmTipSave) {
        Get.find<AuthController>().saveDmTipIndex(
            Get.find<OrderController>().selectedTips.toString());
      }
      Get.find<OrderController>().stopLoader(canUpdate: false);
      HomeScreen.loadData(true);
      if (Get.find<OrderController>().paymentMethodIndex == 2) {
        if (GetPlatform.isWeb) {
          // Get.back();
          await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl;
          // print('===customer id: ${Get.find<UserController>().userInfoModel?.id} /// guest id: ${Get.find<AuthController>().getGuestId()}');
          selectedUrl =
              '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<UserController>().userInfoModel?.id ?? Get.find<AuthController>().getGuestId()}'
              '&payment_method=${Get.find<OrderController>().digitalPaymentName}&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';

          html.window.open(selectedUrl, "_self");
        } else {
          Get.offNamed(RouteHelper.getPaymentRoute(
            orderID,
            Get.find<UserController>().userInfoModel?.id ?? 0,
            Get.find<OrderController>().orderType,
            amount,
            isCashOnDeliveryActive,
            Get.find<OrderController>().digitalPaymentName,
            guestId: Get.find<AuthController>().getGuestId(),
            contactNumber: contactNumber,
          ));
        }
      } else {
        double total = ((amount / 100) *
            Get.find<SplashController>()
                .configModel!
                .loyaltyPointItemPurchasePoint!);
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
        }
        if (ResponsiveHelper.isDesktop(Get.context) &&
            Get.find<AuthController>().isLoggedIn()) {
          Get.offNamed(RouteHelper.getInitialRoute());
          Future.delayed(
              const Duration(seconds: 2),
              () => Get.dialog(Center(
                  child: SizedBox(
                      height: 350,
                      width: 500,
                      child: OrderSuccessfulDialog(orderID: orderID)))));
        } else {
          Get.offNamed(
              RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
        }
      }
      Get.find<OrderController>().clearPrevData(zoneID);
      Get.find<CouponController>().removeCouponData(false);
      Get.find<OrderController>().updateTips(
        Get.find<AuthController>().getDmTipIndex().isNotEmpty
            ? int.parse(Get.find<AuthController>().getDmTipIndex())
            : 0,
        notify: false,
      );
    } else {
      showCustomSnackBar(message);
    }
  }

  Future<bool> saveOfflineInfo(String data) async {
    _isLoading = true;
    bool success = false;
    update();
    Response response = await orderRepo.saveOfflineInfo(data);
    if (response.statusCode == 200) {
      success = true;
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  Future<bool> updateOfflineInfo(String data) async {
    _isLoading = true;
    bool success = false;
    update();
    Response response = await orderRepo.updateOfflineInfo(data);
    if (response.statusCode == 200) {
      success = true;
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  Future<void> placePrescriptionOrder(
      int? storeId,
      int? zoneID,
      double? distance,
      String address,
      String longitude,
      String latitude,
      String note,
      List<XFile> orderAttachment,
      String dmTips,
      String deliveryInstruction,
      double orderAmount,
      double maxCodAmount,
      bool fromCart,
      bool isCashOnDeliveryActive) async {
    List<MultipartBody> multiParts = [];
    for (XFile file in orderAttachment) {
      multiParts.add(MultipartBody('order_attachment[]', file));
    }
    _isLoading = true;
    update();
    Response response = await orderRepo.placePrescriptionOrder(
        storeId,
        distance,
        address,
        longitude,
        latitude,
        note,
        multiParts,
        dmTips,
        deliveryInstruction);
    _isLoading = false;
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      String orderID = response.body['order_id'].toString();
      callback(true, message, orderID, zoneID, orderAmount, maxCodAmount,
          fromCart, isCashOnDeliveryActive, null);
      _orderAttachment = null;
      _rawAttachment = null;
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1', zoneID, orderAmount,
          maxCodAmount, fromCart, isCashOnDeliveryActive, null);
    }
    update();
  }

  void stopLoader({bool canUpdate = true}) {
    _isLoading = false;
    if (canUpdate) {
      update();
    }
  }

  void clearPrevData(int? zoneID) {
    _addressIndex = 0;
    _acceptTerms = true;
    // try {
    //   ZoneData zoneData = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((element) => element.id == zoneID);
    //   _paymentMethodIndex = zoneData.cashOnDelivery! ? 0 : zoneData.digitalPayment! ? 1
    //       : Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? 2 : 0;
    // }catch(e) {
    //   _paymentMethodIndex = Get.find<SplashController>().configModel!.cashOnDelivery! ? 0
    //       : Get.find<SplashController>().configModel!.digitalPayment! ? 1
    //       : Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? 2 : 0;
    // }
    _paymentMethodIndex = -1;
    _selectedDateSlot = 0;
    _selectedTimeSlot = 0;
    _distance = null;
    _orderAttachment = null;
    _rawAttachment = null;
  }

  void setAddressIndex(int? index) {
    _addressIndex = index;
    update();
  }

  Future<bool> cancelOrder(int? orderID, String? cancelReason) async {
    bool success = false;
    _isLoading = true;
    update();
    Response response =
        await orderRepo.cancelOrder(orderID.toString(), cancelReason);
    _isLoading = false;
    Get.back();
    if (response.statusCode == 200) {
      success = true;
      OrderModel? orderModel;
      if (_runningOrderModel != null) {
        for (OrderModel order in _runningOrderModel!.orders!) {
          if (order.id == orderID) {
            orderModel = order;
            break;
          }
        }
        _runningOrderModel!.orders!.remove(orderModel);
      }
      _showCancelled = true;
      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  void setOrderType(String? type, {bool notify = true}) {
    _orderType = type;
    if (notify) {
      update();
    }
  }

  Future<void> initializeTimeSlot(Store store) async {
    _timeSlots = [];
    _allTimeSlots = [];
    int minutes = 0;
    DateTime now = DateTime.now();
    for (int index = 0; index < store.schedules!.length; index++) {
      DateTime openTime = DateTime(
        now.year,
        now.month,
        now.day,
        DateConverter.convertStringTimeToDate(
                store.schedules![index].openingTime!)
            .hour,
        DateConverter.convertStringTimeToDate(
                store.schedules![index].openingTime!)
            .minute,
      );
      DateTime closeTime = DateTime(
        now.year,
        now.month,
        now.day,
        DateConverter.convertStringTimeToDate(
                store.schedules![index].closingTime!)
            .hour,
        DateConverter.convertStringTimeToDate(
                store.schedules![index].closingTime!)
            .minute,
      );
      if (closeTime.difference(openTime).isNegative) {
        minutes = openTime.difference(closeTime).inMinutes;
      } else {
        minutes = closeTime.difference(openTime).inMinutes;
      }
      if (minutes >
          Get.find<SplashController>()
              .configModel!
              .scheduleOrderSlotDuration!) {
        DateTime time = openTime;
        for (;;) {
          if (time.isBefore(closeTime)) {
            DateTime start = time;
            DateTime end = start.add(Duration(
                minutes: Get.find<SplashController>()
                    .configModel!
                    .scheduleOrderSlotDuration!));
            if (end.isAfter(closeTime)) {
              end = closeTime;
            }
            _timeSlots!.add(TimeSlotModel(
                day: store.schedules![index].day,
                startTime: start,
                endTime: end));
            _allTimeSlots!.add(TimeSlotModel(
                day: store.schedules![index].day,
                startTime: start,
                endTime: end));
            time = time.add(Duration(
                minutes: Get.find<SplashController>()
                    .configModel!
                    .scheduleOrderSlotDuration!));
          } else {
            break;
          }
        }
      } else {
        _timeSlots!.add(TimeSlotModel(
            day: store.schedules![index].day,
            startTime: openTime,
            endTime: closeTime));
        _allTimeSlots!.add(TimeSlotModel(
            day: store.schedules![index].day,
            startTime: openTime,
            endTime: closeTime));
      }
    }
    validateSlot(_allTimeSlots!, 0, store.orderPlaceToScheduleInterval,
        notify: false);
  }

  void updateTimeSlot(int index) {
    _selectedTimeSlot = index;
    update();
  }

  void updateDateSlot(int index, int? interval) {
    _selectedDateSlot = index;
    if (_allTimeSlots != null) {
      validateSlot(_allTimeSlots!, index, interval);
    }
    update();
  }

  void validateSlot(List<TimeSlotModel> slots, int dateIndex, int? interval,
      {bool notify = true}) {
    _timeSlots = [];
    DateTime now = DateTime.now();
    if (Get.find<SplashController>()
        .configModel!
        .moduleConfig!
        .module!
        .orderPlaceToScheduleInterval!) {
      now = now.add(Duration(minutes: interval!));
    }
    int day = 0;
    if (dateIndex == 0) {
      day = DateTime.now().weekday;
    } else {
      day = DateTime.now().add(const Duration(days: 1)).weekday;
    }
    if (day == 7) {
      day = 0;
    }
    for (var slot in slots) {
      if (day == slot.day &&
          (dateIndex == 0 ? slot.endTime!.isAfter(now) : true)) {
        _timeSlots!.add(slot);
      }
    }
    if (notify) {
      update();
    }
  }

  Future<bool> switchToCOD(String? orderID) async {
    _isLoading = true;
    update();
    Response response = await orderRepo.switchToCOD(orderID);
    bool isSuccess;
    if (response.statusCode == 200) {
      _isLoading = false;
      await Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar(response.body['message'], isError: false);
      isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng,
      {bool isDuration = false,
      bool isRiding = false,
      bool fromDashboard = false}) async {
    _distance = -1;
    Response response = await orderRepo.getDistanceInMeter(
        originLatLng, destinationLatLng, isRiding);
    try {
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        if (isDuration) {
          _distance = DistanceModel.fromJson(response.body)
                  .rows![0]
                  .elements![0]
                  .duration!
                  .value! /
              3600;
        } else {
          _distance = DistanceModel.fromJson(response.body)
                  .rows![0]
                  .elements![0]
                  .distance!
                  .value! /
              1000;
        }
      } else {
        if (!isDuration) {
          _distance = Geolocator.distanceBetween(
                originLatLng.latitude,
                originLatLng.longitude,
                destinationLatLng.latitude,
                destinationLatLng.longitude,
              ) /
              1000;
        }
      }
    } catch (e) {
      if (!isDuration) {
        _distance = Geolocator.distanceBetween(
                originLatLng.latitude,
                originLatLng.longitude,
                destinationLatLng.latitude,
                destinationLatLng.longitude) /
            1000;
      }
    }
    if (!fromDashboard) {
      await getExtraCharge(_distance);
    }
    update();
    return _distance;
  }

  void pickImage() async {
    _orderAttachment = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (_orderAttachment != null) {
      _orderAttachment = await NetworkInfo.compressImage(_orderAttachment!);
      _rawAttachment = await _orderAttachment!.readAsBytes();
    }
    update();
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    if (_selectedTips == 0 || _selectedTips == 5) {
      _tips = 0;
    } else {
      _tips = double.parse(AppConstants.tips[index]);
    }
    if (notify) {
      update();
    }
  }

  void toggleDmTipSave() {
    _isDmTipSave = !_isDmTipSave;
    update();
  }

  void toggleExpand() {
    _isExpand = !_isExpand;
    update();
  }

  void paymentRedirect(
      {required String url,
      required bool canRedirect,
      required String? contactNumber,
      required Function onClose,
      required final String? addFundUrl,
      required final String orderID}) {
    if (canRedirect) {
      bool isSuccess =
          url.contains('success') && url.contains(AppConstants.baseUrl);
      bool isFailed =
          url.contains('fail') && url.contains(AppConstants.baseUrl);
      bool isCancel =
          url.contains('cancel') && url.contains(AppConstants.baseUrl);
      if (isSuccess || isFailed || isCancel) {
        canRedirect = false;
        onClose();
      }

      if ((addFundUrl == '' && addFundUrl!.isEmpty)) {
        if (isSuccess) {
          Get.offNamed(
              RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
        } else if (isFailed || isCancel) {
          Get.offNamed(
              RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
        }
      } else {
        if (isSuccess || isFailed || isCancel) {
          if (Get.currentRoute.contains(RouteHelper.payment)) {
            Get.back();
          }
          Get.back();
          Get.toNamed(RouteHelper.getWalletRoute(true,
              fundStatus: isSuccess
                  ? 'success'
                  : isFailed
                      ? 'fail'
                      : 'cancel',
              token: DateTime.now().millisecondsSinceEpoch.toString()));
        }
      }
    }
  }

// void placeOrder() {
//   orderController.placeOrder(PlaceOrderBody(
//     cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
//     scheduleAt: !storeController.store!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
//         && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
//     orderAmount: total, orderNote: Get.find<OrderController>().noteController.text, orderType: orderController.orderType,
//     paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
//         : orderController.paymentMethodIndex == 1 ? 'wallet'
//         : orderController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
//     couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
//         && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
//     storeId: _cartList![0]!.item!.storeId,
//     address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
//     contactPersonName: finalAddress.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
//         '${Get.find<UserController>().userInfoModel!.lName}',
//     contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
//     streetNumber: orderController.streetNumberController.text.trim(), house: orderController.houseController.text.trim(), floor: orderController.floorController.text.trim(),
//     discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
//     chargePayer: null, dmTips: (orderController.orderType == 'send_gift' || orderController.tipController.text == 'not_now') ? '' : orderController.tipController.text.trim(),
//     cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
//     unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
//     deliveryInstruction: orderController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[orderController.selectedInstruction] : '',
//     partialPayment: orderController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
//   ), storeController.store!.zoneId, _callback, total, maxCodOrderAmount);
// }
}
