import 'dart:core';

class BikeProperties {
  int objectid;
  String nom;
  String adresse;
  Null code_insee;
  String commune;
  String etat;
  String type;
  int nb_places_dispo;
  int nb_velos_dispo;
  String etat_connexion;
  double x;
  double y;
  String date_modification;

  BikeProperties(this.objectid,this.nom, this.adresse, this.code_insee, this.commune, this.etat, this.type, this.nb_places_dispo, this.nb_velos_dispo, this.etat_connexion, this.x, this.y, this.date_modification);

  factory BikeProperties.fromJson(Map<String, dynamic> json) {
    return BikeProperties(
      json['objectid'],
      json['nom'],
      json['adresse'],
      json['code_insee'],
      json['commune'],
      json['etat'],
      json['type'],
      json['nb_places_dispo'],
      json['nb_velos_dispo'],
      json['etat_connexion'],
      json['x'],
      json['y'],
      json['date_modification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectid': objectid,
      'nom': nom,
      'adresse': adresse,
      'code_insee': code_insee,
      'commune': commune,
      'etat': etat,
      'type': type,
      'nb_places_dispo': nb_places_dispo,
      'nb_velos_dispo': nb_velos_dispo,
      'etat_connexion': etat_connexion,
      'x': x,
      'y': y,
      'date_modification': date_modification,
    };
  }
}

