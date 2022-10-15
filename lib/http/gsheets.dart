import 'package:gsheets/gsheets.dart';
import 'package:terralis/components/utils.dart';
import 'package:terralis/database/dao/receipt_dao.dart';
import 'package:terralis/database/dao/receipt_product_dao.dart';
import 'package:terralis/models/receipt.dart';
import 'package:terralis/models/receipt_product.dart';

/// Your google auth credentials
const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheets-365119",
  "private_key_id": "dfe1434eb63e97ada12b2ed84d3702c395aaa030",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDMm4F3F/tfzGi5\ngIyU2cRtt2Q3q+asOtaod8FYa9d5XVO/eD5E37bds5cOiQZ+YyB7xGs+NfiatPSN\nBdPL1dXFO2UGsekG5yL32NReZ5Z8MBu5YEJxB/QD5KQdYl844/rVS3h9wZSVgCWU\n1ig+5NKvzGkQlBEN2xh8L1tTzcdbkk+3SnGHXWzbNgQ+pC5ryyIBXnJ9PgoTn1K2\n9xCdtzDg6lOjWt4idVGphFcPe7aHvce+NllvudzImEYqr4Hf+HN+0P57tkHiHCBY\n14lmSWKFtmYAOQi4GExEoekd5XrSrDSDPgqEnKGDkvVxMVCOoEDGQHFLqDJBO2MT\n8eXny/pRAgMBAAECggEAYEmgNCUPkaY29HFX9ybCR2XCHmbhz9SCt1ZgIVXi2cT/\nSAB0wWHMg2nkIR1/9lN88nHdjDHG9DtLSOBgqzDPAJnycaOhB7QXYy7hximWiovz\nSBpSOjIldf2P9BoauMGlBeKV6gyC+ZYMWY4s82go9D1MhlY/7lbYn3yDzJzvABqz\nYWHKAoCLhFVZlsbv5MEvOrZgLosG/zeljDpC1K7+tOnESEfgJnCKdjVtlsXc2H7w\nKhBKumi2TULZPOkRsob2CT8bbk7NBUDZbRNXA/KquLuDi0SQUakZTOx6DifOKE1q\nCkT47WmwQRNmHrkNh+WG091zEmbNUAegg/aulS50LwKBgQDzeoKrg98xGzx29FPI\nKqpdPnz6iuOf20KD/utaSbDx6LGaTzlEtFQfaho8+7zpImZusbU+pUjuiPQBdZQb\nkBP5p+M48TiFF7E9n2KlHViIQMTcxxMUOiGRD1EeH1az8SBqwDyPfBjb/42M4ntT\nIzaTKU/HrHkaZSmCGlt3Llh5ewKBgQDXIT32C9a7tAPP3hmkzA+qYQNE4fZMTZki\nI9migc+5my5zUEDr/zEdAkDLzCy0RGtGqchaj9ge6zhbkax8x97tMKCDYvy1Ig4p\n0rI8YUOR48adsJ/0g9yrA4fxEVOJqOcesOPL3mFipF3ugo6590i8WwtTBy2I+vXu\nPhgddI+TowKBgC6vMNreIC90P3W3h1D8DUpvrtsDQn3mNqzEdjALrSfVLCigRCTO\nRsr3Nyy2QBSbifRzkoL+gitqiw60kr9uMsZN0J2ccu/iCRP9uZZbOBx3/scuTJQ2\nSTVdMHqMG73I4CRX08TXUJTuPR/kVS0ttUsmQqvQgC/1ca4Gi78gXcp9AoGBAMKI\n9d3L4NcFtri+z5OdT8EzTuB4MN/Y/9PGdWQlXLErabqu5LZDoqbnxa5EqFwuzo8s\nstdp4fY7oE/1j/OaTbVQ1qVY2sn0zLf3JmPBVHfVcGJiOJLEtsQSQli04UTHbo/r\nR2KwaoHnvmUSvHvf6G8jKT9ga0XGIqPYlLf2EmtfAoGAcGR7wGb3jehPYhngUPh3\nkJaSVZW76sLIAk+YI3J0QsKd5Otcez3tv1IFHX60/0eAqJXaWts8qjAhGfIbpDjw\noRCd4+DfMzbRMK/c4KmUcastevAbi8cwgCsKI3tRNaQDNTaWoX7IpFDRgS04rPQp\n3ec39UxRm4LYu/Nx7f3eE4U=\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheets-365119.iam.gserviceaccount.com",
  "client_id": "108256826895732470041",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-365119.iam.gserviceaccount.com"
}
''';

/// Your spreadsheet id
///
/// It can be found in the link to your spreadsheet -
/// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
/// [YOUR_SPREADSHEET_ID] in the path is the id your need
const _spreadsheetId = '1hA3erUh-P8K-Vs03PaM3UUIiS0HKFGK4-tblEejz0k0';

Future<void> gsheetsSync() async {
  ReceiptDao receiptDao = ReceiptDao();
  List<Receipt> receipts = await receiptDao.findAllUnsynchronized();
  if (receipts.isEmpty) {
    return;
  }
  // init GSheets
  final gsheets = GSheets(_credentials);
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
        'Data': Utils.dateToString(receipt.date),
        'Qtd': Utils.numberToCommaString(product.qt),
        'Produto': product.product,
        'Preço UN': Utils.numberToCommaString(product.priceUn),
        'Recebido': Utils.numberToCommaString(product.price),
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