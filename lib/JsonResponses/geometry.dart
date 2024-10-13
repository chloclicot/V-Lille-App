import 'dart:core';

class Geometry {
  final String type;
  final List<double> coordinates;

  const Geometry(this.type, this.coordinates);

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      json['type'],
      List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }



}