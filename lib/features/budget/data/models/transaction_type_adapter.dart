import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:hive_ce/hive_ce.dart';

/// Hive adapter for persisting [TransactionType] enum values.
class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 3;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
      case TransactionType.expense:
        writer.writeByte(1);
    }
  }
}
