import 'package:http/http.dart' as http;
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