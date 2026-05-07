/// Thrown when a transaction would drop an account balance below zero.
class InsufficientBalanceException implements Exception {
  const InsufficientBalanceException();

  /// Short, conversational copy for dialogs and snack bars.
  static const String userMessage =
      "That’s more than your current balance. Try a smaller amount or add income first.";

  @override
  String toString() => userMessage;
}
