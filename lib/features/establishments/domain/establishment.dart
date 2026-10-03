class Establishment {
  const Establishment({
    required this.id,
    required this.name,
    required this.ownerUid,
  });
  final String id;
  final String name;
  final String ownerUid;
  Map<String, Object?> toMap() => {'name': name, 'ownerUid': ownerUid};
  factory Establishment.fromMap(String id, Map<String, Object?> map) =>
      Establishment(
        id: id,
        name: map['name']! as String,
        ownerUid: map['ownerUid']! as String,
      );
}
