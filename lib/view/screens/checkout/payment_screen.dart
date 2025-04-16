import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dokandar/controller/location_controller.dart';
import 'package:dokandar/controller/order_controller.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/data/model/response/order_model.dart';
import 'package:dokandar/data/model/response/zone_response_model.dart';
import 'package:dokandar/util/app_constants.dart';
import 'package:dokandar/util/dimensions.dart';
import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:dokandar/view/screens/wallet/widget/fund_payment_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? investmentPaymentUrl;

  const PaymentScreen(
      {Key? key,
      required this.orderModel,
      required this.isCashOnDelivery,
      this.addFundUrl,
      required this.paymentMethod,
      required this.guestId,
      required this.contactNumber,
      this.investmentPaymentUrl})
      : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? _maximumCodOrderAmount;

  @override
  void initState() {
    super.initState();

    if (widget.addFundUrl == null ||
        (widget.addFundUrl != null && widget.addFundUrl!.isEmpty)) {
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else {
      selectedUrl = widget.addFundUrl!;
    }

    _initData();
  }

  void _initData() async {
    if (widget.addFundUrl == null ||
        (widget.addFundUrl != null && widget.addFundUrl!.isEmpty)) {
      for (ZoneData zData
          in Get.find<LocationController>().getUserAddress()!.zoneData!) {
        for (Modules m in zData.modules!) {
          if (m.id == Get.find<SplashController>().module!.id) {
            _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
            break;
          }
        }
      }
    }

    browser = MyInAppBrowser(
        orderID: widget.orderModel.id.toString(),
        orderType: widget.orderModel.orderType,
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        isCashOnDelivery: widget.isCashOnDelivery,
        addFundUrl: widget.addFundUrl,
        contactNumber: widget.contactNumber);

    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      bool swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable =
          await AndroidWebViewFeature.isFeatureSupported(
              AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
            AndroidServiceWorkerController.instance();
        await serviceWorkerController
            .setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            return null;
          },
        ));
      }
    }

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          browser.webViewController.reload();
        } else if (Platform.isIOS) {
          browser.webViewController.loadUrl(
              urlRequest:
                  URLRequest(url: await browser.webViewController.getUrl()));
        }
      },
    );
    browser.pullToRefreshController = pullToRefreshController;

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: Uri.parse(selectedUrl)),
      options: InAppBrowserClassOptions(
        crossPlatform:
            InAppBrowserOptions(hideUrlBar: true, hideToolbarTop: true),
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() => _exitApp().then((value) => value!)),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar:
            CustomAppBar(title: 'payment'.tr, onBackPressed: () => _exitApp()),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if (widget.addFundUrl == null ||
        (widget.addFundUrl != null && widget.addFundUrl!.isEmpty)) {
      return Get.dialog(PaymentFailedDialog(
          orderID: widget.orderModel.id.toString(),
          orderAmount: widget.orderModel.orderAmount,
          maxCodOrderAmount: _maximumCodOrderAmount,
          orderType: widget.orderModel.orderType,
          isCashOnDelivery: widget.isCashOnDelivery));
    } else {
      return Get.dialog(const FundPaymentDialog());
    }
  }
}

class MyInAppBrowser extends InAppBrowser {
  final String orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String? contactNumber;

  MyInAppBrowser(
      {required this.orderID,
      required this.orderType,
      required this.orderAmount,
      required this.maxCodOrderAmount,
      required this.isCashOnDelivery,
      this.addFundUrl,
      this.contactNumber,
      int? windowId,
      UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  final bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      // print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      // print("\n\nStarted: $url\n\n");
    }
    // _redirect(url.toString());
    Get.find<OrderController>().paymentRedirect(
        url: url.toString(),
        canRedirect: _canRedirect,
        onClose: () => close(),
        addFundUrl: addFundUrl,
        orderID: orderID,
        contactNumber: contactNumber);
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      // print("\n\nStopped: $url\n\n");
    }
    Get.find<OrderController>().paymentRedirect(
        url: url.toString(),
        canRedirect: _canRedirect,
        onClose: () => close(),
        addFundUrl: addFundUrl,
        orderID: orderID,
        contactNumber: contactNumber);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      // print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      // print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    // if(_canRedirect) {
    //   Get.dialog(PaymentFailedDialog(orderID: orderID, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount, orderType: orderType, isCashOnDelivery: isCashOnDelivery));
    // }
    if (kDebugMode) {
      // print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    if (kDebugMode) {
      // print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      // print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      //    print("""
      //  console output:
      //    message: ${consoleMessage.message}
      //    messageLevel: ${consoleMessage.messageLevel.toValue()}
      // """);
    }
  }
}
