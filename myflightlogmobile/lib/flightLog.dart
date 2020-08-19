import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './network/fetchAircraft.dart';
import 'package:flutter/services.dart';
import './network/verifyAirport.dart';


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}


class FlightLogPage extends StatefulWidget {
  FlightLogPage() : super();

  @override
  _FlightLogPageState createState() => _FlightLogPageState();
}

class _FlightLogPageState extends State<FlightLogPage> {
  final DateFormat _dateFormatter = DateFormat('dd MMM, yyyy');
  Future<List<String>> aircraftIdents;

  // Stop editing
  bool _addButtonEnabled = false;
  bool _removeButtonEnabled = false;
  final stopTextController = TextEditingController();

  // New flight log data
  DateTime _date = DateTime.now();
  String _aircraft;
  List<String> _stops = [];
  int _takeoffs = 0;
  int _landings = 0;



  void addStop() async {
    bool verified = await verifyAirport(stopTextController.text, _stops);

    if (verified) {
      setState(() {
        _stops.add(stopTextController.text);
        _addButtonEnabled = false;
        _removeButtonEnabled = true;
      });

      stopTextController.text = '';
    }
  }

  void removeStop() {
    setState(() {
      _stops.removeLast();
      _removeButtonEnabled = _stops.length > 0;
    });
  }


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
            SizedBox(height: 50),

            // Date and Aircraft

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


            // Stops

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
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    controller: stopTextController,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                    ],
                    onChanged: (text) {
                      setState(() {
                        _addButtonEnabled = stopTextController.text.length == 4;
                      });
                    },
                  ),
                ),

                SizedBox(width: 20),
                
                RaisedButton(
                  child: Text('Add'),
                  onPressed: _addButtonEnabled ? addStop : null,
                ),

                SizedBox(width: 5),

                RaisedButton(
                  child: Text('Remove'),
                  onPressed: _removeButtonEnabled ? removeStop : null,
                ),
              ]
            ),


            SizedBox(height: 50),


            // Takeoffs and Landings

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Takeoffs: $_takeoffs'),
                SizedBox(width: 20),
                RaisedButton(
                  child: Text('-'),
                  onPressed: _takeoffs > 0 ? () {
                    setState(() {
                      _takeoffs--;
                    });
                  } : null,
                ),
                SizedBox(width: 5),
                RaisedButton(
                  child: Text('+'),
                  onPressed: () {
                    setState(() {
                      _takeoffs++;
                    });
                  },
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Landings: $_landings'),
                SizedBox(width: 20),
                RaisedButton(
                  child: Text('-'),
                  onPressed: _landings > 0 ? () {
                    setState(() {
                      _landings--;
                    });
                  } : null,
                ),
                SizedBox(width: 5),
                RaisedButton(
                  child: Text('+'),
                  onPressed: () {
                    setState(() {
                      _landings++;
                    });
                  },
                )
              ],
            ),



          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
