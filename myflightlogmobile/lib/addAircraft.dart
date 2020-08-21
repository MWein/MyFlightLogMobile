import 'package:flutter/material.dart';
import './network/fetchAircraft.dart';
import './components/upperCaseFormatter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './network/saveAircraft.dart';


class AddAircraftPage extends StatefulWidget {
  AddAircraftPage() : super();

  @override
  _AddAircraftPageState createState() => _AddAircraftPageState();
}

class _AddAircraftPageState extends State<AddAircraftPage> {
  Future<List<String>> aircraftIdents;
  Future<List<String>> aircraftTypes;

  final ImagePicker _picker = ImagePicker();

  String _type;
  final nNumberTextController = TextEditingController();
  final shortNameTextController = TextEditingController();
  final longNameTextController = TextEditingController();
  File image;


  bool _enableSaveButton = false;
  determineComplete() {
    bool typeFilled = _type == '_NEW' ? shortNameTextController.text != '' && longNameTextController.text != '' : _type != null;

    setState(() {
      _enableSaveButton = nNumberTextController.text != '' && typeFilled && image != null;
    });
  }


  pickImage() async {
    PickedFile pickedPic = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      image = File(pickedPic.path);
    });

    determineComplete();
  }


  @override
  void initState() {
    super.initState();
    aircraftIdents = fetchAircraft();
    aircraftTypes = fetchAircraftTypes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Aircraft'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  child: TextField(
                    controller: nNumberTextController,
                    decoration: InputDecoration(
                      labelText: 'N-Number',
                    ),
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                    ],
                    onChanged: (value) => determineComplete(),
                  ),
                ),

                SizedBox(width: 20),

                Padding(
                padding: EdgeInsets.only(top: 20),
                child: FutureBuilder(
                  future: aircraftTypes,
                  builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownButton<String>(
                          value: _type,
                          onChanged: (String newValue) {
                            setState(() => _type = newValue);
                            determineComplete();
                          },
                          items: [
                            ...snapshot.data
                              .map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            DropdownMenuItem<String>(
                              value: '_NEW',
                              child: Text('New Type')
                            )
                          ]
                        );
                      } else if (snapshot.hasError) {
                        return Text('Could not load aircraft types');
                      }

                      return CircularProgressIndicator();
                    }
                  ),
                )
              ]
            ),

            SizedBox(height: 20),

            (() {
              if (_type == '_NEW') {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      child: TextField(
                        onChanged: (value) => determineComplete(),
                        controller: shortNameTextController,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: 'Short Name',
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 125,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: TextField(
                          onChanged: (value) => determineComplete(),
                          controller: longNameTextController,
                          decoration: InputDecoration(
                            labelText: 'Long Name',
                          ),
                        ),
                      )
                    )
                  ]);
              } else {
                return SizedBox();
              }
            }()),


            (() {
              if (image != null) {
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Image.file(
                      image,
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 20),
                  ]
                );
              } else {
                return Column(
                  children: [
                    SizedBox(height: 50),
                    Text('No Image'),
                    SizedBox(height: 20),
                  ],
                );
              }
            }()),


            Column(
              children: [
                RaisedButton(
                  child: Text('Select Image'),
                  onPressed: () => pickImage(),
                ),

                SizedBox(height: 30),

                RaisedButton(
                  child: Text('Save'),
                  onPressed: _enableSaveButton ? () {
                    saveAircraft(nNumberTextController.text, _type, shortNameTextController.text, longNameTextController.text, image);
                  } : null,
                )
              ],
            ),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}