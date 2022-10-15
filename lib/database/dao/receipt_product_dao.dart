import 'package:sqflite/sqflite.dart';
import 'package:terralis/database/app_database.dart';
import 'package:terralis/models/receipt.dart';
import 'package:terralis/models/receipt_product.dart';

class ReceiptProductDao {
  static const String tableSql = 'CREATE TABLE ${ReceiptProduct.tableName} ('
      '${ReceiptProduct.colId} INTEGER PRIMARY KEY, '
      '${ReceiptProduct.colQt} INTEGER, '
      '${ReceiptProduct.colProduct} TEXT, '
      '${ReceiptProduct.colPrice} TEXT, '
      '${ReceiptProduct.colPriceUn} TEXT, '
      '${ReceiptProduct.colInfo} TEXT, '
      '${ReceiptProduct.colReceiptId} INTEGER, '
      'FOREIGN KEY (${ReceiptProduct.colReceiptId})'
      '   REFERENCES ${Receipt.tableName} (${Receipt.colId})'
      ')';

  Future<int> insert(ReceiptProduct receiptProduct) async {
    final Database db = await getDatabase();
    Map<String, dynamic> receiptProductMap = receiptProduct.toMap();
    return db.insert(ReceiptProduct.tableName, receiptProductMap);
  }

  Future<void> update(ReceiptProduct receiptProduct) async {
    final Database db = await getDatabase();
    Map<String, dynamic> receiptProductMap = receiptProduct.toMap();
    db.update(
      ReceiptProduct.tableName,
      receiptProductMap,
      where: '${ReceiptProduct.colId} = ?',
      whereArgs: [receiptProduct.id],
    );
  }

  Future<List<ReceiptProduct>> findById(Receipt? receipt) async {
    if (receipt == null) {
      return [];
    }
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> queryResult = await db.query(
      ReceiptProduct.tableName,
      where: '${ReceiptProduct.colReceiptId} = ?',
      whereArgs: [receipt.id],
    );
    return queryResult.map((e) => ReceiptProduct.fromMap(e)).toList();
  }
}
