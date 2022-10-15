class Receipt {
  int id = 0;
  final DateTime date;
  String description;
  bool synchronized = false;

  static const String tableName = 'receipts';
  static const String colId = 'id';
  static const String colDate = 'date';
  static const String colDescription = 'description';
  static const String colSynchronized = 'synchronized';

  Receipt(this.date, this.description);

  @override
  String toString() {
    return 'Receipt{id: $id, date: $date, description: $description, synchronized: $synchronized}';
  }

  Receipt.fromMap(Map<String, dynamic> map)
      : id = map[colId],
        date = DateTime.fromMillisecondsSinceEpoch(map[colDate]),
        description = map[colDescription],
        synchronized = (map[colSynchronized] == 1 ? true : false);

  Map<String, dynamic> toMap() => {
        // 'id': id,
        colDate: date.millisecondsSinceEpoch,
        colDescription: description,
        colSynchronized: (synchronized ? 1 : 0)
      };
}
