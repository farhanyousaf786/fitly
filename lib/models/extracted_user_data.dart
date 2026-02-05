class ExtractedUserData {
  final Map<String, dynamic> data;

  ExtractedUserData({Map<String, dynamic>? data}) : data = data ?? {};

  // Common getters with null safety
  String? get goal => data['goal'];
  int? get age => data['age'];
  String? get gender => data['gender'];
  String? get currentSituation => data['currentSituation'];
  String? get schedule => data['schedule'];
  String? get intensity => data['intensity'];
  String? get healthIssues => data['healthIssues'];
  String? get lifestyle => data['lifestyle'];
  double? get weight => data['weight']?.toDouble();
  double? get height => data['height']?.toDouble();

  // Flexible setter
  void updateField(String key, dynamic value) {
    if (value != null) {
      data[key] = value;
    }
  }

  // Check if we have enough info to generate a basic plan
  bool hasRequiredInfo() {
    // These are the "must-haves" for a basic tailored plan
    final requiredFields = ['goal', 'currentSituation', 'lifestyle'];
    return requiredFields.every(
      (field) => data.containsKey(field) && data[field].toString().isNotEmpty,
    );
  }

  Map<String, dynamic> toJson() => data;

  factory ExtractedUserData.fromJson(Map<String, dynamic> json) {
    return ExtractedUserData(data: Map<String, dynamic>.from(json));
  }

  @override
  String toString() => data.toString();
}
