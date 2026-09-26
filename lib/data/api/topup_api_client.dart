import 'dart:convert';

import 'package:dokandar/data/model/response/error_response.dart';
import 'package:dokandar/util/topup_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;

/// API client for the Success TopUp third-party service.
/// It targets [TopupConstants.baseUrl] and uses plain JSON headers.
class TopupApiClient extends GetxService {
  static const String _baseUrl = TopupConstants.baseUrl;
  static const int _timeoutInSeconds = 40;

  Future<Response> postData(String uri, Map<String, dynamic> body) async {
    try {
      if (kDebugMode) {
        // print('====> TopUp API Call: $uri\nBody: $body');
      }
      http.Response response = await http
          .post(
            Uri.parse(_baseUrl + uri),
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
          )
          .timeout(const Duration(seconds: _timeoutInSeconds));
      return _handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: 'connection_to_api_server_failed'.tr);
    }
  }

  Response _handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: errorResponse.errors![0].message);
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']);
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: 'connection_to_api_server_failed'.tr);
    }
    return response0;
  }
}
