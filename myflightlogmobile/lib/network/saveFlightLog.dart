import './openConnection.dart';
import 'dart:io';


Future<bool> saveFlightLog(DateTime date, bool favorite, String aircraftIdent, List<String> stops, int takeoffs, int landings, Map<String, double> hours, String remarks, List<File> photos) async {
  var connection = await openSQLConnection();

  if (stops.length == 1) {
    stops.add(stops[0]);
  }

  String postgresStopsString = stops.join(",");
  postgresStopsString = '{$postgresStopsString}';


  final result = await connection.query('INSERT INTO log (id, date, ident, stops, night, instrument, sim_instrument, flight_sim, cross_country, instructor, dual, pic, total, takeoffs, landings, remarks, favorite) VALUES (uuid_generate_v1(), @date, @ident, @stops, @night, @instr, @siminstr, @sim, @xc, @instructor, @dual, @pic, @total, @takeoff, @landing, @remarks, @favorite) RETURNING id',
    substitutionValues: {
      'date': date,
      'ident': aircraftIdent,
      'stops': postgresStopsString,
      'night': hours['night'],
      'instr': hours['instrument'],
      'siminstr': hours['simInstrument'],
      'sim': hours['flightSim'],
      'xc': hours['crossCountry'],
      'instructor': hours['instructor'],
      'dual': hours['dual'],
      'pic': hours['pic'],
      'total': hours['total'],
      'takeoff': takeoffs,
      'landing': landings,
      'remarks': remarks,
      'favorite': favorite,
    });


  String flightId = result[0][0];

  photos.forEach((photo) async {
    var connection = await openSQLConnection();
    var imageBytes = await photo.readAsBytes();
    await connection.query('INSERT INTO pictures (flightid, id, data) VALUES (@flightId, uuid_generate_v1(), @photo:bytea)',
      substitutionValues: {
        'flightId': flightId,
        'photo': imageBytes
      }
    );
    connection.close();
  });


  connection.close();

  return true;
}