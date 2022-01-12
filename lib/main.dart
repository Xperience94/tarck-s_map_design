import 'package:flutter/material.dart';
import 'package:scrollable_list_tabview/scrollable_list_tabview.dart';

void main() {
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
      home: MyHomePage(title: 'Flutter ScrollableListTabView Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final myProducts = List<String>.generate(1000, (i) => 'Product $i');

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
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
                  },
                  // In many cases, the key isn't mandatory
                  key: UniqueKey(),
                  title: Text(myProducts[index]),
                  // child: Padding(
                  //     padding: const EdgeInsets.all(10),
                  //     child: Text(myProducts[index])),
                );
              }),
        ));
  }
}
