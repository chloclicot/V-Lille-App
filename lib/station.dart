class Station {
  final String name;
  final String adresse;
  final int places_dispos;
  final int velos_dispos;
  final double x;
  final double y;
  bool isFavorite = false;

  Station(this.name, this.adresse, this.places_dispos, this.velos_dispos, this.x, this.y, this.isFavorite);


  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      json['nom'],
      json['adresse'],
      json['nb_places_dispo'],
      json['nb_velos_dispo'],
      json['x'],
      json['y'],
      json['isFavorite'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': name,
      'adresse': adresse,
      'nb_places_dispo': places_dispos,
      'nb_velos_dispo': velos_dispos,
      'x': x,
      'y': y,
      'isFavorite': isFavorite,
    };
  }

}