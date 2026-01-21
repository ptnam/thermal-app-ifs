/// Domain entity for Warning Event
class WarningEventEntity {
  final int id;
  final String code;
  final String name;

  const WarningEventEntity({
    required this.id,
    required this.code,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarningEventEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
