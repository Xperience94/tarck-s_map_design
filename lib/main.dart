import 'package:flutter/material.dart';
import 'view_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter ScrollableListTabView Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final myProducts = List<String>.generate(1, (i) => 'Track $i');
final _firestore = FirebaseFirestore.instance;

class _MyHomePageState extends State<MyHomePage> {
  int value = 0;
  @override
  Widget build(BuildContext context) {
    //recuperer les infos dans la base de donnée et remplire la liste
    final test = _firestore.toString();
    print(test);
    // QuerySnapshot querySnapshot = await _firestore.collection("collection").get();
    // for (int i = 0; i < querySnapshot.docs.length; i++) {
    //   var a = querySnapshot.docs[i];
    //   print(a.id);
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        // Use ListView.builder
        child: ListView.builder(
            // the number of items in the list
            itemCount: myProducts.length,

            // display each item of the product list
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  print(myProducts[index]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewMap(
                              title: 'your track',
                              track: index,
                            )),
                  );
                },
                // In many cases, the key isn't mandatory
                key: UniqueKey(),
                title: Text(myProducts[index]),
                // child: Padding(
                //     padding: const EdgeInsets.all(10),
                //     child: Text(myProducts[index])),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print("je rentre dans le bouton pour add list");
          setState(() {
            value++;
            myProducts.add("Track $value");
          });
        },
        label: Text("New Track"),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}
