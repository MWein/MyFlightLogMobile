import 'package:http/http.dart' as http;
import './openConnection.dart';
import 'dart:convert';


Future<List<String>> fetchAircraft() async {
  final response = await http.get('http://165.227.200.248:8081/airplanes-flown');

  if (response.statusCode == 200) {
    List<String> idents = json.decode(response.body).toList().map<String>((aircraft) {
      String ident = aircraft['ident'];
      return ident;
    }).toList();

    return idents;
  }

  return [];
}


Future<List<String>> fetchAircraftTypes() async {
  var connection = await openSQLConnection();

  List<List<dynamic>> results = await connection.query("SELECT name from plane_type");

  List<String> types = [];
  results.forEach((element) => types.add(element[0]));

  connection.close();

  return types;
}