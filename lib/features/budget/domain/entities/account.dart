class Account {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String? icon;
  final String? color;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
    required this.createdAt,
  });
}
