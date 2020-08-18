import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './network/fetchAircraft.dart';

class FlightLogPage extends StatefulWidget {
  FlightLogPage() : super();

  @override
  _FlightLogPageState createState() => _FlightLogPageState();
}

class _FlightLogPageState extends State<FlightLogPage> {
  DateFormat _dateFormatter = DateFormat('dd MMM, yyyy');
  Future<List<String>> aircraftIdents;

  // New flight log data
  DateTime _date = DateTime.now();
  String _aircraft;
  List<String> _stops = [ 'KSET', 'KJOT', 'KSET' ];


  @override
  void initState() {
    super.initState();
    aircraftIdents = fetchAircraft();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Flight Log'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text(_dateFormatter.format(_date)),
                  onPressed: () {
                    showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2018), lastDate: DateTime(2050))
                      .then((date) {
                        setState(() {
                          _date = date == null ? _date : date;
                        });
                      });
                  },
                ),

                SizedBox(width: 40),

                FutureBuilder(
                  future: aircraftIdents,
                  builder: (context, snapshot) {
                    print(snapshot.data);
                    if (snapshot.hasData) {
                      return DropdownButton<String>(
                        value: _aircraft,
                        onChanged: (String newValue) {
                          setState(() {
                            _aircraft = newValue;
                          });
                        },
                        items: snapshot.data
                          .map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Could not load aircraft');
                    }

                    return CircularProgressIndicator();
                  }
                ),


                SizedBox(width: 20),

                RaisedButton(
                  child: Text('New')
                ),
              ],
            ),


            SizedBox(height: 50),


            Wrap(
              spacing: 8.0,
              children: _stops.map((String stop) {
                return Chip(
                  label: Text(stop)
                );
              }).toList(),
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: TextField(
                    maxLength: 4,
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(width: 20),
                
                RaisedButton(child: Text('Add')),
              ]
            ),



          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
