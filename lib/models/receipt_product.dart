class ReceiptProduct {
  int id = 0;
  int qt; // = 1;
  String product; // = '';
  double _price = 0;
  double _priceUn = 0;
  String info;
  final int receiptId;

  static const String tableName = 'receipt_products';
  static const String colId = 'id';
  static const String colQt = 'qt';
  static const String colProduct = 'product';
  static const String colPrice = 'price';
  static const String colPriceUn = 'price_un';
  static const String colInfo = 'info';
  static const String colReceiptId = 'receipt_id';

  ReceiptProduct(this.qt, this.product, price, this.info, this.receiptId) {
    this.price = price;
  }

  @override
  String toString() {
    return 'ReceiptProduct{id: $id, qt: $qt, product: $product, price: $price, priceUn: $_priceUn, info: $info, receiptId: $receiptId}';
  }

  ReceiptProduct.fromMap(Map<String, dynamic> map)
      : id = map[colId],
        qt = map[colQt],
        product = map[colProduct],
        _price = double.parse(map[colPrice]),
        _priceUn = double.parse(map[colPriceUn]),
        info = map[colInfo],
        receiptId = map[colReceiptId];

  Map<String, dynamic> toMap() => {
        // 'id': id,
        colQt: qt,
        colProduct: product,
        colPrice: price.toStringAsFixed(2),
        colPriceUn: priceUn.toStringAsFixed(2),
        colInfo: info,
        colReceiptId: receiptId
      };

  double get price => _price;

  set price(double value) {
    _price = value;
    if (qt == 0) {
      qt = 1;
    }
    _priceUn = price/qt;
  }

  double get priceUn => _priceUn;

}
