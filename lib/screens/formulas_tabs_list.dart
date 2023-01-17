import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:terralis/http/gsheets_formulas_stock.dart';
import 'package:terralis/components/progress.dart';
import 'package:terralis/components/centered_message.dart';
import 'package:terralis/screens/formulas_history_list.dart';
import 'package:terralis/screens/formulas_list.dart';

class FormulasTabsList extends StatefulWidget {
  FormulasTabsList(this._name, {Key? key}) : super(key: key) {
    _gsheets = GsheetsFormulasStock(_name);
  }

  final String _name; //Terralis ou Yoga-se
  late final GsheetsFormulasStock _gsheets;

  @override
  _FormulasTabsListState createState() => _FormulasTabsListState();
}

class _FormulasTabsListState extends State<FormulasTabsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receitas ${widget._name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryList(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Worksheet>>(
        initialData: const [],
        future: widget._gsheets.getFormulasTabs(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return const Progress();
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              List<Worksheet>? formulasTabs = snapshot.data;
              if (formulasTabs == null) {
                return CenteredMessage(
                  'Erro ao carregar receitas',
                  message2: snapshot.error.toString(),
                  icon: Icons.error,
                );
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  final Worksheet wTab = formulasTabs[index];
                  return _FormulaTabItem(
                    wTab,
                    onClick: () => _showFormulasList(context, wTab),
                  );
                },
                itemCount: formulasTabs.length,
              );
          }
          return const Text('Unknown error');
        },
      ),
    );
  }

  void _showFormulasList(BuildContext context, Worksheet wTab) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) =>
            FormulasList(widget._gsheets, widget._name, wTab),
      ),
    )
        .then((value) {
      setState(() {});
    });
  }

  void _showHistoryList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormulasHistoryList(widget._gsheets),
      ),
    );
  }
}

class _FormulaTabItem extends StatelessWidget {
  final Worksheet wTab;
  final Function onClick;

  const _FormulaTabItem(
    this.wTab, {
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          wTab.title,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
