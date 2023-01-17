import 'package:flutter/material.dart';
import 'package:terralis/components/flutter_utils.dart';
import 'package:terralis/components/full_screen_loading.dart';
import 'package:terralis/components/progress.dart';
import 'package:terralis/database/dao/history_dao.dart';
import 'package:terralis/http/gsheets_formulas_stock.dart';
import 'package:terralis/models/history.dart';

class FormulasHistoryList extends StatefulWidget {
  final GsheetsFormulasStock _gsheets;

  const FormulasHistoryList(this._gsheets, {Key? key}) : super(key: key);

  @override
  _FormulasHistoryListState createState() => _FormulasHistoryListState();
}

class _FormulasHistoryListState extends State<FormulasHistoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas > Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => _synchronizeToGsheets(context),
          ),
        ],
      ),
      body: FutureBuilder<List<History>>(
        initialData: const [],
        future: HistoryDao().findAll(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return const Progress();
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              List<History>? listHistory = snapshot.data;
              return ListView.builder(
                itemBuilder: (context, index) {
                  final History history = listHistory![index];
                  return _FormulaHistoryItem(
                    history,
                  );
                },
                itemCount: listHistory?.length ?? 0,
              );
          }
          return const Text('Unknown error');
        },
      ),
    );
  }

  void _synchronizeToGsheets(BuildContext context) async {
    FullScreenLoading(context).start();
    var historyDao = HistoryDao();
    var listHistory = await historyDao.findAll();
    try {
      await widget._gsheets.synchronizeHistory(listHistory, noDao: true);
      await historyDao.deleteAll();
      setState(() {});
      FlutterUtils.showSnackBar(context, 'Sincronizado com sucesso');
    } on Exception catch (e) {
      FlutterUtils.showErrorSnackBar(context, e);
    }
    FullScreenLoading(context).stop();
  }
}

class _FormulaHistoryItem extends StatelessWidget {
  final History history;

  const _FormulaHistoryItem(this.history);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          history.toString(),
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
