class TopupOperator {
  final String code;
  final String name;
  final String? icon;

  const TopupOperator({required this.code, required this.name, this.icon});
}

class DriveModel {
  final String? id;
  final String? name;
  final String? description;
  final num? amount;
  final num? commission;
  final String? duration;
  final String? operator;
  final String? type;

  DriveModel({
    this.id,
    this.name,
    this.description,
    this.amount,
    this.commission,
    this.duration,
    this.operator,
    this.type,
  });

  factory DriveModel.fromJson(Map<String, dynamic> json) {
    return DriveModel(
      id: (json['driveId'] ?? json['id'])?.toString(),
      name: (json['title'] ?? json['name'])?.toString(),
      description: json['description']?.toString(),
      amount: _toNum(json['price'] ?? json['amount']),
      commission: _toNum(json['commission']),
      duration: json['duration']?.toString(),
      operator: json['operator']?.toString(),
      type: json['type']?.toString(),
    );
  }

  static num? _toNum(dynamic value) {
    return value is num ? value : num.tryParse(value?.toString() ?? '');
  }
}

class TopupApiResponse {
  final bool result;
  final String? message;
  final String? status;
  final dynamic data;

  TopupApiResponse({
    required this.result,
    this.message,
    this.status,
    this.data,
  });

  factory TopupApiResponse.fromJson(Map<String, dynamic> json) {
    return TopupApiResponse(
      result: json['result'] == true,
      message: json['message']?.toString(),
      status: json['status']?.toString(),
      data: json,
    );
  }
}
