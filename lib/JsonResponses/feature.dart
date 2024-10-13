

import 'package:v_lille/JsonResponses/FeatureProperties.dart';
import 'package:v_lille/JsonResponses/geometry.dart';

class Feature {
  String type;
  String id;
  Geometry geometry;
  String geometry_name;
  BikeProperties properties;

  Feature(this.type, this.id, this.geometry, this.geometry_name, this.properties);

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      json['type'],
      json['id'],
      Geometry.fromJson(json['geometry']),
      json['geometry_name'],
      BikeProperties.fromJson(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'geometry': geometry,
      'geometry_name': geometry_name,
      'properties': properties,
    };
  }

}