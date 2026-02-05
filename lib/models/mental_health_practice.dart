class MentalHealthPractice {
  final String id;
  final String name;
  final String type; // meditation, journaling, breathing
  final int durationMinutes;
  final String time;
  final String instructions;
  final String? audioGuideUrl;

  MentalHealthPractice({
    required this.id,
    required this.name,
    required this.type,
    required this.durationMinutes,
    required this.time,
    required this.instructions,
    this.audioGuideUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'durationMinutes': durationMinutes,
      'time': time,
      'instructions': instructions,
      'audioGuideUrl': audioGuideUrl,
    };
  }

  factory MentalHealthPractice.fromMap(Map<String, dynamic> map) {
    return MentalHealthPractice(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'meditation',
      durationMinutes: map['durationMinutes'] ?? 0,
      time: map['time'] ?? '',
      instructions: map['instructions'] ?? '',
      audioGuideUrl: map['audioGuideUrl'],
    );
  }
}
