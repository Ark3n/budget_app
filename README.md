# budget_app


# dependencies
/// freezed: code generator for data classes
flutter pub add \
  dev:build_runner \
  freezed_annotation \
  dev:freezed
flutter pub add json_annotation dev:json_serializable

/// local DB
dependencies:
  hive_ce: latest
  hive_ce_flutter: latest

dev_dependencies:
  hive_ce_generator: latest
  build_runner: latest
