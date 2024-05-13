import 'package:gsheets/gsheets.dart';
import 'package:terralis/components/dart_utils.dart';
import 'package:terralis/database/dao/history_dao.dart';
import 'package:terralis/models/history.dart';

class GsheetsFormulasStock {
  // Spreadsheet Produções e fórmulas Terralis
  static const _idFormulasTerralis =
      '1H8JXBeSWvVhZJ1TOVtokF3Ci-j0759-GPBZPEX2oTNI';

  // Spreadsheet Produções e fórmulas Yoga-se
  static const _idFormulasYogase =
      '1gtCQm89K5_iJWxhw6GWVKCrTXYqbMjlCvazx_uRON80';

  // Spreadsheet Controle de estoque Terralis
  static const _idStock = '1qErlo0MGVdyOenoVk9RE2hYPBiH5Rc-gNuU20ExLJPQ';

  static const _stockTabName = 'Estoque';
  // static const _stockTabName = 'TESTE';

  static const _historyTabName = 'Histórico';
  static const _columnFormulaInfo = 5;

  final _gsheets = GSheets(_credentials);
  final String _sheetName;
  Spreadsheet? _ss;
  Map<String, List<Cell>>? _mapFormulas;
  Worksheet? _wStock; //aba Estoque atual de Controle de estoque insumos
  Map<String, List<Cell>>? _mapStock;
  Worksheet? _wHistory; //aba Histórico da planilha Controle de estoque insumos
  List<FormulaIngredient> _listFormulaIngredient = [];
  List<History> _listHistory = [];
  bool _hasError = false;

  GsheetsFormulasStock(this._sheetName);

  Future<List<Worksheet>> getFormulasTabs() async {
    if (_sheetName == 'Terralis') {
      _ss = await _gsheets.spreadsheet(_idFormulasTerralis);
    } else if (_sheetName == 'Yoga-se') {
      _ss = await _gsheets.spreadsheet(_idFormulasYogase);
    } else {
      return [];
    }
    _ss!.sheets.removeWhere(
        (e) => ['Soma insumos', 'Preços'].contains(e.title.trim()));
    return _ss!.sheets;
  }

  Future<List<FormulaQt>> getFormulasNames(Worksheet s) async {
    _mapFormulas = await _getCellsMap(s, columnCount: _columnFormulaInfo);
    var listQtd = _mapFormulas!['Qtd %']!;
    var listQtdUnit = _mapFormulas!['Qtd final']!;
    var listInfo = _mapFormulas!['Informações']!;

    List<FormulaQt> listFormulaQt = [];

    for (var cell in listQtd.getRange(1, listQtd.length)) {
      var cellValue = cell.value.trim();
      if (cellValue.isNotEmpty && double.tryParse(cellValue) == null) {
        int indexCell = cell.row - 1;
        listFormulaQt.add(FormulaQt(cell, _getCellValue(listQtdUnit, indexCell),
            _getCellValue(listInfo, indexCell)));
      }
    }

    return listFormulaQt;
  }

  Production getFormula(Worksheet wTab, Cell cellFormulaName) {
    var listIngredient = _getIngredients(cellFormulaName);
    List<ProductionIngredient> listProd = [];

    for (var ingredient in listIngredient) {
      if (ingredient.name.isEmpty) {
        continue;
      }

      String qtG = _getQtG(ingredient.row);
      String qtFinal = _getQtFinal(ingredient.row);
      listProd.add(ProductionIngredient(ingredient.name.trim(), qtG, qtFinal));
    }

    return Production(wTab, cellFormulaName, listProd);
  }

  Future<bool> produceFormula(Worksheet wTab, Production prod,
      {bool stockWriteOff = true}) async {
    _wStock = await _getWorksheet(_idStock, _stockTabName);
    _wHistory = await _getWorksheet(_idStock, _historyTabName);
    _mapStock = await _getCellsMap(_wStock!, columnCount: 15);
    _listFormulaIngredient = [];
    _listHistory = [History()]; //criar assim p/ ter uma separação no historico
    _hasError = false;

    var listCellStockQt = _mapStock!['Peso']!;
    var listCellStockProduct = _mapStock!['Produto']!;

    for (var prodIngred in prod.list) {
      double qtUsed = _getQtUsed(prodIngred);
      double qtNotUsed = 0;
      var found = false;

      for (var cellStockProduct in listCellStockProduct) {
        if (cellStockProduct.value.contains(prodIngred.ingredient)) {
          // o numero do row inicia em 1 e o numero do indice inicia em 0, portanto subtrair 1
          int indexStockProduct = cellStockProduct.row - 1;
          var cellStockQt = listCellStockQt[indexStockProduct];
          var stockQt = DartUtils.tryParseCommaDouble(cellStockQt.value);
          if (stockQt == null) {
            continue;
          }
          if (qtNotUsed > 0) {
            qtUsed = qtNotUsed;
          }

          try {
            qtNotUsed = await _writeOff(
                cellStockQt, stockQt, qtUsed, indexStockProduct,
                stockWriteOff: stockWriteOff);

            var priceKgLUn = _getPriceKgLUn(indexStockProduct);
            var unit = _getUnit(indexStockProduct);
            double? value;
            String message = '';
            try {
              value = _getValue(
                  priceKgLUn, unit, qtUsed - qtNotUsed, indexStockProduct);
            } on FormatException catch (e) {
              _hasError = true;
              message = e.message;
            }

            _addHistory(
              History(
                  formula: prod.cellFormulaName.value,
                  ingredient: prodIngred.ingredient,
                  nameInStock: cellStockProduct.value,
                  initialQt: qtUsed,
                  used: qtUsed - qtNotUsed,
                  oldQtStock: stockQt,
                  newCell: cellStockQt.toString(),
                  priceKgLUn: priceKgLUn,
                  unit: unit,
                  value: value,
                  status: _getStatusHistory(qtNotUsed, true, message: message)),
            );

            _addPrice(prodIngred.ingredient, indexStockProduct,
                qtUsed - qtNotUsed, cellStockProduct);

            if (qtNotUsed == 0) {
              found = true;
              break;
            }
          } on Exception catch (e) {
            _hasError = true;
            _addHistory(History(
              formula: prod.cellFormulaName.value,
              ingredient: prodIngred.ingredient,
              nameInStock: cellStockProduct.value,
              used: qtUsed,
              oldQtStock: stockQt,
              newCell: cellStockQt.toString(),
              status: _getStatusHistory(qtNotUsed, true),
              error: _formatException(e),
            ));
          }
        }
      }
      if (!found) {
        _hasError = true;
        _addHistory(History(
          formula: prod.cellFormulaName.value,
          ingredient: prodIngred.ingredient,
          initialQt: qtUsed,
          used: qtNotUsed,
          status: _getStatusHistory(qtNotUsed, false),
        ));
        _addPriceNotFound(prodIngred.ingredient, qtUsed);
      }
    }

    await _setOkStockWriteOff(wTab, prod.cellFormulaName, stockWriteOff);
    await synchronizeHistory(_listHistory);
    await _insertPromptDelivery(prod.cellFormulaName, stockWriteOff);

    return _hasError;
  }

  Future<void> _insertPromptDelivery(
      Cell cellFormulaName, bool stockWriteOff) async {
    var nameInStock = 'Dar baixa: $stockWriteOff - Planilha: $_stockTabName';

    try {
      var wPromptDelivery = await _getWorksheet(_idStock, 'Pronta-entrega');
      int? qtProducedItens = DartUtils.tryParseCommaDouble(
              _mapFormulas!['Qtd final']![cellFormulaName.row - 1].value)
          ?.truncate();
      if (qtProducedItens == null) {
        _hasError = true;
        await _addHistory(
            History(
                formula: cellFormulaName.value,
                nameInStock: nameInStock,
                status: 'QTD DE UNIDADES DA RECEITA NÃO ENCONTRADA'),
            addListHistory: false,
            synchronize: true);
        return;
      }

      var cost = _calculateFormulaCost();
      wPromptDelivery.values.map.appendRow({
        'Data': DartUtils.dateToString(DateTime.now()),
        'Produto': cellFormulaName.value,
        'Quantidade': qtProducedItens.toString(),
        'Custo total': DartUtils.numberToCommaString(cost),
        'Custo': DartUtils.numberToCommaString(cost / qtProducedItens),
        'Informações': _getFormulaCostInfos(),
      });

      await _addHistory(
          History(
              formula: cellFormulaName.value,
              used: qtProducedItens,
              nameInStock: nameInStock,
              status: 'Adicionado na pronta-entrega'),
          addListHistory: false,
          synchronize: true);
    } on Exception catch (e) {
      _hasError = true;
      await _addHistory(
          History(
              formula: cellFormulaName.value,
              status: 'NAO FOI PRA PRONTA-ENTREGA',
              nameInStock: nameInStock,
              error: _formatException(e)),
          addListHistory: false,
          synchronize: true);
    }
  }

  double _calculateFormulaCost() {
    double cost = 0;
    for (var formulaIngred in _listFormulaIngredient) {
      if (formulaIngred.priceKgLUn == null || formulaIngred.unit.isEmpty) {
        formulaIngred.info = 'sem preço/unidade';
        continue;
      }

      var unit = formulaIngred.unit.trim().toLowerCase();
      var priceKgLUn = formulaIngred.priceKgLUn!;
      var qt = formulaIngred.quantity + formulaIngred.offset;

      if (unit == 'ml' || unit == 'g') {
        cost += priceKgLUn * qt / 1000;
      } else if (unit == 'uni') {
        cost += priceKgLUn * qt;
      } else {
        formulaIngred.info = 'unidade inválida';
      }
    }

    return cost;
  }

  Future<double> _writeOff(
      Cell cellStockQt, double stockQt, double qtUsed, int indexStockProduct,
      {bool stockWriteOff = true}) async {
    double offset = _getOffset(indexStockProduct);

    if (qtUsed > 0) {
      qtUsed += offset;
    }

    if (stockQt > qtUsed) {
      cellStockQt.value = DartUtils.numberToCommaString(stockQt - qtUsed);
      if (stockWriteOff) {
        if (!await _wStock!.cells.insert([cellStockQt])) {
          throw Exception('_writeOff: insert returned false');
        }
      }
      return 0;
    } else {
      cellStockQt.value = '';
      if (stockWriteOff) {
        if (!await _wStock!.cells.insert([cellStockQt])) {
          throw Exception('_writeOff: insert returned false');
        }
      }
      return (stockQt - qtUsed).abs();
    }
  }

  double _getOffset(int indexStockProduct) =>
      DartUtils.tryParseCommaDouble(
          _mapStock!['Ajuste']![indexStockProduct].value) ??
      1;

  List<Ingredient> _getIngredients(Cell cellFormulaName) {
    int firstRow = cellFormulaName.row;
    var listCellIngredient = _mapFormulas!['Ingrediente']!;

    int lastRow = -1;
    for (int i = firstRow; i < listCellIngredient.length; i++) {
      var cIngredient = listCellIngredient[i];
      if (cIngredient.value.trim() == 'FIM' || cIngredient.value.trim() == '') {
        lastRow = cIngredient.row;
        break;
      }
    }
    List<Ingredient> listIngredient = [];
    listCellIngredient.getRange(firstRow, lastRow - 1).forEach((cell) {
      listIngredient.add(Ingredient(cell));
    });
    return listIngredient;
  }

  String _getQtG(int row) {
    return _getQt(row, 'Qtd (g)');
  }

  String _getQtFinal(int row) {
    return _getQt(row, 'Qtd final');
  }

  String _getQt(int row, String column) {
    var listQt = _mapFormulas![column]!;

    // o numero do row inicia em 1 e o numero do indice inicia em zero, portanto subtrair 1
    int indexIngredient = row - 1;

    var strQt = _getCellValue(listQt, indexIngredient);
    double? qt = double.tryParse(strQt);
    if (qt == null) {
      return strQt;
    }
    return qt.toStringAsFixed(2);
  }

  double _getQtUsed(ProductionIngredient prodIngred) {
    if (prodIngred.qtUsed != null) {
      return prodIngred.qtUsed!;
    }

    if (prodIngred.qtFinal != '') {
      double? qtFinal = double.tryParse(prodIngred.qtFinal);
      if (qtFinal != null) {
        return qtFinal;
      }
    }

    return double.tryParse(prodIngred.qtG) ?? 0;
  }

  String _getFormulaCostInfos() {
    String infos = '';
    for (var formIngr in _listFormulaIngredient) {
      if (formIngr.info.isNotEmpty) {
        infos += '$formIngr qtd: ${formIngr.quantity} ${formIngr.info} - ';
      }
    }
    return infos;
  }

  void _addPrice(String ingredient, int indexProduct, double qtUsed,
      Cell cellStockProduct) {
    var unit = _getUnit(indexProduct);
    var priceKgLUn = _getPriceKgLUn(indexProduct);
    var offset = _getOffset(indexProduct);

    _listFormulaIngredient.add(FormulaIngredient(
        cellStockProduct, ingredient, unit, priceKgLUn, qtUsed, offset));
  }

  Future<void> _addHistory(History history,
      {bool addListHistory = true, bool synchronize = false}) async {
    if (addListHistory) {
      _listHistory.add(history);
    }
    if (synchronize) {
      await synchronizeHistory([history]);
    }
  }

  Future<void> _setOkStockWriteOff(
      Worksheet wTab, Cell cellFormulaName, bool stockWriteOff) async {
    if (!stockWriteOff) {
      return;
    }

    var listInfo = _mapFormulas!['Informações']!;
    int index = cellFormulaName.row - 1;

    try {
      if (index >= listInfo.length) {
        // wTab.values.insertValueByKeys('OK', columnKey: 'Informações', rowKey: cellFormulaName.value, eager: false);
        if (!await wTab.values
            .insertValue('OK', column: _columnFormulaInfo, row: index + 1)) {
          throw Exception('_setOkStockWriteOff: insertValue returned false');
        }
        return;
      }
      var cellInfo = listInfo[index];
      if (cellInfo.value == 'OK') {
        return;
      }
      if (!await cellInfo.post('OK')) {
        throw Exception('_setOkStockWriteOff: cellInfo.post returned false');
      }
    } on Exception catch (e) {
      _hasError = true;
      await _addHistory(
        History(
            formula: cellFormulaName.value,
            status: 'NAO FOI POSSIVEL SETAR OK NA RECEITA',
            error: _formatException(e)),
      );
    }
  }

  Future<void> synchronizeHistory(List<History> listHistory,
      {bool noDao = false}) async {
    _wHistory ??= await _getWorksheet(_idStock, _historyTabName);
    try {
      if (!await _wHistory!.values.map
          .appendRows(listHistory.map((e) => e.toMap(true)).toList())) {
        throw Exception('synchronizeHistory: appendRows returned false');
      }
    } on Exception catch (e) {
      if (noDao) {
        rethrow;
      }
      _hasError = true;
      for (var history in listHistory) {
        history.error += 'synchronizeHistory: ${_formatException(e)}';
      }
      await HistoryDao().insertAll(listHistory);
    }
  }

  double _getValue(
      double? priceKgLUn, String unit, double quantity, int indexStockProduct) {
    if (priceKgLUn == null) {
      throw const FormatException('sem preço/unidade, ');
    }
    unit = unit.toLowerCase();
    quantity += _getOffset(indexStockProduct);
    if (unit == 'ml' || unit == 'g') {
      return priceKgLUn * quantity / 1000;
    } else if (unit == 'uni') {
      return priceKgLUn * quantity;
    } else {
      throw const FormatException('unidade inválida, ');
    }
  }

  String _getUnit(int indexProduct) =>
      _mapStock!['g / mL / uni']![indexProduct].value.trim();

  void _addPriceNotFound(String ingredient, double qtUsed) {
    _listFormulaIngredient.add(FormulaIngredient.notFound(ingredient, qtUsed));
  }

  String _getStatusHistory(double qtNotUsed, bool found,
      {String message = ''}) {
    return message +
        ((qtNotUsed == 0)
            ? (found ? 'OK' : 'NÃO ENCONTROU')
            : (found ? 'OK, ' : 'NÃO ENCONTROU, ') +
                'Faltou dar baixa: ${qtNotUsed.toStringAsFixed(2)}');
  }

  double? _getPriceKgLUn(int indexProduct) => DartUtils.tryParseCommaDouble(
      _mapStock!['Preço kg L un']![indexProduct].value.trim());

  Future<Map<String, List<Cell>>> _getCellsMap(Worksheet worksheet,
      {int columnCount = -1, int fromRow = 1, int length = -1}) async {
    var listWsheetCells = await worksheet.cells
        .allColumns(count: columnCount, fromRow: fromRow, length: length);
    var mapWorksheetCells = {for (var e in listWsheetCells) e.first.value: e};
    return mapWorksheetCells;
  }

  Future<Worksheet> _getWorksheet(String idSpreadsheet, String wsheet) async {
    final ss = await _gsheets.spreadsheet(idSpreadsheet);
    var sheet = ss.worksheetByTitle(wsheet);
    sheet ??= await ss.addWorksheet(wsheet);
    return sheet;
  }

  String _getCellValue(List<Cell> listCell, int index) {
    if (index >= listCell.length) {
      return '';
    }
    return listCell[index].value.trim();
  }

  String _formatException(Exception e) => '${e.runtimeType}: $e';
}

class Ingredient {
  late final String name;
  late final String label;
  late final int row;
  late final int column;

  Ingredient(Cell cell) {
    name = cell.value.trim();
    row = cell.row;
    label = cell.label;
    column = cell.column;
  }

  @override
  String toString() {
    return 'Ingrediente{name: $name, label: $label, row: $row, column: $column}';
  }
}

class FormulaIngredient {
  late final String ingredient;
  late final String name;
  late final String label;
  late final int row;
  late final int column;
  late final double? priceKgLUn;
  late final String unit;
  late final double offset;
  final double quantity;
  String info = '';

  FormulaIngredient(Cell cell, this.ingredient, this.unit, this.priceKgLUn,
      this.quantity, this.offset) {
    name = cell.value.trim();
    row = cell.row;
    label = cell.label;
    column = cell.column;
  }

  FormulaIngredient.notFound(this.ingredient, this.quantity) {
    name = ingredient;
    label = unit = '';
    row = column = -1;
    offset = 0;
    priceKgLUn = null;
  }

  @override
  String toString() => "$name at $label";
}

class FormulaQt {
  final Cell formula;
  final String qt;
  late final bool ok;

  FormulaQt(this.formula, this.qt, String info) {
    ok = info == 'OK';
  }
}

class Production {
  final Worksheet wTab;
  final Cell cellFormulaName;
  final List<ProductionIngredient> list;

  Production(this.wTab, this.cellFormulaName, this.list);
}

class ProductionIngredient {
  final String ingredient;
  final String qtG;
  final String qtFinal;
  double? qtUsed;

  ProductionIngredient(this.ingredient, this.qtG, this.qtFinal);
}

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
