import 'package:sqflite/sqflite.dart';
import 'package:terralis/database/app_database.dart';
import 'package:terralis/models/history.dart';

class HistoryDao {
  static const String tableSql = 'CREATE TABLE ${History.tableName} ('
      '${History.colId} INTEGER PRIMARY KEY, '
      '${History.colDate} TEXT, '
      '${History.colFormula} TEXT, '
      '${History.colIngredient} TEXT, '
      '${History.colNameInStock} TEXT, '
      '${History.colInitialQt} TEXT, '
      '${History.colUsed} TEXT, '
      '${History.colOldQtStock} TEXT, '
      '${History.colPriceKgLUn} TEXT, '
      '${History.colUnit} TEXT, '
      '${History.colValue} TEXT, '
      '${History.colNewCell} TEXT, '
      '${History.colStatus} TEXT, '
      '${History.colError} TEXT'
      ')';

  Future<void> insertAll(List<History> list) async {
    final Database db = await getDatabase();
    var batch = db.batch();
    for (var history in list) {
      batch.insert(History.tableName, history.toMap(false));
    }
    await batch.commit(noResult: true);
  }

  Future<List<History>> findAll() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> queryResult =
        await db.query(History.tableName);
    return queryResult.map((e) => History.fromMap(e)).toList();
  }

  Future<void> deleteAll() async {
    final Database db = await getDatabase();
    db.delete(History.tableName);
  }

}
