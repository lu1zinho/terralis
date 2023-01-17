import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:terralis/components/confirm_dialog.dart';
import 'package:terralis/components/full_screen_loading.dart';
import 'package:terralis/components/message_dialog.dart';
import 'package:terralis/components/qt_used_dialog.dart';
import 'package:terralis/http/gsheets_formulas_stock.dart';

class ProductionList extends StatefulWidget {
  const ProductionList(this._gsheets, this._name, this._wTab, this._production,
      {Key? key})
      : super(key: key);

  final String _name;
  final GsheetsFormulasStock _gsheets;
  final Worksheet _wTab;
  final Production _production;

  @override
  _ProductionListState createState() => _ProductionListState();
}

class _ProductionListState extends State<ProductionList> {
  bool stockWriteOff = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget._name} > ${widget._wTab.title} > \n ${widget._production.cellFormulaName.value}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: stockWriteOff
                ? const Icon(Icons.file_download)
                : const Icon(Icons.file_download_off),
            onPressed: () => setState(() {
              stockWriteOff = !stockWriteOff;
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _ProductionItem.title(
            'Ingrediente',
            'Qtd (g)',
            'Qtd final',
            'Qtd usado',
            onClick: () => null,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              var prodIngred = widget._production.list[index];
              return _ProductionItem(
                prodIngred,
                onClick: () => _dialogQtUsed(context, prodIngred),
              );
            },
            itemCount: widget._production.list.length,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () async {
                  await _produceFormula(context);
                  // Navigator.pop(context);
                },
                child: const Text('Dar baixa'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dialogQtUsed(BuildContext context, ProductionIngredient prodIngred) {
    showDialog(
            context: context,
            builder: (contextDialog) =>
                QtUsedDialog(prodIngred.ingredient, prodIngred.qtUsed))
        .then((value) {
      if (value != null) {
        if (value == '') {
          prodIngred.qtUsed = null;
        } else {
          prodIngred.qtUsed = double.parse(value);
        }
        setState(() {});
      }
    });
  }

  Future<void> _produceFormula(BuildContext context) async {
    var confirm = await showDialog(
      context: context,
      builder: (contextDialog) => ConfirmDialog(
          'Dar baixa? ${stockWriteOff ? 'VALENDO' : 'TESTE'}',
          widget._production.cellFormulaName.value),
    );
    if (confirm != 'OK') {
      return;
    }

    FullScreenLoading(context).start();
    try {
      bool hasError = await widget._gsheets.produceFormula(
        widget._wTab,
        widget._production,
        stockWriteOff: stockWriteOff,
      );
      FullScreenLoading(context).stop();
      if (!hasError) {
        // FlutterUtils.showSnackBar(context, 'Sincronizado com sucesso');
        await showDialog(
          context: context,
          builder: (contextDialog) => const SuccessMessageDialog(
            message: 'Sincronizado com sucesso!',
          ),
        );
      } else {
        await showDialog(
          context: context,
          builder: (contextDialog) => const WarningMessageDialog(
            message: 'Sincronização funcionou com erros.\nVeja no histórico.',
          ),
        );
      }
      Navigator.pop(context);
    } on Exception catch (e) {
      FullScreenLoading(context).stop();
      showDialog(
        context: context,
        builder: (contextDialog) => FailureMessageDialog(
          message: 'Erro na sincronização.\nTente novamente.',
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

class _ProductionItem extends StatelessWidget {
  late final String ingredient;
  late final String qtG;
  late final String qtFinal;
  late final String qtUsed;
  final Function onClick;

  _ProductionItem(
    ProductionIngredient prodIngred, {
    required this.onClick,
  }) {
    ingredient = prodIngred.ingredient;
    qtG = prodIngred.qtG;
    qtFinal = prodIngred.qtFinal;
    qtUsed = prodIngred.qtUsed?.toStringAsFixed(2) ?? '';
  }

  _ProductionItem.title(this.ingredient, this.qtG, this.qtFinal, this.qtUsed,
      {required this.onClick});



  bool isNumberOrTitle() {
    if (ingredient == 'Ingrediente') {
      return true;
    }
    if (qtUsed == '') {
      if (qtFinal == '') {
        return double.tryParse(qtG) != null;
      }
      return double.tryParse(qtFinal) != null;
    }
    return double.tryParse(qtUsed) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isNumberOrTitle() ? null : Colors.yellow,
      child: InkWell(
        onTap: () => onClick(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  ingredient,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: Text(
                  qtG,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: Text(
                  qtFinal,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: Text(
                  qtUsed,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
