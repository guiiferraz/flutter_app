class Tarefa {
  final int? id;
  final String name;
  final String description;
  final String date;
  final int statusId;
  final int usuarioId;

  Tarefa({
    this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.statusId,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'status_id': statusId,
      'usuario_id': usuarioId,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      date: map['date'],
      statusId: map['status_id'],
      usuarioId: map['usuario_id'],
    );
  }
}