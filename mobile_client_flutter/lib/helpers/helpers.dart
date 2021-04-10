// Helper functions
import 'package:intl/intl.dart';

String enumToString(Object o) => o.toString().split('.').last;

T enumFromString<T>(String key, List<T> values) =>
    values.firstWhere((v) => key == enumToString(v), orElse: () => null);

String prettifyEnumString(String o) => o.replaceAll('_', ' ');

final f = new DateFormat('yyyy-MM-dd hh:mm');
String timestampToDate(String timestamp) => f
    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)))
    .toString();

List<String> getAvailableTopics() => [
      "Random",
      "Investment",
      "Personal development",
      "Life extension",
      "Design",
      "Fallacies",
      "Bayesian statistics",
      "Decision theory",
      "Universe",
      "Motivation",
      "Attention",
      "Cognitive biases",
      "Emotion",
      "Information science",
      "Biotechnology",
      "Nanotechnology",
      "Robotics",
      "Technology forecasting",
      "Artificial intelligence",
      "Human–computer interaction",
      "Mobile web",
      "Nuclear technology"
    ];
