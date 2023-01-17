import 'package:terralis/components/dart_utils.dart';

class History {
  int id = 0;
  final DateTime? date;
  final String formula;
  final String ingredient;
  final String nameInStock;
  final num? initialQt;
  final num? used;
  final num? oldQtStock;
  final double? priceKgLUn;
  final String unit;
  final double? value;
  final String newCell;
  final String status;
  String error;

  static const String tableName = 'history';
  static const String colId = 'id';
  static const String colDate = 'date';
  static const String colFormula = 'formula';
  static const String colIngredient = 'ingredient';
  static const String colNameInStock = 'name_in_stock';
  static const String colInitialQt = 'initial_qt';
  static const String colUsed = 'used';
  static const String colOldQtStock = 'old_qt_stock';
  static const String colPriceKgLUn = 'price_kg_l_un';
  static const String colUnit = 'unit';
  static const String colValue = 'value';
  static const String colNewCell = 'new_cell';
  static const String colStatus = 'status';
  static const String colError = 'error';

  History({
    this.date,
    this.formula = '',
    this.ingredient = '',
    this.nameInStock = '',
    this.initialQt,
    this.used,
    this.oldQtStock,
    this.priceKgLUn,
    this.unit = '',
    this.value,
    this.newCell = '',
    this.status = '',
    this.error = '',
  });

  History.fromMap(Map<String, dynamic> map)
      : id = map[colId],
        date = DartUtils.stringToDate(map[colDate]),
        formula = map[colFormula],
        ingredient = map[colIngredient],
        nameInStock = map[colNameInStock],
        initialQt = DartUtils.tryParseCommaDouble(map[colInitialQt]),
        used = DartUtils.tryParseCommaDouble(map[colUsed]),
        oldQtStock = DartUtils.tryParseCommaDouble(map[colOldQtStock]),
        priceKgLUn = DartUtils.tryParseCommaDouble(map[colPriceKgLUn]),
        unit = map[colUnit],
        value = DartUtils.tryParseCommaDouble(map[colValue]),
        newCell = map[colNewCell],
        status = map[colStatus],
        error = map[colError];

  Map<String, String> toMap(bool gsheets) => {
        // 'id': id,
        (gsheets ? 'Data' : colDate):
            DartUtils.dateToString(date ?? DateTime.now()),
        (gsheets ? 'Receita' : colFormula): formula,
        (gsheets ? 'Ingrediente' : colIngredient): ingredient,
        (gsheets ? 'Nome no estoque' : colNameInStock): nameInStock,
        (gsheets ? 'Qtd inicial' : colInitialQt):
            DartUtils.numberToCommaString(initialQt),
        (gsheets ? 'Utilizado' : colUsed): DartUtils.numberToCommaString(used),
        (gsheets ? 'Estoque anterior' : colOldQtStock):
            DartUtils.numberToCommaString(oldQtStock),
        (gsheets ? 'Preço kg L un' : colPriceKgLUn):
            DartUtils.numberToCommaString(priceKgLUn),
        (gsheets ? 'Unidade' : colUnit): unit,
        (gsheets ? 'Valor' : colValue): DartUtils.numberToCommaString(value),
        (gsheets ? 'Novo' : colNewCell): newCell,
        (gsheets ? 'Status' : colStatus): status,
        (gsheets ? 'Erro' : colError): error,
      };

  @override
  String toString() {
    return 'History{id: $id, date: $date, formula: $formula, ingredient: $ingredient, nameInStock: $nameInStock, initialQt: $initialQt, used: $used, oldQtStock: $oldQtStock, priceKgLUn: $priceKgLUn, unit: $unit, value: $value, newCell: $newCell, status: $status, error: $error}';
  }
}
