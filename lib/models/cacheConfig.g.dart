// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cacheConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheConfig _$CacheConfigFromJson(Map<String, dynamic> json) {
  return CacheConfig()
    ..enable = json['enable'] as bool
    ..maxCount = json['maxCount'] as int
    ..maxAge = json['maxAge'] as int;
}

Map<String, dynamic> _$CacheConfigToJson(CacheConfig instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'maxCount': instance.maxCount,
      'maxAge': instance.maxAge,
    };
