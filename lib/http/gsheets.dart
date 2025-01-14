import 'package:gsheets/gsheets.dart';
import 'package:terralis/components/dart_utils.dart';
import 'package:terralis/database/dao/receipt_dao.dart';
import 'package:terralis/database/dao/receipt_product_dao.dart';
import 'package:terralis/http/google_credentials.dart';
import 'package:terralis/models/receipt.dart';
import 'package:terralis/models/receipt_product.dart';

/// Your spreadsheet id
///
/// It can be found in the link to your spreadsheet -
/// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
/// [YOUR_SPREADSHEET_ID] in the path is the id your need

// Spreadsheet Terralis - Recebimentos e Receitas
//const _spreadsheetId = '1hA3erUh-P8K-Vs03PaM3UUIiS0HKFGK4-tblEejz0k0';

// Spreadsheet Terralis - Recebimentos e Receitas - DEMO
const _spreadsheetId = '1j2OfQUXqeHJAPlJfgX58Pc8lnHUc-DatZZ_1BXm-HfA';

Future<void> gsheetsReceiptsSync() async {
  ReceiptDao receiptDao = ReceiptDao();
  List<Receipt> receipts = await receiptDao.findAllUnsynchronized();
  if (receipts.isEmpty) {
    return;
  }
  // init GSheets
  final gsheets = GSheets(await getGoogleCredentials());
  // fetch spreadsheet by its id
  final ss = await gsheets.spreadsheet(_spreadsheetId);

  var sheet = ss.worksheetByTitle('Recebimentos');
  sheet ??= await ss.addWorksheet('Recebimentos');

  ReceiptProductDao productDao = ReceiptProductDao();
  List<Map<String, dynamic>> list = [];
  for (var receipt in receipts) {
    List<ReceiptProduct> products = await productDao.findById(receipt);
    if (products.isEmpty) {
      continue;
    }

    for (var product in products) {
      list.add({
        'Data': DartUtils.dateToString(receipt.date),
        'Qtd': DartUtils.numberToCommaString(product.qt),
        'Produto': product.product,
        'Preço UN': DartUtils.numberToCommaString(product.priceUn),
        'Recebido': DartUtils.numberToCommaString(product.price),
        'Informações': receipt.description +
            (product.info.isNotEmpty ? ' - ${product.info}' : ''),
      });
    }
  }

  await sheet.values.map.appendRows(list);
  await receiptDao.updateToSynchronized(receipts);
}

/*
void mainExample() async {
  // init GSheets
  final gsheets = GSheets(_credentials);
  // fetch spreadsheet by its id
  final ss = await gsheets.spreadsheet(_spreadsheetId);

  print(ss.data.namedRanges.byName.values
      .map((e) => {
            'name': e.name,
            'start':
                '${String.fromCharCode((e.range?.startColumnIndex ?? 0) + 97)}${(e.range?.startRowIndex ?? 0) + 1}',
            'end':
                '${String.fromCharCode((e.range?.endColumnIndex ?? 0) + 97)}${(e.range?.endRowIndex ?? 0) + 1}'
          })
      .join('\n'));

  // get worksheet by its title
  var sheet = ss.worksheetByTitle('example');
  // create worksheet if it does not exist yet
  sheet ??= await ss.addWorksheet('example');

  // update cell at 'B2' by inserting string 'new'
  await sheet.values.insertValue('new', column: 2, row: 2);
  // prints 'new'
  print(await sheet.values.value(column: 2, row: 2));
  // get cell at 'B2' as Cell object
  final cell = await sheet.cells.cell(column: 2, row: 2);
  // prints 'new'
  print(cell.value);
  // update cell at 'B2' by inserting 'new2'
  await cell.post('new2');
  // prints 'new2'
  print(cell.value);
  // also prints 'new2'
  print(await sheet.values.value(column: 2, row: 2));

  // insert list in row #1
  final firstRow = ['index', 'letter', 'number', 'label'];
  await sheet.values.insertRow(1, firstRow);
  // prints [index, letter, number, label]
  print(await sheet.values.row(1));

  // insert list in column 'A', starting from row #2
  final firstColumn = ['0', '1', '2', '3', '4'];
  await sheet.values.insertColumn(1, firstColumn, fromRow: 2);
  // prints [0, 1, 2, 3, 4, 5]
  print(await sheet.values.column(1, fromRow: 2));

  // insert list into column named 'letter'
  final secondColumn = ['a', 'b', 'c', 'd', 'e'];
  await sheet.values.insertColumnByKey('letter', secondColumn);
  // prints [a, b, c, d, e, f]
  print(await sheet.values.columnByKey('letter'));

  // insert map values into column 'C' mapping their keys to column 'A'
  // order of map entries does not matter
  final thirdColumn = {
    '0': '1',
    '1': '2',
    '2': '3',
    '3': '4',
    '4': '5',
  };
  await sheet.values.map.insertColumn(3, thirdColumn, mapTo: 1);
  // prints {index: number, 0: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6}
  print(await sheet.values.map.column(3));

  // insert map values into column named 'label' mapping their keys to column
  // named 'letter'
  // order of map entries does not matter
  final fourthColumn = {
    'a': 'a1',
    'b': 'b2',
    'c': 'c3',
    'd': 'd4',
    'e': 'e5',
  };
  await sheet.values.map.insertColumnByKey(
    'label',
    fourthColumn,
    mapTo: 'letter',
  );
  // prints {a: a1, b: b2, c: c3, d: d4, e: e5, f: f6}
  print(await sheet.values.map.columnByKey('label', mapTo: 'letter'));

  // appends map values as new row at the end mapping their keys to row #1
  // order of map entries does not matter
  final secondRow = {
    'index': '5',
    'letter': 'f',
    'number': '6',
    'label': 'f6',
  };
  await sheet.values.map.appendRow(secondRow);
  // prints {index: 5, letter: f, number: 6, label: f6}
  print(await sheet.values.map.lastRow());

  // get first row as List of Cell objects
  final cellsRow = await sheet.cells.row(1);
  // update each cell's value by adding char '_' at the beginning
  cellsRow.forEach((cell) => cell.value = '_${cell.value}');
  // actually updating sheets cells
  await sheet.cells.insert(cellsRow);
  // prints [_index, _letter, _number, _label]
  print(await sheet.values.row(1));
}
*/