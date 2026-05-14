class LocalDatabaseService {
  static final List<Map<String, dynamic>> _evaluations = [];

  static Future<List<Map<String, dynamic>>> getEvaluations() async {
    return _evaluations;
  }

  static Future<void> saveEvaluation(
    Map<String, dynamic> evaluation,
  ) async {
    _evaluations.add(evaluation);
  }

  static Future<void> clearEvaluations() async {
    _evaluations.clear();
  }
}