enum AnalyticsStatus { initial, empty, success }

enum AnalyticsRange { today, week, month, year }

class BalancePoint {
  final DateTime date;
  final double balance;

  const BalancePoint({required this.date, required this.balance});
}

class CategorySlice {
  final String label;
  final double amount;
  final String? colorKey;
  final String? iconKey;

  const CategorySlice({
    required this.label,
    required this.amount,
    this.colorKey,
    this.iconKey,
  });
}

class AnalyticsState {
  final AnalyticsStatus status;
  final AnalyticsRange selectedRange;
  final List<BalancePoint> balancePoints;
  final List<CategorySlice> categorySlices;
  final double totalExpenses;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.selectedRange = AnalyticsRange.today,
    this.balancePoints = const [],
    this.categorySlices = const [],
    this.totalExpenses = 0,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsRange? selectedRange,
    List<BalancePoint>? balancePoints,
    List<CategorySlice>? categorySlices,
    double? totalExpenses,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      selectedRange: selectedRange ?? this.selectedRange,
      balancePoints: balancePoints ?? this.balancePoints,
      categorySlices: categorySlices ?? this.categorySlices,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }
}
