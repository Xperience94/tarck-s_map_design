import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
//import 'package:latlong/latlong.dart';
import 'package:latlong2/latlong.dart';
//import 'package:latlng/latlng.dart';

// void main() {
//   runApp(const MyApp());
// }

class ViewMap extends StatefulWidget {
  ViewMap({Key? key, required this.title, required this.track})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
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
  int _counter = 0;
  String nameButton = 'Start';
  String _end = "Start";
  late Timer timer;
  late MapController _mapController;
  final List<LatLng> _polyline = [];
  final _firestore = FirebaseFirestore.instance;
  late String _trackName;
  late StreamSubscription<Position> _positionStreamSubscription;
  @override
  void initState() {
    super.initState();
    active_geoloc();
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) => _measure());
    _mapController = MapController();
    print("je rentre la dans le init() quand");
    //je recupere tout ce qu'il  y a sur la base de donée et je l'affiche sur la map
    // setState(() {
    //   _polyline.clear(); //flush all point
    //   //free all the data in the firebase
    //   _firestore.collection('test$_trackName').get().then((snapshot) {
    //     for (DocumentSnapshot doc in snapshot.docs) {
    //       //doc.reference.delete();
    //       final mylocation = doc.data();
    //       print(mylocation);
    //     }
    //   });

    //.add({'geohash': 'track', 'position': myLocation.data}).then((_) {
    //print('added ${myLocation.hash} successfully');
    // });
  }

  Future<void> active_geoloc() async {
    //a verifier si il marche vraiment
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController.move(LatLng(position.latitude, position.longitude), 16);
  }

//fonction appeller toute les 2 seconde et met a jour la position de l'iutilisateur
  Future<void> _measure() async {
    setState(() async {
      print("je rentre dans la measure pour ajuster ");
      if (_end == "Done") {
        //print("je passe la 1");
        final geo = Geoflutterfire();
        CollectionReference test =
            FirebaseFirestore.instance.collection(_trackName);
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        GeoFirePoint myLocation = geo.point(
            latitude: position.latitude, longitude: position.longitude);

        _firestore
            .collection(_trackName)
            .add({'geohash': 'track', 'position': myLocation.data}).then((_) {
          print('added ${myLocation.hash} successfully');
        });
        //print("je passe la 2");
        print(position.latitude);
        //print(position.latitude);
        //_mapController.move(LatLng(lat, long), 16);
        //_mapController.move(LatLng(position.latitude, position.longitude), 16);
        _polyline.add(LatLng(
            position.latitude, position.longitude)); //add the line to the map

      } else {
        print("je fais rien ");
      }
    });
  }

  Future<void> _incrementCounter() async {
    //setState(() {
    //change the name of the button
    if (_end == "Start") {
      setState(() {
        nameButton = "Save !";
        _end = "Done";
      });
      //Zomm in
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _mapController.move(LatLng(position.latitude, position.longitude), 16);
      final positionStream = Geolocator.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        print("il y a une erreur dans le stream ");
        //_positionStreamSubscription = null;
      }).listen((position) {
        _polyline.add(LatLng(position.latitude, position.longitude));
        final geo = Geoflutterfire();
        GeoFirePoint myLocation = geo.point(
            latitude: position.latitude, longitude: position.longitude);
        _firestore
            .collection(_trackName)
            .add({'geohash': 'track', 'position': myLocation.data}).then((_) {
          print('added ${myLocation.hash} successfully');
        });
      });
    } else if (_end == "Done") {
      setState(() {
        nameButton = "Start";
        _end = "Start";
      });
      _positionStreamSubscription.pause();
      _positionStreamSubscription.cancel();
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
    print("je rentre la a chaque que je bouge la map ");
  }

  void refresh() {
    setState(() {
      _polyline.clear(); //flush all point
      //free all the data in the firebase
      _firestore.collection(_trackName).get().then((snapshot) {
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
    setState(() {
      //zom in
      // Position position = await Geolocator.getCurrentPosition(
      //     desiredAccuracy: LocationAccuracy.high);
      // _mapController.move(LatLng(position.latitude, position.longitude), 16);

      _polyline.clear(); //flush all point
      //free all the data in the firebase
      _firestore.collection(_trackName).get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          //doc.reference.delete();
          final mylocation = doc.get("position")["geopoint"];
          //print(mylocation.latitude);
          //print(mylocation.longitude);
          _polyline.add(mylocation);
        }
      });

      //.add({'geohash': 'track', 'position': myLocation.data}).then((_) {
      //print('added ${myLocation.hash} successfully');
    });
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
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
            polylines: [
              Polyline(
                points: _polyline,
                strokeWidth: 10.0,
                color: const Color.fromRGBO(0, 179, 253, 0.8),
              ),
            ],
          ),
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
                  backgroundColor: Colors.red,
                  // child: Icon(Icons.refresh),
                  label: Text(nameButton),
                  onPressed: () {
                    _incrementCounter();
                  }),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: const Color(0XFF0D325E),
              child: const Icon(Icons.refresh),
              //label: const Text("test"),
              onPressed: () {
                refresh();
                //call a function to reset everything
              },
            ),
          ),
        ],
      ),
    );
  }
}
