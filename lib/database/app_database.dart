import 'package:terralis/database/dao/history_dao.dart';
import 'package:terralis/database/dao/receipt_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:terralis/database/dao/receipt_product_dao.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'terralis.db');
  return openDatabase(
    path,
    onCreate: (db, version) async {
      var batch = db.batch();
      batch.execute(ReceiptDao.tableSql);
      batch.execute(ReceiptProductDao.tableSql);
      batch.execute(HistoryDao.tableSql);
      await batch.commit(noResult: true);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      for (var version = oldVersion + 1; version <= newVersion; version++) {
        switch (version) {
          case 1: {
            //Version 1 - no changes
            break;
          }
          case 2: {
            await db.execute(HistoryDao.tableSql);
            break;
          }
        }
      }
    },
    version: 2,
    // onDowngrade: onDatabaseDowngradeDelete
  );
}
