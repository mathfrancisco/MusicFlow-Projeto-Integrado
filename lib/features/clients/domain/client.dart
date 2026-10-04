class Client {
  const Client({required this.id, required this.name, required this.phone, required this.createdAt, required this.updatedAt, this.artisticName, this.email, this.notes});
  final String id;
  final String name;
  final String? artisticName;
  final String phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'id': id, 'name': name, 'artistic_name': artisticName, 'phone': phone, 'email': email, 'notes': notes,
    'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String(),
  };

  factory Client.fromMap(Map<String, Object?> map) => Client(
    id: map['id'] as String,
    name: map['name'] as String,
    artisticName: map['artistic_name'] as String?,
    phone: map['phone'] as String,
    email: map['email'] as String?,
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
