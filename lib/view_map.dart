////////////////////////////////////////////////////////////////////////
///////////////////////// Author : HUGO LOPES //////////////////////////
////////////////////////////////////////////////////////////////////////
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:location/location.dart' as loc;
import 'firebase_options.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:latlong2/latlong.dart';

//import 'package:latlng/latlng.dart';

class ViewMap extends StatefulWidget {
  ViewMap({Key? key, required this.title, required this.track})
      : super(key: key);

  // widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  String track;

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  String nameButton = 'START';
  late MapController _mapController;
  List<LatLng> positionList = [];
  List<Color>? gradientColorsList = [];
  List<Position> positionArray = [];
  List<int> speedArray = [];
  final _firestore = FirebaseFirestore.instance;
  late String _trackName;
  late StreamSubscription<Position> _positionStreamSubscription;
  int positionstreambegin = 0;
  Position? currentLocation;
  int speedMin = 0;
  int speedMax = 0;

  @override
  void initState() {
    Check_geoloc();
    getCurrentLocation();
    setState(() {
      gradientColorsList!.add(Colors.orange);
    });

    retraceRace(); //
    super.initState();
    print("je rentre dans le init() ");

    //timer = Timer.periodic(const Duration(seconds: 2), (Timer t) => _measure());
  }

  void retraceRace() async {
    /*

    Fonction qui est appelé lorsque l'on veut recuperer ces tracé precedent sur ce circuit 
    La fonction va dans un premier temps recuperer les information dans la BDD puis faire le tarcer du circuit

    */
    print("avant appelle de la fonction");
    final forecast = await getAllDataFromDB();
    print("apres appelle de la fonction");
    retraceRoute();
  }

  void getCurrentLocation() async {
    /*

    Fonction qui active le stream sur la position de l'utilisateur : 
      - Afin de le reperer sur la map 
      - de pourvoir faire le tracer de sa course

     */
    loc.Location location = loc.Location();
    double latitude;
    await location.getLocation().then((location) => {
          setState(() {
            currentLocation = Position(
                longitude: location.longitude!,
                latitude: location.latitude!,
                timestamp: DateTime(0),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0);
          })
        });
    _mapController = await MapController();
    final positionStream = Geolocator.getPositionStream();
    _positionStreamSubscription = positionStream.handleError((error) {
      //_positionStreamSubscription?.cancel();
      print("il y a une erreur dans le stream ");
      //_positionStreamSubscription = null;
    }).listen((position) {
      print(position);
      setState(() {
        currentLocation = position;
        _mapController.move(LatLng(position.latitude, position.longitude), 17);
      });

      var speedInMps = position.speed;
      //j'appuie sur le bouton
      if (nameButton == "END !") {
        setState(() {
          positionList.add(LatLng(position.latitude, position.longitude));

          // polylines_test[0]
          //     .points
          //     .add(LatLng(position.latitude, position.longitude));
        });
        final geo = Geoflutterfire();
        GeoFirePoint myLocation = geo.point(
            latitude: position.latitude, longitude: position.longitude);
        _firestore.collection(_trackName).add({
          'geohash': 'track',
          'position': myLocation.data,
          'speed': speedInMps.toInt(),
          'time': DateTime.now()
              .millisecondsSinceEpoch //time rajouter afin de permetre de le trier par la suite
        }).then((_) {
          print('added ${myLocation.hash} successfully');
        });
      }
    });
    //je le desactive je le reactive au moment de l'appuis sur le bouton
    //_positionStreamSubscription.pause();
    //_positionStreamSubscription.cancel();
  }

  Future<void> Check_geoloc() async {
    /* 

    Fonction qui permet de verifier les permission de geolocalisation 

    */
    LocationPermission checkPermi = await Geolocator.checkPermission();
    LocationPermission askPermi = await Geolocator.requestPermission();
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // _mapController.move(LatLng(position.latitude, position.longitude), 18);
  }

  //fonction appeller toute les 2 seconde non utiliser.
  Future<void> _measure() async {
    return;
  }

  Future<void> getAllDataFromDB() async {
    /*
      fill 2 array speed and position
      get all data from the BDD speed and the position
    */
    return _firestore
        .collection(widget.track)
        .orderBy('time')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        //     //doc.reference.delete();
        print(doc.get("position")["geopoint"]);
        print(doc.get("speed"));
        print(doc.get('time'));
        setState(() {
          speedArray.add((doc.get("speed")).toInt());
        });
        Position pos = Position(
            longitude: doc.get("position")["geopoint"].longitude,
            latitude: doc.get("position")["geopoint"].latitude,
            timestamp: DateTime(0),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0);
        positionArray.add(pos);
      }
      findMaxSpeed();
      findMinSpeed();
    });
  }

  void findMaxSpeed() {
    /*
      Fonction qui va trouver la vitesse max recuperer au preavant dans BDD
    
     */
    speedMax = 0;
    for (var i = 0; i < speedArray.length; i++) {
      if (speedArray[i] > speedMax) {
        speedMax = speedArray[i];
      }
    }
  }

  void findMinSpeed() {
    /*
      Fonction qui va trouver la vitesse min recuperer au preavant dans BDD
    
     */
    speedMin = 100000;
    print("j'affiche la taille du tableau");
    print(speedArray.length);
    for (var i = 0; i < speedArray.length; i++) {
      if (speedArray[i] < speedMin) {
        speedMin = speedArray[i];
      }
    }
    //return speedMin;
  }

  void retraceRoute() {
    /*
      Fonction qui va remplire le tableau...  A finir
    
     */
    double epsilon = (speedMax - speedMin) / 3;
    int change = -1;
    int indexDrawPolyline = -1;

    //on flush les deux tableau pour reconstruire le tracer depuis la bdd
    setState(() {
      positionList.clear();
      gradientColorsList!.clear();
    });

    for (var i = positionArray.length - 1; i >= 0; i--) {
      if (speedArray[i] < (speedMin + epsilon)) {
        //fill the polyline with the color blue
        setState(() {
          positionList.add(
              LatLng(positionArray[i].latitude, positionArray[i].longitude));
          gradientColorsList!.add(Colors.blue);
        });
        continue;
      }
      if (speedArray[i] >= (speedMin + epsilon) &&
          speedArray[i] <= (speedMin + (2 * epsilon))) {
        setState(() {
          positionList.add(
              LatLng(positionArray[i].latitude, positionArray[i].longitude));
          gradientColorsList!.add(Colors.orange);
        });
        continue;
      }
      if (speedArray[i] > (speedMin + (2 * epsilon))) {
        setState(() {
          positionList.add(
              LatLng(positionArray[i].latitude, positionArray[i].longitude));
          gradientColorsList!.add(Colors.red);
        });
        continue;
      }
    }

    return;
  }

  Future<void> startRace() async {
    /*
      Fonction qui va mettre a jour la variable globale qui correspond au nom  du bouton. 
      pour le esle nous allons rappeller chaque position ecris au paravant dans la BDD et puis nous allons
      affecter a chaque points une couleurs selon la vitesse enregistrer
    
     */
    if (nameButton == "START") {
      //_positionStreamSubscription.resume();
      setState(() {
        nameButton = "END !";
      });

      positionstreambegin = 1;
      print(
          "je suis dans le startRace au moment de l'init du stream de la localisation");
    } else if (nameButton == "END !") {
      speedArray = [];
      positionArray = [];
      final forecast = await getAllDataFromDB();

      ///retrace the route
      retraceRoute();
      setState(() {
        nameButton = "START";
      });
    }
    // This call to setState tells the Flutter framework that something has
    // changed in this State, which causes it to rerun the build method below
    // so that the display can reflect the updated values. If we changed
    // _counter without calling setState(), then the build method would not be
    // called again, and so nothing would appear to happen.
    //_counter++;
    //});
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    /*
      Lorsque je bouge la map je rentrer dans cette fonction
    
     */
    print("je rentre la a chaque que je bouge la map ");
  }

  void refresh() {
    /*
      Fonction qui va supprimer que ce soit sur la map ou les positions enregistrer dans la BDD

     */
    setState(() {
      positionList.clear();
      gradientColorsList!.clear();
      gradientColorsList!.add(Colors.orange);
      //free all the data in the firebase
      _firestore.collection(widget.track).get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _trackName = widget.track;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the ViewMap object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: currentLocation == null
            ? const Text("Loading")
            : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onPositionChanged: _onPositionChanged,
                  plugins: [
                    TappablePolylineMapPlugin(),
                  ],
                  center: LatLng(
                      currentLocation!.latitude, currentLocation!.longitude),
                  zoom: 17.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  PolylineLayerOptions(
                    //polylineCulling: true,
                    polylines: [
                      Polyline(
                          points: positionList,
                          gradientColors: gradientColorsList,
                          strokeWidth: 4.0)
                    ],
                  ),
                  //PolylineLayerOptions(polylines: _poly),

                  MarkerLayerOptions(markers: [
                    Marker(
                        point: LatLng(currentLocation!.latitude,
                            currentLocation!.longitude),
                        builder: (ctx) =>
                            const Icon(Icons.location_on_outlined)),
                  ]) // le probleme n'est pas la
                ],
              ),
        floatingActionButton: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 70),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                    heroTag: "btn1",
                    // backgroundColor: Color(0XFF0D325E),
                    backgroundColor: Colors.orange,
                    // child: Icon(Icons.refresh),
                    label: Text(
                      nameButton,
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      startRace();
                    }),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "btn2",
                backgroundColor: Colors.black,
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                //label: const Text("test"),
                onPressed: () {
                  refresh();
                  //call a function to reset everything
                },
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        _positionStreamSubscription.pause();
        _positionStreamSubscription.cancel();
        return true;
      },
    ); //);
  }
}
