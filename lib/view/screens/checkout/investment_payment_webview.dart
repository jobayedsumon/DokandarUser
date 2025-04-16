import 'dart:collection';

import 'package:dokandar/view/base/custom_app_bar.dart';
import 'package:dokandar/view/screens/checkout/investment_after_payment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/app_constants.dart';

class InvestmentPaymentWebView extends StatefulWidget {
  final String investmentPaymentUrl;

  const InvestmentPaymentWebView({Key? key, required this.investmentPaymentUrl})
      : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<InvestmentPaymentWebView> {
  late String selectedUrl;
  bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();

    selectedUrl = widget.investmentPaymentUrl;

    _initData();
  }

  void _initData() async {
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
                android: AndroidInAppWebViewOptions(useHybridComposition: true),
              ),
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                // _redirect(url.toString());

                String urlString = url.toString();

                bool isSuccess = urlString.contains('success') &&
                    urlString.contains(AppConstants.baseUrl);
                bool isFailed = urlString.contains('fail') &&
                    urlString.contains(AppConstants.baseUrl);
                bool isCancel = urlString.contains('cancel') &&
                    urlString.contains(AppConstants.baseUrl);

                if (isSuccess) {
                  Get.to(const InvestmentAfterPaymentScreen(
                    isSuccessful: true,
                  ));
                } else if (isFailed || isCancel) {
                  Get.to(const InvestmentAfterPaymentScreen(
                    isSuccessful: false,
                  ));
                }

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

                String urlString = url.toString();

                bool isSuccess = urlString.contains('success') &&
                    urlString.contains(AppConstants.baseUrl);
                bool isFailed = urlString.contains('fail') &&
                    urlString.contains(AppConstants.baseUrl);
                bool isCancel = urlString.contains('cancel') &&
                    urlString.contains(AppConstants.baseUrl);

                if (isSuccess) {
                  Get.to(
                      const InvestmentAfterPaymentScreen(isSuccessful: true));
                } else if (isFailed || isCancel) {
                  Get.to(
                      const InvestmentAfterPaymentScreen(isSuccessful: false));
                }

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
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return Future.value(false);
      }
    }
    return null;
  }
}
