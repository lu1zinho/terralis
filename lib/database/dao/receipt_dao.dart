import 'package:sqflite/sqflite.dart';
import 'package:terralis/database/app_database.dart';
import 'package:terralis/models/receipt.dart';

class ReceiptDao {
  static const String tableSql = 'CREATE TABLE ${Receipt.tableName} ('
      '${Receipt.colId} INTEGER PRIMARY KEY, '
      '${Receipt.colDate} INTEGER, '
      '${Receipt.colDescription} TEXT, '
      '${Receipt.colSynchronized} INTEGER'
      ')';

  Future<int> insert(Receipt receipt) async {
    final Database db = await getDatabase();
    Map<String, dynamic> receiptMap = receipt.toMap();
    return db.insert(Receipt.tableName, receiptMap);
  }

  Future<void> update(Receipt receipt) async {
    final Database db = await getDatabase();
    Map<String, dynamic> receiptMap = receipt.toMap();
    await db.update(
      Receipt.tableName,
      receiptMap,
      where: '${Receipt.colId} = ?',
      whereArgs: [receipt.id],
    );
  }
  Future<void> updateToSynchronized(List<Receipt> receipts) async {
    final Database db = await getDatabase();
    var listIds = receipts.map((e) => e.id.toString()).toList();
    print('receipts.length: ${receipts.length}');
    print('listIds: $listIds');

    var i = await db.update(
      Receipt.tableName,
      {Receipt.colSynchronized: 1},
      where: '${Receipt.colId} IN (${List.filled(listIds.length, '?').join(',')})',
      whereArgs: listIds,
    );
    print('rows updated: $i');
  }

  Future<List<Receipt>> _findAll(bool synchronized) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> queryResult =
        await db.query(Receipt.tableName, where: '${Receipt.colSynchronized} = ${synchronized ? '1' : '0'}');
    return queryResult.map((e) => Receipt.fromMap(e)).toList();
  }

  Future<List<Receipt>> findAllUnsynchronized() async {
    return _findAll(false);
  }

  Future<List<Receipt>> findAllSynchronized() async {
    return _findAll(true);
  }
}
