import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String? id;
  final String time;
  final String title;

  Reminder({this.id, required this.time, required this.title});

  Map<String, dynamic> toMap() {
    return {if (id != null) 'id': id, 'time': time, 'title': title};
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      time: map['time'] ?? '',
      title: map['title'] ?? '',
    );
  }

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder.fromMap({...data, 'id': doc.id});
  }
}
