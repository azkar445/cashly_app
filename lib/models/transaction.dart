class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id'       : id,
    'title'    : title,
    'amount'   : amount,
    'isIncome' : isIncome,
    'date'     : date.toIso8601String(),
    'category' : category,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Support both local key (isIncome) and server key (is_income)
    final bool income = json['isIncome'] != null
        ? json['isIncome'] == true || json['isIncome'] == 1
        : json['is_income'] == true || json['is_income'] == 1;

    // Support both local key (date) and server key (created_at / date)
    final String rawDate =
        json['date'] ?? json['created_at'] ?? DateTime.now().toIso8601String();

    return TransactionModel(
      id      : json['id']?.toString() ?? DateTime.now().toString(),
      title   : json['title']    ?? '',
      amount  : (json['amount']  as num).toDouble(),
      isIncome: income,
      date    : DateTime.parse(rawDate),
      category: json['category'] ?? 'Lainnya',
    );
  }
}