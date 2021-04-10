import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart';

@JsonSerializable()
class Neo4jDate {
  int year;
  int month;
  int day;
  String formatted;

  Neo4jDate({this.year, this.month, this.day, this.formatted});

  factory Neo4jDate.fromJson(Map<String, dynamic> json) =>
      _$Neo4jDateFromJson(json);
  Map<String, dynamic> toJson() => _$Neo4jDateToJson(this);
}

@JsonSerializable()
class Neo4jPoint {
  double latitude;
  double longitude;

  Neo4jPoint({this.latitude, this.longitude});

  factory Neo4jPoint.fromJson(Map<String, dynamic> json) =>
      _$Neo4jPointFromJson(json);
  Map<String, dynamic> toJson() => _$Neo4jPointToJson(this);
}

@JsonSerializable()
class User {
  String id;
  String username;
  String createdAt;
  String modifiedAt;
  Stream stream;
  List<Nugget> savedNuggets;
  List<Nugget> seenNuggets;
  List<Nugget> likedNuggets;
  List<String> selectedTopics;

  User({
    this.id,
    this.username,
    this.createdAt,
    this.modifiedAt,
    this.stream,
    this.savedNuggets,
    this.seenNuggets,
    this.likedNuggets,
    this.selectedTopics,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Stream {
  String id;
  User user;
  String createdAt;
  String modifiedAt;
  List<Nugget> nuggets;

  Stream({
    this.id,
    this.user,
    this.createdAt,
    this.modifiedAt,
    this.nuggets,
  });

  factory Stream.fromJson(Map<String, dynamic> json) => _$StreamFromJson(json);
  Map<String, dynamic> toJson() => _$StreamToJson(this);
}

@JsonSerializable()
class Nugget {
  String id;
  User createdBy;
  String nuggetType;
  String content;
  String metaInfo;
  String createdAt;
  String modifiedAt;
  List<String> topics;

  Nugget({
    this.id,
    this.createdBy,
    this.nuggetType,
    this.content,
    this.metaInfo,
    this.createdAt,
    this.modifiedAt,
  });

  factory Nugget.fromJson(Map<String, dynamic> json) => _$NuggetFromJson(json);
  Map<String, dynamic> toJson() => _$NuggetToJson(this);
}

enum NuggetTypeEnum { TEXT, IMAGE, VIDEO }
