import 'project_status.dart';

class Project {
  const Project({required this.id, required this.clientId, required this.title, required this.serviceType, required this.requestedDate, required this.status, required this.createdAt, required this.updatedAt, this.description, this.dueDate, this.amount, this.notes});
  final String id;
  final String clientId;
  final String title;
  final String serviceType;
  final String? description;
  final DateTime requestedDate;
  final DateTime? dueDate;
  final double? amount;
  final ProjectStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({ProjectStatus? status, DateTime? updatedAt}) => Project(
    id: id, clientId: clientId, title: title, serviceType: serviceType, description: description,
    requestedDate: requestedDate, dueDate: dueDate, amount: amount, status: status ?? this.status,
    notes: notes, createdAt: createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id, 'client_id': clientId, 'title': title, 'service_type': serviceType, 'description': description,
    'requested_date': requestedDate.toIso8601String(), 'due_date': dueDate?.toIso8601String(), 'amount': amount,
    'status': status.dbValue, 'notes': notes, 'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, Object?> map) => Project(
    id: map['id'] as String,
    clientId: map['client_id'] as String,
    title: map['title'] as String,
    serviceType: map['service_type'] as String,
    description: map['description'] as String?,
    requestedDate: DateTime.parse(map['requested_date'] as String),
    dueDate: map['due_date'] == null ? null : DateTime.parse(map['due_date'] as String),
    amount: (map['amount'] as num?)?.toDouble(),
    status: ProjectStatus.fromDb(map['status'] as String),
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
