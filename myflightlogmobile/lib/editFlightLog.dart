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


class EditFlightLogPage extends StatefulWidget {
  EditFlightLogPage() : super();

  @override
  _EditFlightLogPageState createState() => _EditFlightLogPageState();
}

class _EditFlightLogPageState extends State<EditFlightLogPage> {
  final DateFormat _dateFormatter = DateFormat('dd MMMM, yyyy');
  Future<List<String>> aircraftIdents;

  // Stop editing
  bool _addButtonEnabled = false;
  bool _removeButtonEnabled = false;
  final stopTextController = TextEditingController();

  // Remarks editing
  StepState remarksStepState = StepState.editing;

  // New flight log data
  bool _favorite = false;
  DateTime _date = DateTime.now();
  String _aircraft;
  List<String> _stops = [];
  int _takeoffs = 0;
  int _landings = 0;
  final remarksTextController = TextEditingController();

  final nightTextController = TextEditingController();
  final instrumentTextController = TextEditingController();
  final simInstrumentTextController = TextEditingController();
  final flightSimTextController = TextEditingController();
  final crossCountryTextController = TextEditingController();
  final instructorTextController = TextEditingController();
  final dualTextController = TextEditingController();
  final pilotInCommandTextController = TextEditingController();
  final totalTextController = TextEditingController();


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




  // Stepper state
  int currentStep = 0;
  bool complete = false;

  next() {
    currentStep + 1 != 7 ? goTo(currentStep + 1) : setState(() => complete = true);
  }

  goTo(int step) {
    setState(() => currentStep = step);
    FocusScope.of(context).unfocus();
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }



  @override
  void initState() {
    super.initState();
    aircraftIdents = fetchAircraft();
  }


  @override
  Widget build(BuildContext context) {
    Map<String, TextEditingController> hoursMap = {
      'Night': nightTextController,
      'Instr.': instrumentTextController,
      'Sim Instr.': simInstrumentTextController,
      'Flight Sim': flightSimTextController,
      'X Country': crossCountryTextController,
      'Instructor': instructorTextController,
      'Dual': dualTextController,
      'PIC': pilotInCommandTextController,
      'Total': totalTextController,
    };

    List<Widget> hoursWidgets = [];

    hoursMap.forEach((key, value) {
      hoursWidgets.add(
        Container(
          width: 75,
          child: TextField(
            controller: value,
            inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')) ],
            decoration: InputDecoration(
              labelText: key
            ),
            keyboardType: TextInputType.number
          ),
        ),
      );

      hoursWidgets.add(SizedBox(width: 10));
    });


    List<Step> steps = [
      Step(
        title: const Text('Date'),
        isActive: currentStep == 0,
        state: StepState.complete,
        content: Row(
          children: [
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
            )
          ],
        ),
      ),

      Step(
        title: const Text('Aircraft'),
        isActive: currentStep == 1,
        state: _aircraft != null ? StepState.complete : StepState.editing,
        content: Row(
          children: [
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
              child: Text('New Aircraft')
            ),
          ],
        ),
      ),

      Step(
        title: const Text('Stops'),
        isActive: currentStep == 2,
        state: _stops.length > 0 ? StepState.complete : StepState.editing,
        content: Column(
          children: [
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
                    autocorrect: false,
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
          ],
        ),
      ),

      Step(
        title: const Text('Takeoffs and Landings'),
        isActive: currentStep == 3,
        state: StepState.complete,
        content: Column(
          children: [
            // TODO Write a component class for the below

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
      ),

      Step(
        title: const Text('Hours'),
        isActive: currentStep == 4,
        state: StepState.editing,
        content: Column(
          children: [
            Wrap(
              children: hoursWidgets,
            ),
          ],
        ),
      ),

      Step(
        title: const Text('Remarks'),
        isActive: currentStep == 5,
        state: remarksStepState,
        content: Column(
          children: [
            CheckboxListTile(
              title: Text('Mark as Favorite'),
              value: _favorite,
              onChanged: (value) {
                setState(() {
                  _favorite = value;
                });
              },
            ),
            TextField(
              minLines: 3,
              maxLines: 3,
              controller: remarksTextController,
              onChanged: (text) {
                setState(() {
                  remarksStepState = text == '' ? StepState.editing : StepState.complete;
                });
              },
            )
          ],
        ),
      ),

      Step(
        title: const Text('Photos'),
        isActive: currentStep == 6,
        state: StepState.complete,
        content: Column(
          children: [],
        ),
      ),
    ];



    return Scaffold(
      appBar: AppBar(
        title: Text('New Flight Log'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                steps: steps,
                currentStep: currentStep,
                onStepContinue: next,
                onStepCancel: cancel,
                onStepTapped: (step) => goTo(step),
              ),
            ),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
