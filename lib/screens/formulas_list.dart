import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:terralis/components/progress.dart';
import 'package:terralis/http/gsheets_formulas_stock.dart';
import 'package:terralis/screens/production_list.dart';

class FormulasList extends StatefulWidget {
  const FormulasList(this._gsheets, this._name, this._wTab, {Key? key})
      : super(key: key);

  final String _name;
  final GsheetsFormulasStock _gsheets;
  final Worksheet _wTab;

  @override
  _FormulasListState createState() => _FormulasListState();
}

class _FormulasListState extends State<FormulasList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget._name} > ${widget._wTab.title}'),
      ),
      body: FutureBuilder<List<FormulaQt>>(
        initialData: const [],
        future: widget._gsheets.getFormulasNames(widget._wTab),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return const Progress();
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              List<FormulaQt>? listFormulaQt = snapshot.data;
              return ListView.builder(
                itemBuilder: (context, index) {
                  final FormulaQt formulaQt = listFormulaQt![index];
                  return _FormulaItem(
                    formulaQt,
                    onClick: () => _showProductionList(context, formulaQt),
                  );
                },
                itemCount: listFormulaQt?.length ?? 0,
              );
          }
          return const Text('Unknown error');
        },
      ),
    );
  }

  void _showProductionList(BuildContext context, FormulaQt formulaQt) {
    var formula = widget._gsheets.getFormula(widget._wTab, formulaQt.formula);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductionList(
            widget._gsheets, widget._name, widget._wTab, formula),
      ),
    )
        .then((value) {
      setState(() {});
    });
  }

/*
  void _dialogProduceFormula(BuildContext context, FormulaQt formulaQt) {
    showDialog(
      context: context,
      builder: (contextDialog) => ConfirmDialog(
          '${formulaQt.formula.value}\n'
              'Quantidade: ${formulaQt.qt}',
          'Deseja dar baixa?'),
    ).then((value) async {
      if (value == 'OK') {
        await _produceFormula(context, formulaQt);
      }
    });
  }

  Future<void> _produceFormula(
      BuildContext context, FormulaQt formulaQt) async {
    FullScreenLoading(context).start();
    try {
      bool hasError =
          await widget._gsheets.produceFormula(widget._wTab, formulaQt.formula);
      FullScreenLoading(context).stop();
      if (!hasError) {
        FlutterUtils.showSnackBar(context, 'Sincronizado com sucesso');
      } else {
        showDialog(
          context: context,
          builder: (contextDialog) => const WarningMessageDialog(
            message: 'Sincronização funcionou com erros.\nVeja no histórico.',
          ),
        );
      }
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
  */
}

class _FormulaItem extends StatelessWidget {
  final FormulaQt formulaQt;
  final Function onClick;

  const _FormulaItem(
    this.formulaQt, {
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          formulaQt.formula.value,
          style: const TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          'Quantidade: ${formulaQt.qt}',
          style: const TextStyle(fontSize: 16.0),
        ),
        trailing: formulaQt.ok
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }
}
