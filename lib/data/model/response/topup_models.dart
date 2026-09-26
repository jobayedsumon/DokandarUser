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
  final String? operator;
  final String? type;

  DriveModel({
    this.id,
    this.name,
    this.description,
    this.amount,
    this.operator,
    this.type,
  });

  factory DriveModel.fromJson(Map<String, dynamic> json) {
    return DriveModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse(json['amount']?.toString() ?? ''),
      operator: json['operator']?.toString(),
      type: json['type']?.toString(),
    );
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
