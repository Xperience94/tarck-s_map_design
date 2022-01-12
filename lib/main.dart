import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Track\'s Demo tracking'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String nameButton = 'Start';
  String _end = "Start";
  late Timer timer;
  late MapController _mapController;
  final List<LatLng> _polyline = [];

  @override
  void initState() {
    super.initState();
    active_geoloc();
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) => _measure());
    _mapController = MapController();
  }

  Future<void> active_geoloc() async {
    //a verifier si il marche vraiment
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _measure() async {
    print("je rentre dans la measure pour ajuster ");
    if (_end == "Done") {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(position.latitude);

      //print(position.latitude);
      //_mapController.move(LatLng(lat, long), 16);
      _polyline.add(LatLng(
          position.latitude, position.longitude)); //add the line to the map
    } else {
      print("je fais rien ");
    }
  }

  void _incrementCounter() {
    setState(() {
      //change the name of the button
      if (_end == "Start") {
        setState(() {
          nameButton = "Save !";
          _end = "Done";
        });
      } else if (_end == "Done") {
        setState(() {
          nameButton = "Start";
          _end = "Start";
        });
      }
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    print("je rentre la a chaque que je bouge la map ");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
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
              backgroundColor: Color(0XFF0D325E),
              child: const Icon(Icons.refresh),
              //label: const Text("test"),
              onPressed: () {
                //call a function to reset everything
              },
            ),
          ),
        ],
      ),
    );
  }
}
