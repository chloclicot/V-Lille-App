import 'package:v_lille/JsonResponses/feature.dart';

class VLilleApiResponse {
  final String type;
  final List<Feature> features;

  VLilleApiResponse(this.type, this.features);

  factory VLilleApiResponse.fromJson(Map<String, dynamic> json) {
    return VLilleApiResponse(
      json['type'],
      List<Feature>.from(json['features'].map((feature) => Feature.fromJson(feature))),
    );
  }

}