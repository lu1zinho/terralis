import 'package:terralis/database/dao/receipt_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:terralis/database/dao/receipt_product_dao.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'terralis.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(ReceiptDao.tableSql);
      db.execute(ReceiptProductDao.tableSql);
    },
    version: 1,
    onDowngrade: onDatabaseDowngradeDelete
  );
}
