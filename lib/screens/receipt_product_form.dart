import 'package:flutter/material.dart';
import 'package:terralis/components/flutter_utils.dart';
import 'package:terralis/components/number_form_field.dart';
import 'package:terralis/database/dao/receipt_product_dao.dart';
import 'package:terralis/models/receipt.dart';
import 'package:terralis/models/receipt_product.dart';

class ReceiptProductForm extends StatefulWidget {
  final Receipt receipt;
  final ReceiptProduct? productSelected;
  final bool isNotHistory;

  const ReceiptProductForm(this.receipt,
      {Key? key, this.productSelected, this.isNotHistory = true})
      : super(key: key);

  @override
  State<ReceiptProductForm> createState() => _ReceiptProductFormState();
}

class _ReceiptProductFormState extends State<ReceiptProductForm> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final ReceiptProductDao _dao = ReceiptProductDao();
  ReceiptProduct? _product;

  // Create a global key that uniquely identifies the Form widget and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _product = widget.productSelected;
    if (_product != null) {
      _productController.text = _product!.product;
      _priceController.text = _product!.price.toStringAsFixed(2);
      _qtController.text = _product!.qt.toString();
      _infoController.text = _product!.info;
    }
    return Scaffold(
      appBar: AppBar(
        title: (widget.isNotHistory
            ? const Text('Produto')
            : const Text('Histórico > Produto')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  validator: (value) => FlutterUtils.validateNotEmpty(value),
                  enabled: widget.isNotHistory,
                  controller: _productController,
                  decoration: const InputDecoration(labelText: 'Produto'),
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: NumberFormField(
                  validator: (value) => FlutterUtils.validateNotEmpty(value),
                  enabled: widget.isNotHistory,
                  controller: _priceController,
                  label: 'Valor recebido',
                  style: const TextStyle(fontSize: 20.0),
                  allowDecimal: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: NumberFormField(
                  enabled: widget.isNotHistory,
                  controller: _qtController,
                  label: 'Quantidade',
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  enabled: widget.isNotHistory,
                  controller: _infoController,
                  decoration: const InputDecoration(labelText: 'Informações'),
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
              Visibility(
                visible: widget.isNotHistory,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _createOrUpdateReceiptProduct();
                          Navigator.pop(context);
                        }
                      },
                      child: _product == null
                          ? const Text('Incluir')
                          : const Text('Atualizar'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createOrUpdateReceiptProduct() async {
    final String product = _productController.text;
    final int qt = int.tryParse(_qtController.text) ?? 1;
    final double price = double.parse(_priceController.text);
    final String info = _infoController.text;

    if (_product == null) {
      _product = ReceiptProduct(qt, product, price, info, widget.receipt.id);
      final int id = await _dao.insert(_product!);
      _product!.id = id;
    } else {
      _product!.product = product;
      _product!.qt = qt;
      _product!.price = price;
      _product!.info = info;
      await _dao.update(_product!);
    }
  }
}
