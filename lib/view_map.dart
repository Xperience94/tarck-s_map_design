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

class ArrayInfo {
  late List<Position> positionArray;
  late List<double> speedArray;
}

class _ViewMapState extends State<ViewMap> {
  int _counter = 0;
  String nameButton = 'START';
  String _end = "Start";
  late Timer timer;
  late MapController _mapController;
  final List<LatLng> _polyline = [];
  final List<Polyline> _poly = [];
  final List<LatLng> _polybis = [];
  final List<LatLng> _polybis2 = [];
  List<Polyline> polylines_test = [];
  final List<Position> positionArray = [];
  List<double> speedArray = [];
  final List<Color> _color = [Colors.purple, Colors.pink];
  int test_cpt_tag = 0;
  final _firestore = FirebaseFirestore.instance;
  late String _trackName;
  late StreamSubscription<Position> _positionStreamSubscription;
  late StreamSubscription<Position> _positionStreamSubscription_pin;
  int positionstreambegin = 0;
  int var_test = 1;
  List<Marker> _markers = <Marker>[];
  double speedMin = 0;
  double speedMax = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    active_geoloc();
    setState(() {
      polylines_test.add(Polyline(
          points: [])); // je l'initialise une fois puis ensuite je vais le remplir dans fonction "TO COMPLETE"
      polylines_test[0].color = Color.fromARGB(255, 222, 136, 6);
      polylines_test[0].strokeWidth = 4.0;
    });

    ////////////////////// le code qu'il faut utiliser et le mettre en commentaire plus bas /////////////////

    ///call function for routes and pin to put on a map
    tracePin();
    tracePolyline();

    //   print("je rentre la ");

    //timer = Timer.periodic(const Duration(seconds: 2), (Timer t) => _measure());
    print("je rentre la dans le init() quand");
    print(widget.track);
    _polyline.clear(); //flush all point
    _polybis.clear();
    _polybis2.clear();
    _firestore.collection(widget.track).get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        //     //doc.reference.delete();
        final mylocation = doc.get("position")["geopoint"];
        setState(() {
          _polyline.add(LatLng(mylocation.latitude, mylocation.longitude));
          // _polybis.add(
          //     LatLng(mylocation.latitude + 5.0, mylocation.longitude + 5.0));
        });
        //print(_polyline);
      }
    });
    //je recupere tout ce qu'il  y a sur la base de donée et je l'affiche sur la map
    // setState(() {
    //   _polyline.clear(); //flush all point
    //   //free all the data in the firebase
    //   _firestore.collection(_trackName).get().then((snapshot) {
    //     for (DocumentSnapshot doc in snapshot.docs) {
    //       //doc.reference.delete();
    //       final mylocation = doc.get("position")["geopoint"];
    //       //print(mylocation.latitude);
    //       //print(mylocation.longitude);
    //       _polyline.add(mylocation);
    //     }
    //   });

    //   //.add({'geohash': 'track', 'position': myLocation.data}).then((_) {
    //   //print('added ${myLocation.hash} successfully');
    // });
  }

  void tracePin() {
    final positionStream = Geolocator.getPositionStream();
    _positionStreamSubscription_pin = positionStream.handleError((error) {
      //_positionStreamSubscription?.cancel();
      print("il y a une erreur dans le stream ");
      //_positionStreamSubscription = null;
    }).listen((position) {
      setState(() {
        //useless but Markerlayer option m'oblige a prendre list<Marker>
        _markers.clear();
        _markers.add(
          Marker(
              point: LatLng(position.latitude, position.longitude),
              builder: (ctx) => const Icon(Icons.location_on_outlined)),
        );
      });
    });
    //_positionStreamSubscription_pin.pause();
    //_positionStreamSubscription_pin.cancel();
  }

  void changePinMarker() {
    //_positionStreamSubscription_pin.resume();
  }

  void tracePolyline() async {
    final positionStream = Geolocator.getPositionStream();
    _positionStreamSubscription = positionStream.handleError((error) {
      //_positionStreamSubscription?.cancel();
      print("il y a une erreur dans le stream ");
      //_positionStreamSubscription = null;
    }).listen((position) {
      ////////////////////////
      if (_insideListen == 1) {
        _insideListen = 0;
      }
      var speedInMps = position.speed; // this is your speed
      ///////////////////////
      print(speedInMps);
      setState(() {
        print("je suis la 1");
        ////je fais le tracer initiale et j'ecris tout les infos dans la base de donnée (vitesse et position )
        polylines_test[0]
            .points
            .add(LatLng(position.latitude, position.longitude));
        print("je suis la 2");
        //////////////////////////////////////
      });
      print("j'affiche le polyline");

      final geo = Geoflutterfire();
      GeoFirePoint myLocation =
          geo.point(latitude: position.latitude, longitude: position.longitude);
      print("je passe ici");
      _firestore.collection(_trackName).add({
        'geohash': 'track',
        'position': myLocation.data,
        'speed': speedInMps
      }).then((_) {
        print('added ${myLocation.hash} successfully');
      });
    });
    //je le desactive je le reactive au moment de l'appuis sur le bouton
    _positionStreamSubscription.pause();
    //_positionStreamSubscription.cancel();
  }

  Future<void> active_geoloc() async {
    LocationPermission permission = await Geolocator.checkPermission();
    LocationPermission permission_bis = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController.move(LatLng(position.latitude, position.longitude), 18);
  }

  //fonction appeller toute les 2 seconde non utiliser.
  Future<void> _measure() async {
    return;
  }

  Future<void> getAllDataFromDB() async {
    //position and speed
    ///Creation 2 array speed and position
    //get all data from the BDD speed and the position

    return _firestore.collection(widget.track).get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        //     //doc.reference.delete();
        print(doc.get("position")["geopoint"]);
        print(doc.get("speed"));
        setState(() {
          speedArray.add(doc.get("speed"));
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
    speedMax = 0.0;
    for (var i = 0; i < speedArray.length; i++) {
      if (speedArray[i] > speedMax) {
        speedMax = speedArray[i];
      }
    }
    //return speedMax;
  }

  void findMinSpeed() {
    speedMin = 100000.0;
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
    //give in argument 2 array with the same size
    double epsilon = (speedMax - speedMin) / 3;
    int change = -1;
    int indexDrawPolyline = -1;

    polylines_test = []; // flush the all the draw of the track
    for (var i = 0; i < positionArray.length; i++) {
      if (speedArray[i] < (speedMin + epsilon)) {
        if (change != 1) {
          polylines_test
              .add(Polyline(points: [], color: Colors.blue, strokeWidth: 4.0));
          change = 1;
          indexDrawPolyline++;
        }
        //fill the polyline with the color blue
        polylines_test[indexDrawPolyline]
            .points
            .add(LatLng(positionArray[i].latitude, positionArray[i].longitude));
        continue;
      }
      if (speedArray[i] >= (speedMin + epsilon) &&
          speedArray[i] < (speedMin + (2 * epsilon))) {
        if (change != 2) {
          polylines_test.add(
              Polyline(points: [], color: Colors.orange, strokeWidth: 4.0));
          change = 2;
          indexDrawPolyline++;
        }
        //fill the polyline with the color orange
        polylines_test[indexDrawPolyline]
            .points
            .add(LatLng(positionArray[i].latitude, positionArray[i].longitude));
        continue;
      }
      if (speedArray[i] >= (speedMin + (2 * epsilon))) {
        if (change != 3) {
          polylines_test
              .add(Polyline(points: [], color: Colors.red, strokeWidth: 4.0));
          change = 3;
          indexDrawPolyline++;
        }
        //fill the polyline with the color red
        polylines_test[indexDrawPolyline]
            .points
            .add(LatLng(positionArray[i].latitude, positionArray[i].longitude));
        continue;
      }
    }

    return;
  }

  int cpt = 0;
  late StreamSubscription<loc.LocationData> locationSubscription;
  int _insideListen = 1;
  //TO-DO change the name of the function
  Future<void> _incrementCounter() async {
    print("je rentre dans_incrementCounter _end : " + _end);
    if (_end == "Start") {
      //_positionStreamSubscription.resume();
      setState(() {
        nameButton = "END !";
        _end = "Done";
      });
      //Zomm in
      // Position position = await Geolocator.getCurrentPosition(
      //     desiredAccuracy: LocationAccuracy.high);
      // setState(() {
      //   _mapController.move(LatLng(position.latitude, position.longitude), 16);
      // });

      /// reactive the polyline
      _positionStreamSubscription.resume();
      positionstreambegin = 1;
      late Position test;
      print(
          "je suis dans le _incrementCounter au moment de l'init du stream de la localisation");
    } else if (_end == "Done") {
      _insideListen = 1;

      //var tab = ArrayInfo();
      ///getting all the information from the database speed and position
      ///passer par une class
      ///malgres l'utilisation de la class je n'arrive pas a enregistrer les informations reçue par la bdd

      final forecast = await getAllDataFromDB();

      //print(tab.speedArray);

      ///

      ///
      //positionArray = tab[0];
      //speedArray = tab[1];

      ///function that return the maxspeed and the minspeed

      ///retrace the route
      retraceRoute();

      //timer.cancel();
      setState(() {
        nameButton = "START";
        _end = "Start";
      });
      if (_positionStreamSubscription != null) {
        print("yoooo");
        _positionStreamSubscription.pause();
        //_positionStreamSubscription.cancel();
      }
      // locationSubscription.cancel();
      // locationSubscription.resume();
    } else {
      //pr)
    }
    // This call to setState tells the Flutter framework that something has
    // changed in this State, which causes it to rerun the build method below
    // so that the display can reflect the updated values. If we changed
    // _counter without calling setState(), then the build method would not be
    // called again, and so nothing would appear to happen.
    //_counter++;
    //});
  }

  _localisation() {
    changePinMarker();
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    print("je rentre la a chaque que je bouge la map ");
  }

  void refresh() {
    //fonction qui pose probleme, censer marcher de façon theorique.
    setState(() {
      _markers
          .clear(); //j'enleve le marker initial qui represente le point de depart.

      _polyline.clear(); //flush all point
      _poly.clear();
      //free all the data in the firebase
      _firestore.collection(widget.track).get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      //.add({'geohash': 'track', 'position': myLocation.data}).then((_) {
      //print('added ${myLocation.hash} successfully');
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
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            onPositionChanged: _onPositionChanged,
            plugins: [
              TappablePolylineMapPlugin(),
            ],
            center: LatLng(45.1313258, 5.5171205),
            zoom: 11.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            PolylineLayerOptions(
              //polylineCulling: true,
              polylines: polylines_test,
              // [
              //   Polyline(
              //     points: _polyline,
              //     strokeWidth: 4.0,
              //     color: Color.fromARGB(255, 253, 173, 0),
              //   ),
              //   Polyline(
              //     points: _polybis,
              //     strokeWidth: 4.0,
              //     color: Color.fromARGB(255, 0, 253, 59),
              //   ),
              //   Polyline(
              //     points: _polybis2,
              //     strokeWidth: 4.0,
              //     color: Color.fromARGB(255, 87, 54, 172),
              //   ),
              // ]
            ),
            //PolylineLayerOptions(polylines: _poly),

            MarkerLayerOptions(markers: _markers) // le probleme n'est pas la
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
                      print("j'ai appuyer sur le bouton : " + nameButton);
                      _incrementCounter();
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
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                    heroTag: "btn3",
                    // backgroundColor: Color(0XFF0D325E),
                    backgroundColor: Colors.orange,
                    // child: Icon(Icons.refresh),
                    child: const Icon(Icons.location_on),
                    onPressed: () {
                      print("je m'auto localise");
                      _localisation();
                    }),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        print("je suis la dans le willpop");
        //timer.cancel();
        if (positionstreambegin == 0) {
          return true;
        }

        if (_positionStreamSubscription != null) {
          print("je rentre la dans le if de fin");

          _positionStreamSubscription.pause();
          _positionStreamSubscription.cancel();
        }
        _positionStreamSubscription_pin.pause();
        _positionStreamSubscription_pin.cancel();
        print("je suis a la fin de willpop");
        return true;
      },
    ); //);
  }
}
