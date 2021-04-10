// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Neo4jDate _$Neo4jDateFromJson(Map<String, dynamic> json) {
  return Neo4jDate(
    year: json['year'] as int,
    month: json['month'] as int,
    day: json['day'] as int,
    formatted: json['formatted'] as String,
  );
}

Map<String, dynamic> _$Neo4jDateToJson(Neo4jDate instance) => <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
      'formatted': instance.formatted,
    };

Neo4jPoint _$Neo4jPointFromJson(Map<String, dynamic> json) {
  return Neo4jPoint(
    latitude: (json['latitude'] as num)?.toDouble(),
    longitude: (json['longitude'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$Neo4jPointToJson(Neo4jPoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    username: json['username'] as String,
    createdAt: json['createdAt'] as String,
    modifiedAt: json['modifiedAt'] as String,
    stream: json['stream'] == null
        ? null
        : Stream.fromJson(json['stream'] as Map<String, dynamic>),
    savedNuggets: (json['savedNuggets'] as List)
        ?.map((e) =>
            e == null ? null : Nugget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    seenNuggets: (json['seenNuggets'] as List)
        ?.map((e) =>
            e == null ? null : Nugget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    likedNuggets: (json['likedNuggets'] as List)
        ?.map((e) =>
            e == null ? null : Nugget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    selectedTopics:
        (json['selectedTopics'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'createdAt': instance.createdAt,
      'modifiedAt': instance.modifiedAt,
      'stream': instance.stream,
      'savedNuggets': instance.savedNuggets,
      'seenNuggets': instance.seenNuggets,
      'likedNuggets': instance.likedNuggets,
      'selectedTopics': instance.selectedTopics,
    };

Stream _$StreamFromJson(Map<String, dynamic> json) {
  return Stream(
    id: json['id'] as String,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    createdAt: json['createdAt'] as String,
    modifiedAt: json['modifiedAt'] as String,
    nuggets: (json['nuggets'] as List)
        ?.map((e) =>
            e == null ? null : Nugget.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$StreamToJson(Stream instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'createdAt': instance.createdAt,
      'modifiedAt': instance.modifiedAt,
      'nuggets': instance.nuggets,
    };

Nugget _$NuggetFromJson(Map<String, dynamic> json) {
  return Nugget(
    id: json['id'] as String,
    createdBy: json['createdBy'] == null
        ? null
        : User.fromJson(json['createdBy'] as Map<String, dynamic>),
    nuggetType: json['nuggetType'] as String,
    content: json['content'] as String,
    metaInfo: json['metaInfo'] as String,
    createdAt: json['createdAt'] as String,
    modifiedAt: json['modifiedAt'] as String,
  )..topics = (json['topics'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$NuggetToJson(Nugget instance) => <String, dynamic>{
      'id': instance.id,
      'createdBy': instance.createdBy,
      'nuggetType': instance.nuggetType,
      'content': instance.content,
      'metaInfo': instance.metaInfo,
      'createdAt': instance.createdAt,
      'modifiedAt': instance.modifiedAt,
      'topics': instance.topics,
    };
