import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v_lille/JsonResponses/vLilleApiResponse.dart';
import 'package:v_lille/station.dart';
import 'package:http/http.dart' as http;

class StationsProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String url =
      "https://data.lillemetropole.fr/geoserver/wfs?SERVICE=WFS&REQUEST=GetFeature&VERSION=2.0.0&TYPENAMES=dsp_ilevia%3Avlille_temps_reel&OUTPUTFORMAT=application%2Fjson";

  List<Station> _stations = [];
  Station _closestStation = Station("", "", 0, 0, 0.0, 0.0, false);
  Station _selectedStation = Station("", "", 0, 0, 0.0, 0.0, false);
  List<String> _stationsfav =
  []; // on va seulement stocker les noms des stations favorites

  List<double> currentLocation = [0.0, 0.0];

  StationsProvider() {
    loadStationsFav();
    _determinePosition().then((value) {
      currentLocation = [value.latitude, value.longitude];
    });
    _getStations().then((value) {
      _stations = value;
      _closestStation = _stations[0];
      for (var s in _stations) {
        // si le nom de la station est dans la liste des stations favorites
        if (_stationsfav.contains(s.name)) {
          s.isFavorite = true;
        }
        var distance = Geolocator.distanceBetween(
            currentLocation[0], currentLocation[1], s.y, s.x);
        if (distance <
            Geolocator.distanceBetween(currentLocation[0], currentLocation[1],
                _closestStation.y, _closestStation.x)) {
          _closestStation = s;
        }
      }

      notifyListeners();
    });
  }

  void loadStationsFav() async {
    final sharedpreferences = await SharedPreferences.getInstance();
    var favs = sharedpreferences.getStringList('stationsFav') ?? [];
    _stationsfav = favs;
  }

  void saveStations() async {
    final sharedpreferences = await SharedPreferences.getInstance();
    sharedpreferences.setStringList('stationsFav', _stationsfav);
  }

  void addFavorite(Station station) {
    _stationsfav.add(station.name);
    saveStations();
    notifyListeners();
  }

  void removeFavorite(Station station) {
    _stationsfav.remove(station.name);
    saveStations();
    notifyListeners();
  }

  void selectStation(Station station) {
    _selectedStation = station;
    notifyListeners();
  }

  void refresh(){
    // on garde le nom de la station selectionnée
    var selectedStationName = _selectedStation.name;
    _getStations().then((value) {
      _stations = value;
      _closestStation = _stations[0];
      for (var s in _stations) {
        // si le nom de la station est dans la liste des stations favorites
        if (_stationsfav.contains(s.name)) {
          s.isFavorite = true;
        }
        var distance = Geolocator.distanceBetween(
            currentLocation[0], currentLocation[1], s.y, s.x);
        if (distance <
            Geolocator.distanceBetween(currentLocation[0], currentLocation[1],
                _closestStation.y, _closestStation.x)) {
          _closestStation = s;
        }
        // on remet la station selectionnée refreshed
        if (s.name == selectedStationName){
          _selectedStation = s;
        }
      }

      notifyListeners();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        //TODO: your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Station>> _getStations() async {
    var response = await http.get(Uri.parse(url), headers: {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*'
    });
    if (response.statusCode == 200) {
      var stations = <Station>[];
      for (var feature in VLilleApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>)
          .features) {
        stations.add(Station(
            feature.properties.nom,
            feature.properties.adresse,
            feature.properties.nb_velos_dispo,
            feature.properties.nb_places_dispo,
            feature.properties.x,
            feature.properties.y,
            false));
      }
      return stations;
    } else {
      throw Exception("Failed to load stations");
    }
  }

  //Todo: add method pour refresh la position plus proche

  List<Station> get stations => _stations;
  Station get closestStation => _closestStation;
  Station get selectedStation => _selectedStation;
  List<String> get stationsfav => _stationsfav;

  set selectedStation(Station station) {
    _selectedStation = station;
    notifyListeners();
  }
}