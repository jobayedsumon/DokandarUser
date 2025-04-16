import 'dart:collection';

import 'package:dokandar/controller/location_controller.dart';
import 'package:dokandar/controller/order_controller.dart';
import 'package:dokandar/controller/splash_controller.dart';
import 'package:dokandar/data/model/response/order_model.dart';
import 'package:dokandar/data/model/response/zone_response_model.dart';
import 'package:dokandar/util/app_constants.dart';
import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:dokandar/view/screens/wallet/widget/fund_payment_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? investmentPaymentUrl;

  const PaymentWebViewScreen(
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

class PaymentScreenState extends State<PaymentWebViewScreen> {
  late String selectedUrl;
  bool _isLoading = true;
  final bool _canRedirect = true;
  double? _maximumCodOrderAmount;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;

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

    pullToRefreshController = GetPlatform.isWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _exitApp();
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBar(
            title: '', onBackPressed: () => _exitApp(), backButton: true),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(selectedUrl)),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    userAgent:
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36',
                  ),
                  android:
                      AndroidInAppWebViewOptions(useHybridComposition: true)),
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
              onLoadStart: (controller, url) async {
                // _redirect(url.toString());
                Get.find<OrderController>().paymentRedirect(
                    url: url.toString(),
                    canRedirect: _canRedirect,
                    onClose: () {},
                    addFundUrl: widget.addFundUrl,
                    orderID: widget.orderModel.id.toString(),
                    contactNumber: widget.contactNumber);
                setState(() {
                  _isLoading = true;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                Uri uri = navigationAction.request.url!;
                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() {
                  _isLoading = false;
                });
                Get.find<OrderController>().paymentRedirect(
                    url: url.toString(),
                    canRedirect: _canRedirect,
                    onClose: () {},
                    addFundUrl: widget.addFundUrl,
                    orderID: widget.orderModel.id.toString(),
                    contactNumber: widget.contactNumber);
                // _redirect(url.toString());
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
                // setState(() {
                //   _value = progress / 100;
                // });
              },
              onConsoleMessage: (controller, consoleMessage) {
                // debugPrint(consoleMessage.message);
              },
            ),
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
    );
  }

  Future<bool?> _exitApp() async {
    if ((widget.addFundUrl == null ||
            (widget.addFundUrl != null && widget.addFundUrl!.isEmpty)) ||
        !Get.find<SplashController>()
            .configModel!
            .digitalPaymentInfo!
            .pluginPaymentGateways!) {
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
      ));
    } else {
      return Get.dialog(const FundPaymentDialog());
    }
  }
}
