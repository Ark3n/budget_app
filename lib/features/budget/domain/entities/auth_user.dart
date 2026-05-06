class AuthUser {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.name,
  });

  /// Convenience username derived from the email local-part.
  String get username => email.split('@').first;

  /// Creates a modified copy while preserving unchanged fields.
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
