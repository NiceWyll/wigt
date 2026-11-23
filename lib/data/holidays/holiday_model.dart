/// Modelo de un feriado o día no laborable en Perú.
class Holiday {
  const Holiday({
    required this.date,
    required this.name,
    required this.type,
    this.provisional = false,
    this.verifiedOn,
    this.note,
  });

  final String date; // 'yyyy-MM-dd'
  final String name;
  final String type; // 'feriado' o 'no_laborable'
  final bool provisional;
  final String? verifiedOn;
  final String? note;

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: json['date'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'feriado',
      provisional: json['provisional'] as bool? ?? false,
      verifiedOn: json['verifiedOn'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'name': name,
    'type': type,
    'provisional': provisional,
    if (verifiedOn != null) 'verifiedOn': verifiedOn,
    if (note != null) 'note': note,
  };
}

