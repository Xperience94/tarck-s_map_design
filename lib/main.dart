// ignore_for_file: deprecated_member_use, unnecessary_new

import 'package:flutter/material.dart';
import 'view_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<String> myProducts = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("dans le main");

  await FirebaseFirestore.instance
      .collection('alltracks')
      .get()
      .then((snapshot) {
    myProducts.clear();
    for (DocumentSnapshot doc in snapshot.docs) {
      //doc.reference.delete();
      print(doc.get("String"));
      //value++;
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
        primarySwatch: Colors.blue,
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
    print(myProducts[index]);
    _firestore.collection(myProducts[index]).get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    //le supprimer de la liste de alltracks
    _firestore.collection('alltracks').get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        print("ce que je vois sur firebase " + doc.get("String"));
        int taille = myProducts.length;
        print("le nom de ma pist $taille ");
        if (doc.get("String") == myProducts[index]) {
          doc.reference.delete();
        }
      }
      setState(() {
        myProducts.removeAt(index);
        //value--;
        print("je passe ici pour supprimer une item de la list");
      });
    });
  }

  final myController = TextEditingController();
  String namecircuit = "";
  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
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
            print("j'affiche un truc");
            print(myController.text);
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
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //recuperer les infos dans la base de donnée et remplire la liste
    final test = _firestore.toString();
    print(test);
    // setState(() {
    //   getData();
    // });
    print("je suis la"); //quand je lance l'app il ne passe par la par
    print(myProducts);
    // setState(() {
    //   myProducts = List.from(test_array);
    // });

    //myProducts.add("test");

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
              return Card(
                child: ListTile(
                  onTap: () {
                    print(myProducts[index]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewMap(
                                title: 'your track',
                                //je lui donne le nom de la piste
                                track: myProducts[index],
                                //track: index,
                              )),
                    );
                  },
                  // In many cases, the key isn't mandatory

                  title: Text(myProducts[index]),
                  leading: const Icon(Icons.car_repair_outlined),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      print("je supprime la card");
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
          print("je rentre dans le bouton pour add list");
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
        label: Text("New Track"),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}
