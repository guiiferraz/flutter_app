
class StatusEnum {
  final int? id;
  final String status;

  StatusEnum({this.id, required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
    };
  }

  factory StatusEnum.fromMap(Map<String, dynamic> map) {
    return StatusEnum(
      id: map['id'],
      status: map['status'],
    );
  }
}