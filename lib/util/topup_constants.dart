/// Configuration constants for the Success TopUp integration.
///
/// The public key and secret should ideally be delivered by your backend
/// inside [ConfigModel] so the secret is never hard-coded in the client.
/// The values below are used as a fallback only when the backend does not
/// provide them.
class TopupConstants {
  // API base
  // static const String baseUrl = 'https://api.successtopup.com';
  static const String baseUrl = 'https://successtopup.com';

  static const String rechargeUri = '/api/recharge';
  static const String statusUri = '/api/status';
  static const String drivesUri = '/api/drives';
  static const String balanceUri = '/api/balance';
  static const String billPayUri = '/api/bill-pay';
  static const String sandboxTestUri = '/api/sandbox/test';

  // Fallback credentials (replace with real values or, preferably, backend config)
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
