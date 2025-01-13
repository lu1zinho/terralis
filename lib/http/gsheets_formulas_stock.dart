import 'package:gsheets/gsheets.dart';
import 'package:terralis/components/dart_utils.dart';
import 'package:terralis/database/dao/history_dao.dart';
import 'package:terralis/models/history.dart';
import 'package:terralis/no_commit/http/webclient.dart';

class GsheetsFormulasStock {
  // Spreadsheet Produções e fórmulas Terralis
  //static const _idFormulasTerralis =
  //    '1H8JXBeSWvVhZJ1TOVtokF3Ci-j0759-GPBZPEX2oTNI';

  // Spreadsheet Produções e fórmulas Terralis - DEMO
  static const _idFormulasTerralis =
      '1MLmRGeQdNhpUDa-XK3kHcmt8pBjYoSih1UdzSd1zNWY';

  // Spreadsheet Produções e fórmulas Yoga-se
  //static const _idFormulasYogase =
  //    '1gtCQm89K5_iJWxhw6GWVKCrTXYqbMjlCvazx_uRON80';

  // Spreadsheet Produções e fórmulas Yoga-se - DEMO
  static const _idFormulasYogase =
      '1gq2paysGmBA2XU3coLOkLeR3WTG23VH_dquQErD3le0';

  // Spreadsheet Controle de estoque Terralis
  //static const _idStock = '1qErlo0MGVdyOenoVk9RE2hYPBiH5Rc-gNuU20ExLJPQ';

  // Spreadsheet Controle de estoque Terralis - DEMO
  static const _idStock = '1YYI9MWSLOnIsPd5S2ooTrmW8iMtSke-Q4gTL4KzozLQ';

  static const _stockTabName = 'Estoque';
  // static const _stockTabName = 'TESTE';

  static const _historyTabName = 'Histórico';
  static const _columnFormulaInfo = 5;

  final _gsheets = GSheets(googleCredentials);
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

