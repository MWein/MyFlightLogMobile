import 'package:flutter/material.dart';
import './editFlightLog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFlightLogMobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'MyFlightLogMobile'),

      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/flight': (context) => EditFlightLogPage(),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage() : super();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Log Mobile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),

            IconButton(
              icon: Icon(Icons.history),
              color: Colors.lightBlue,
              iconSize: 150.0,
              onPressed: () {
                Navigator.pushNamed(context, '/flight');
              }
            ),

            Spacer(),

            IconButton(
              icon: Icon(Icons.build),
              color: Colors.lightBlue,
              iconSize: 150.0,
            ),

            Spacer(),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
