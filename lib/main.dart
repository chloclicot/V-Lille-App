import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v_lille/station.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:v_lille/stationsProvider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => StationsProvider())
    ],
    child: const VLilleApp(),
  ));
}

class VLilleApp extends StatelessWidget {
  const VLilleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V\'Lille',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: const VLilleHomePage(),
    );
  }
}

class VLilleHomePage extends StatefulWidget {
  const VLilleHomePage({super.key});

  @override
  State<VLilleHomePage> createState() => VLilleHomePageState();
}

class VLilleHomePageState extends State<VLilleHomePage> {
  bool _showFavorites = false;
  bool _showMap = true;
  bool _showClosest = true;
  final MapController _mapController = MapController();

  void moveMapToStation(double lat, double lon) {
    _mapController.move(LatLng(lat, lon), 13.0); // Adjust zoom if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Besoin d'un vélo ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w100,
                  )),
              const Text('Trouve ton V\'Lille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ))
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/background.png",
                fit: BoxFit.cover,
              ),
            ),
            //  le container blanc
            SafeArea(
                child: Column(
              children: [
                const SizedBox(height: 130),
                Expanded(
                    child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ))
              ],
            )),
            SafeArea(
                child: Column(children: [
              const SizedBox(height: 87),
              // Les boutons d'options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // favoris
                  ElevatedButton(
                    onPressed: () {
                      //reset la station selectionnée
                      Provider.of<StationsProvider>(context, listen: false)
                              .selectStation(Station("", "", 0, 0, 0.0, 0.0, false));
                      setState(() {
                        _showFavorites = !_showFavorites;
                        _showMap = false;
                        if (_showFavorites) {
                          _showClosest = false;
                        } else {
                          _showClosest = true;
                          _showMap = true;
                          moveMapToStation(
                              Provider.of<StationsProvider>(context)
                                  .closestStation
                                  .y,
                              Provider.of<StationsProvider>(context)
                                  .closestStation
                                  .x
                          );
                        }
                      });
                    },
                    child: const Row(
                      children: [Icon(Icons.star), Text("Favoris")],
                    ),
                   ),
                  ],
                ),
                  const SizedBox(height: 20),
                  // La map
                  if (_showMap)
                  MapWidget(
                  mapController: _mapController,
                  onPinclick: () {
                    setState(() {
                      // cacher la station la plus près
                      _showClosest = false;
                      _showMap = true;
                      });
                    },
                  ),
                //Station selectionnée
                if (Provider.of<StationsProvider>(context).selectedStation.name !=
                  "")
                  StationWidget(
                    onClicked: (){},
                    station:
                        Provider.of<StationsProvider>(context).selectedStation),
              // Stations favorites
              if (_showFavorites &&
                  Provider.of<StationsProvider>(context).stationsfav.isNotEmpty)
                FavoriteStationsWidget(
                  mapController: _mapController,
                  clickFavStation: (){
                    setState(() {
                      _showFavorites = false;
                      _showMap = true;
                    });
                  },
                ),
              if (_showFavorites &&
                  Provider.of<StationsProvider>(context).stationsfav.isEmpty)
                // messzge si pas de stations favorites
                Center(
                    child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.star, color: Colors.yellow.shade600, size: 28),
                    const SizedBox(height: 5),
                    const Text(
                      "Aucune station favorite",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showFavorites = false;
                            _showClosest = true;
                            _showMap = true;
                          });
                        },
                        child: const Text("Retour"))
                  ],
                )),
              if (_showClosest)
                //Station la plus proche
                const SizedBox(height: 20),
              if (!_showFavorites && _showClosest)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_pin, color: Colors.red, size: 28),
                    SizedBox(width: 5), // Space between icon and text
                    Text(
                      "Station la plus proche",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              if (!_showFavorites && _showClosest)
                StationWidget(
                  onClicked: (){},
                    station:
                        Provider.of<StationsProvider>(context).closestStation),
            ])),
            SafeArea(
                child: Column(
              children: [
                const SizedBox(height: 10),
                StationSearchBar(
                  mapController: _mapController,
                  onClearQuery: () {
                    setState(() {
                      _showClosest = true;
                    });
                  },
                  onSelectStation: () {
                    setState(() {
                      _showClosest = false;
                      _showFavorites = false;
                      _showMap = true;
                    });
                  },
                ),
              ],
            ))
          ],
        ));
  }
}

class StationWidget extends StatefulWidget {
  final Station station;
  final Function onClicked;
  const StationWidget({super.key, required this.station, required this.onClicked});

  @override
  State<StationWidget> createState() => _StationWidgetState();
}

class _StationWidgetState extends State<StationWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onClicked();
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          width: 300,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.station.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          widget.station.isFavorite
                              ? Icons.star
                              : Icons.star_border,
                          color: widget.station.isFavorite
                              ? Colors.yellow.shade600
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.station.toggleFavorite();
                            if (widget.station.isFavorite) {
                              Provider.of<StationsProvider>(context,
                                  listen: false)
                                  .addFavorite(widget.station);
                            } else {
                              Provider.of<StationsProvider>(context,
                                  listen: false)
                                  .removeFavorite(widget.station);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.station.adresse,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${widget.station.velos_dispos} vélos • ${widget.station.places_dispos} places",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteStationsWidget extends StatelessWidget {
  final List<Station> stationsfav = [];
  final Function clickFavStation;
  final MapController mapController;

  FavoriteStationsWidget({super.key, required this.clickFavStation, required this.mapController});

  void loadStations() async {
    final sharedpreferences = await SharedPreferences.getInstance();
    var favs = sharedpreferences.getStringList('stationsfav') ?? [];
    for (var fav in favs) {
      stationsfav.add(Station.fromJson(fav as Map<String, dynamic>));
    }
  }

  void moveMapToStation(double lat, double lon) {
    mapController.move(LatLng(lat, lon), 16.0); // Adjust zoom if needed
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Mes stations favorites",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10), // Adding some spacing for a better layout
          Expanded(
            // Use Expanded here to allow ListView to take remaining space
            child: ListView(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              shrinkWrap:
                  true, // Can be removed since we are wrapping it with Expanded
              children: Provider.of<StationsProvider>(context)
                  .stations
                  .where((station) => station.isFavorite)
                  .map((station) => StationWidget(
                onClicked: (){
                  // select the station
                  Provider.of<StationsProvider>(context, listen: false)
                      .selectStation(station);
                  clickFavStation();
                  moveMapToStation(station.y, station.x);
                },
                  station: station))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class StationSearchBar extends StatefulWidget {
  final Function onSelectStation;
  final Function onClearQuery;
  final MapController mapController;

  const StationSearchBar(
      {super.key,
      required this.onSelectStation,
      required this.onClearQuery,
      required this.mapController});

  @override
  State<StationSearchBar> createState() => _StationSearchBarState();
}

class _StationSearchBarState extends State<StationSearchBar> {
  String query = "";
  final FocusNode _focusNode = FocusNode();
  bool _hideSuggestions = true;
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];

  void onQueryChange(String newQuery) {
    setState(() {
      query = newQuery;
      // if(query.isEmpty){suggestions = [];}
      suggestions = getSuggestions(query,
          Provider.of<StationsProvider>(context, listen: false).stations);
    });
  }

  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && query.isEmpty) {
        setState(() {
          // suggestions = [];
        });
      } else {
        _hideSuggestions = false;
        setState(() {
          suggestions = getSuggestions(query,
              Provider.of<StationsProvider>(context, listen: false).stations);
        });
      }
    });
  }

  List<String> getSuggestions(String query, List<Station> stations) {
    return stations
        .where((station) =>
            station.name.toLowerCase().contains(query.toLowerCase()))
        .map((station) => station.name)
        .toList();
  }

  void hideSuggestions() {
    setState(() {
      _hideSuggestions = true;
    });
  }

  void moveMapToStation(double lat, double lon) {
    widget.mapController.move(LatLng(lat, lon), 16.0); // Adjust zoom if needed
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            left: (MediaQuery.of(context).size.width - 400) / 2, top: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              width: 400,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: onQueryChange,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Rechercher une station",
                  suffixIcon: IconButton(
                      // rechercher suggestion
                      onPressed: () {
                        setState(() {
                          var station;
                          // si la recherche correspond à une station
                          if (Provider.of<StationsProvider>(context,
                                  listen: false)
                              .stations
                              .where((station) => station.name == query)
                              .isNotEmpty) {
                            station = Provider.of<StationsProvider>(context,
                                    listen: false)
                                .stations
                                .firstWhere((station) => station.name == query);
                            Provider.of<StationsProvider>(context,
                                    listen: false)
                                .selectStation(station);
                            moveMapToStation(station.y, station.x);
                            widget.onSelectStation();
                          }
                        });
                      },
                      icon: const Icon(Icons.search)),
                  prefixIcon: IconButton(
                    onPressed: () {
                      _controller.clear();
                      hideSuggestions();
                      onQueryChange("");
                      //enlever la station selectionnée
                      Provider.of<StationsProvider>(context, listen: false)
                              .selectStation(Station("", "", 0, 0, 0.0, 0.0, false));
                      var station =
                          Provider.of<StationsProvider>(context, listen: false)
                              .closestStation;
                      moveMapToStation(station.y, station.x);
                      widget.onClearQuery();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            if (!_hideSuggestions)
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                width: 400,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView(
                  children: [
                    for (var suggestion in suggestions)
                      ListTile(
                        title: Text(suggestion),
                        onTap: () {
                          _controller.text = suggestion;
                          Station station;
                          station = Provider.of<StationsProvider>(context,
                                  listen: false)
                              .stations
                              .firstWhere(
                                  (station) => station.name == suggestion);
                          Provider.of<StationsProvider>(context, listen: false)
                              .selectStation(station);
                          setState(() {
                            hideSuggestions();
                            query = suggestion;
                            suggestions = [];
                            moveMapToStation(station.y, station.x);
                            widget.onSelectStation();
                          });
                        },
                      ),
                  ],
                ),
              )
          ],
        ));
  }
}

class MapWidget extends StatefulWidget {
  final Function onPinclick;
  final MapController mapController;

  const MapWidget(
      {super.key, required this.onPinclick, required this.mapController});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  void moveMapToStation(double lat, double lon) {
    widget.mapController.move(LatLng(lat, lon), 16.0); // Adjust zoom if needed
  }

  @override
  Widget build(BuildContext context) {
    var closestStation = Provider.of<StationsProvider>(context).closestStation;
    if(closestStation.x == 0 && closestStation.y == 0){
      return Center(child : CircularProgressIndicator());

    }
    else{
      return Container(
        margin: const EdgeInsets.only(top: 20),
        height: 300,
        width: 300,
        decoration: const BoxDecoration(
          color: Colors.blue,
        ),
        child: Center(
            child: FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter:
                LatLng(
                    Provider.of<StationsProvider>(context).closestStation.y,
                    Provider.of<StationsProvider>(context).closestStation.x),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'v_lille',
                ),
                // ajouter les markers pour les stations
                MarkerLayer(
                  markers: [
                    for (var station
                    in Provider.of<StationsProvider>(context).stations)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(station.y, station.x),
                        child: IconButton(
                          icon: Icon(
                            Icons.location_pin,
                            color: (station.name ==
                                Provider.of<StationsProvider>(context)
                                    .selectedStation
                                    .name ||
                                station.name ==
                                    Provider.of<StationsProvider>(context)
                                        .closestStation
                                        .name)
                                ? Colors.red
                                : Colors.blue,
                          ),
                          onPressed: () {
                            Provider.of<StationsProvider>(context, listen: false)
                                .selectStation(station);
                            moveMapToStation(station.y, station.x);
                            widget.onPinclick();
                          },
                        ),
                      ),
                    // current position marker point

                  ],
                ),

                RichAttributionWidget(attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ])
              ],
            )),
      );
    }
  }
}

// creer le theme de l'application
ThemeData theme = ThemeData(
    primaryColor: const Color(0xFFC62828),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.red, // Main red theme
      accentColor: const Color(0xFF6A1B9A), // Purple accent
    ).copyWith(
      secondary: const Color(0xFF6A1B9A),
      surface: Colors.white, // White background
      // For the buttons/icons
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Transparent for overlap
      elevation: 0,

      iconTheme: IconThemeData(
        color: Colors.white, // White icons for the AppBar
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // White background for the search bar
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
            color: Color(0xFFC62828)), // Red border when focused
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black87, // Dark text for most content
        fontSize: 18,
      ),
      headlineSmall: TextStyle(
        color: Color(0xFFC62828), // Red for headers
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.black, // Darker text for larger headlines
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFE5FD), // Purple button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
