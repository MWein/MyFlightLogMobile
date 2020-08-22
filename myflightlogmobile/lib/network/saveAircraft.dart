import './openConnection.dart';
import 'dart:io';


Future<bool> saveAircraft(String nNumber, String type, String newTypeSName, String newTypeLName, File image) async {
  var connection = await openSQLConnection();

  String typeId;

  if (type == '_NEW') {
    List<List<dynamic>> createTypeResults = await connection.query('INSERT INTO plane_type (type_id, name, long_name) VALUES (uuid_generate_v1(), @shortName, @longName) RETURNING type_id',
      substitutionValues: {
        'shortName': newTypeSName,
        'longName': newTypeLName,
      },
    );
    typeId = createTypeResults[0][0];
  } else {
    List<List<dynamic>> typeResults = await connection.query('SELECT type_id FROM plane_type WHERE name = @name',
      substitutionValues: {
        'name': type,
      },
    );
    typeId = typeResults[0][0];
  }

  var imageBytes = await image.readAsBytes();

  await connection.query('INSERT INTO plane (ident, type_id, pic) VALUES (@ident, @typeId, @pic:bytea)',
    substitutionValues: {
      'ident': nNumber,
      'typeId': typeId,
      'pic': imageBytes,
    },
  );

  connection.close();

  return true;
}