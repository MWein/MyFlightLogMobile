import 'package:flutter/material.dart';


class FlightLogPage extends StatefulWidget {
  FlightLogPage() : super();

  @override
  _FlightLogPageState createState() => _FlightLogPageState();
}

class _FlightLogPageState extends State<FlightLogPage> {
  final _formKey = GlobalKey<_FlightLogPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Logs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('This is the flight log page'),


            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    }
                  )
                ],
              ),
            )
            
            
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
