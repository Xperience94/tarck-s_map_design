////////////////////////////////////////////////////////////////////////
///////////////////////// Author : HUGO LOPES //////////////////////////
////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'view_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> myProducts = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseFirestore.instance
      .collection('alltracks')
      .get()
      .then((snapshot) {
    myProducts.clear();
    for (DocumentSnapshot doc in snapshot.docs) {
      //doc.reference.delete();
      myProducts.add(doc.get("String"));
      //print(mylocation.latitude);
      //print(mylocation.longitude);
    }
  });
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
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Tracks_geo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final _firestore = FirebaseFirestore.instance;

class _MyHomePageState extends State<MyHomePage> {
  int value = 0;
  //List<String> myProducts = [];
  List<String> test_array = [];
  @override
  void initState() {
    super.initState();
  }

  // ignore: non_constant_identifier_names
  void delete_tarck_pist(int index) {
    _firestore.collection(myProducts[index]).get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    //le supprimer de la liste de alltracks
    _firestore.collection('alltracks').get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        int taille = myProducts.length;
        if (doc.get("String") == myProducts[index]) {
          doc.reference.delete();
        }
      }
      setState(() {
        myProducts.removeAt(index);
      });
    });
  }

  final myController = TextEditingController();
  String namecircuit = "";
  double oppa = 0.1;
  double oppa_array = 1;
  double oppa_button = 1;
  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      //backgroundColor: Colors.white.withOpacity(0.1),
      title: const Text('Select a name'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: myController,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            setState(() {
              value++;
              myProducts.add(myController
                  .text); //on ajoute dans la liste affichage le nom de la piste
              //myProducts.add("Track $value");
            });
            //j'ajoute dans cette collection tout les noms des piste creer
            _firestore
                .collection('alltracks')
                .add({'String': myController.text}).then((_) {
              print('added ${myController.text} successfully');
            });
            Navigator.of(context).pop();
            myController.clear();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text(
            'Create',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  bool Show_array = false, Show_button = false;
  String explication = "Vous pouvez enregistrer le tracer de vos circuits";

  final keyIsFirstLoaded = 'is_first_loaded';
  showDialogIfFirstLoaded(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLoaded = prefs.getBool(keyIsFirstLoaded);
    if (isFirstLoaded == false) {
      return;
    }
    prefs.setBool(keyIsFirstLoaded, false);
    setState(() {
      oppa_array = 0.1;
      oppa_button = 0.1;
    });
    showDialog(
      context: context,
      //barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter teststate) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Presentation"),
            content: Text(
              explication,
              //style: TextStyle(backgroundColor: Colors.white),
            ),
            actionsAlignment: MainAxisAlignment.end,
            backgroundColor: Colors.white.withOpacity(0.7),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: const Text(
                  'Suivant',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  //creation de deux variable Show_array et Show_button
                  if (Show_array == false && Show_button == false) {
                    //on augmente l'opacité du tableau
                    teststate(() => explication =
                        "voici la liste des circuit sur lequelle sont enregistrer vos circuit !");
                    setState(() {
                      oppa_array = 1;
                      oppa_button = 0.1;
                      Show_array = true;
                    });

                    //Navigator.of(context).pop();
                  } else if (Show_array == true && Show_button == false) {
                    //on augmente l'opacité du button
                    teststate(() => explication =
                        "Voici le bouton qui permet de creer de nouveau circuit !");
                    setState(() {
                      oppa_button = 1;
                      oppa_array = 0.1;
                      Show_button = true;
                    });

                    //Navigator.of(context).pop();
                  } else {
                    // Close the dialog
                    setState(() {
                      oppa_button = 1;
                      oppa_array = 1;
                    });
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();
                    //Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //recuperer les infos dans la base de donnée et remplire la liste
    final test = _firestore.toString();
    // setState(() {
    //   getData();
    // });
    Future.delayed(Duration.zero, () => showDialogIfFirstLoaded(context));
    // setState(() {
    //   myProducts = List.from(test_array);
    // });
    //Future.delayed(Duration.zero, () => _buildPopupExplication(context));
    //myProducts.add("test");

    // QuerySnapshot querySnapshot = await _firestore.collection("collection").get();
    // for (int i = 0; i < querySnapshot.docs.length; i++) {
    //   var a = querySnapshot.docs[i];
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
              return Card(
                //color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewMap(
                                title: myProducts[index],
                                //je lui donne le nom de la piste
                                track: myProducts[index],
                                //track: index,
                              )),
                    );
                  },
                  // In many cases, the key isn't mandatory

                  title: Text(
                    myProducts[index],
                    style:
                        TextStyle(color: Colors.black.withOpacity(oppa_array)),
                  ),
                  leading: const Icon(
                    Icons.car_repair_outlined,
                    color: Colors.black,
                  ),
                  trailing: IconButton(
                    color: Colors.black,
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      //appeller la fonction qui va supprimer les tarce sur firebase
                      delete_tarck_pist(index);
                    },
                  ),
                  key: UniqueKey(),
                ),
                // child: Padding(
                //     padding: const EdgeInsets.all(10),
                //     child: Text(myProducts[index])),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            barrierColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
        label: Text("New Track"),
        icon: const Icon(Icons.directions_boat),
        backgroundColor: Colors.orange.withOpacity(oppa_button),
        foregroundColor: Colors.black.withOpacity(oppa_button),
      ),
    );
  }
}
