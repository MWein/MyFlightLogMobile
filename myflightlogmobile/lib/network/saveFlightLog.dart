import './openConnection.dart';


Future<bool> saveFlightLog(DateTime date, bool favorite, String aircraftIdent, List<String> stops, int takeoffs, int landings, Map<String, int> hours, String remarks) async {


  // bool alreadyVerified = stops.contains(ident);

  // if (alreadyVerified) {
  //   return true;
  // }

  // var connection = await openSQLConnection();

  // List<List<dynamic>> results = await connection.query("SELECT count(*) FROM airport WHERE ident = @ident",
  //   substitutionValues: {
  //     "ident" : ident
  //   });

  // connection.close();

  // return results[0][0] == 1;
}