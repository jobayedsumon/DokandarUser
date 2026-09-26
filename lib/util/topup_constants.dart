/// Configuration constants for the Success TopUp integration.
///
/// The app now proxies all Success TopUp calls through the Dokandar backend
/// so the Success TopUp secret stays server-side and CORS is avoided.
class TopupConstants {
  // Backend proxy endpoint URIs (relative to AppConstants.baseUrl)
  static const String rechargeUri = '/api/v1/customer/topup/recharge';
  static const String statusUri = '/api/v1/customer/topup/status';
  static const String drivesUri = '/api/v1/customer/topup/drives';
  static const String balanceUri = '/api/v1/customer/topup/balance';
  static const String billPayUri = '/api/v1/customer/topup/bill-pay';
  static const String sandboxTestUri = '/api/v1/customer/topup/sandbox-test';

  // Fallback credentials kept empty; the backend stores the real credentials.
  static const String fallbackKey = '';
  static const String fallbackSecret = '';

  // Service tabs
  static const String tabRecharge = 'recharge';
  static const String tabDataPack = 'data_pack';
  static const String tabBill = 'bill';

  static const List<Map<String, String>> mobileOperators = [
    {'code': 'GP', 'name': 'Grameenphone'},
    {'code': 'RB', 'name': 'Robi'},
    {'code': 'AT', 'name': 'Airtel'},
    {'code': 'BL', 'name': 'Banglalink'},
    {'code': 'TT', 'name': 'Teletalk'},
    {'code': 'SK', 'name': 'Skitto'},
    {'code': 'BT', 'name': 'Brilliant'},
    {'code': 'RY', 'name': 'Ryze'},
  ];

  static const List<Map<String, String>> billOperators = [
    {'code': 'DESCO', 'name': 'DESCO (Postpaid)', 'type': 'electricity'},
    {'code': 'DPDC', 'name': 'DPDC (Postpaid)', 'type': 'electricity'},
    {'code': 'NESCO', 'name': 'NESCO (Postpaid)', 'type': 'electricity'},
    {'code': 'TITAS', 'name': 'Titas Gas', 'type': 'gas'},
    {'code': 'KARNAPHULI', 'name': 'Karnaphuli Gas', 'type': 'gas'},
    {'code': 'JALALABAD', 'name': 'Jalalabad Gas', 'type': 'gas'},
    {'code': 'SUNDARBAN', 'name': 'Sundarban Gas', 'type': 'gas'},
    {'code': 'WASA', 'name': 'Dhaka WASA', 'type': 'water'},
    {'code': 'BTCL_PREPAID', 'name': 'BTCL Prepaid', 'type': 'internet'},
    {'code': 'BTCL_POSTPAID', 'name': 'BTCL Postpaid', 'type': 'internet'},
    {'code': 'INTERNET', 'name': 'Internet Bill', 'type': 'internet'},
    {'code': 'VISA', 'name': 'Credit Card (Visa)', 'type': 'credit_card'},
    {
      'code': 'MASTERCARD',
      'name': 'Credit Card (Master)',
      'type': 'credit_card'
    },
  ];
}
