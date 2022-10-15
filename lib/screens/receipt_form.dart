import 'package:flutter/material.dart';
import 'package:terralis/no_commit/components/progress.dart';
import 'package:terralis/database/dao/receipt_dao.dart';
import 'package:terralis/database/dao/receipt_product_dao.dart';
import 'package:terralis/models/receipt.dart';
import 'package:terralis/models/receipt_product.dart';
import 'package:terralis/screens/receipt_product_form.dart';

class ReceiptForm extends StatefulWidget {
  final Receipt? receiptSelected;
  final bool isNotHistory;

  const ReceiptForm({Key? key, this.receiptSelected, this.isNotHistory = true})
      : super(key: key);

  @override
  State<ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<ReceiptForm> {
  final TextEditingController _descriptionController = TextEditingController();
  final ReceiptDao _dao = ReceiptDao();
  final ReceiptProductDao _productDao = ReceiptProductDao();
  Receipt? _receipt;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receiptSelected;
    if (_receipt != null) {
      _descriptionController.text = _receipt!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    //findById called here
    Future<List<ReceiptProduct>> initializeDataFindById =
        _productDao.findById(_receipt);

    return Scaffold(
      appBar: AppBar(
        title: (widget.isNotHistory
            ? const Text('Recebimento')
            : const Text('Histórico > Recebimento')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                enabled: widget.isNotHistory,
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                style: const TextStyle(fontSize: 24.0),
              ),
            ), // Descrição
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Visibility(
                visible: widget.isNotHistory,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _createOrUpdateReceipt();
                      Navigator.pop(context);
                    },
                    child: const Text('Concluir'),
                  ),
                ),
              ),
            ), // Concluir
            FutureBuilder<List<ReceiptProduct>>(
              initialData: const [],
              future: initializeDataFindById,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    break;
                  case ConnectionState.waiting:
                    return const Progress();
                  case ConnectionState.active:
                    break;
                  case ConnectionState.done:
                    final List<ReceiptProduct>? products = snapshot.data;
                    final double? total =
                        products?.fold(0, (sum, item) => sum! + item.price);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total: ${total?.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                    );
                }
                return const Text('Unknown error');
              },
            ),
            FutureBuilder<List<ReceiptProduct>>(
              initialData: const [],
              future: initializeDataFindById,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    break;
                  case ConnectionState.waiting:
                    return const Progress();
                  case ConnectionState.active:
                    break;
                  case ConnectionState.done:
                    final List<ReceiptProduct>? products = snapshot.data;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final ReceiptProduct product = products![index];
                        return _ReceiptProductItem(
                          product,
                          onClick: () => _saveReceiptShowReceiptProductForm(context, product),
                        );
                      },
                      itemCount: products?.length ?? 0,
                    );
                }
                return const Text('Unknown error');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: widget.isNotHistory,
        child: FloatingActionButton(
          onPressed: () => _saveReceiptShowReceiptProductForm(context, null),
          child: const Icon(
            Icons.receipt,
          ),
        ),
      ),
    );
  }

  void _saveReceiptShowReceiptProductForm(BuildContext context, ReceiptProduct? product) {
    _createOrUpdateReceipt();
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ReceiptProductForm(
          _receipt!,
          productSelected: product,
          isNotHistory: widget.isNotHistory,
        ),
      ),
    )
        .then((value) {
      setState(() {});
    });
  }

  Future<void> _createOrUpdateReceipt() async {
    if (!widget.isNotHistory) {
      return;
    }
    if (_receipt == null) {
      _receipt = Receipt(DateTime.now(), _descriptionController.text);
      final int id = await _dao.insert(_receipt!);
      _receipt!.id = id;
    } else {
      _receipt!.description = _descriptionController.text;
      await _dao.update(_receipt!);
    }
  }
}

class _ReceiptProductItem extends StatelessWidget {
  final ReceiptProduct product;
  final Function onClick;

  const _ReceiptProductItem(
    this.product, {
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          product.product +
              (product.info.isNotEmpty ? ' - ${product.info}' : ''),
          style: const TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          'Qtd: ${product.qt.toString()} - ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
