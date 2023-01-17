import 'package:flutter/material.dart';
import 'package:terralis/components/flutter_utils.dart';
import 'package:terralis/components/full_screen_loading.dart';
import 'package:terralis/components/progress.dart';
import 'package:terralis/components/dart_utils.dart';
import 'package:terralis/database/dao/receipt_dao.dart';
import 'package:terralis/http/gsheets.dart';
import 'package:terralis/models/receipt.dart';
import 'package:terralis/screens/receipt_form.dart';

class ReceiptsList extends StatefulWidget {
  const ReceiptsList({Key? key, this.isNotHistory = true}) : super(key: key);

  final bool isNotHistory;

  @override
  _ReceiptsListState createState() => _ReceiptsListState();
}

class _ReceiptsListState extends State<ReceiptsList> {
  final ReceiptDao _dao = ReceiptDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.isNotHistory
            ? const Text('Recebimentos')
            : const Text('Histórico > Recebimentos')),
        actions: [
          Visibility(
            visible: widget.isNotHistory,
            child: IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showHistoryList(context),
            ),
          ),
          Visibility(
            visible: widget.isNotHistory,
            child: IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => _synchronizeToGsheets(context),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Receipt>>(
        initialData: const [],
        future: (widget.isNotHistory
            ? _dao.findAllUnsynchronized()
            : _dao.findAllSynchronized()),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return const Progress();
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              List<Receipt>? receipts = snapshot.data;
              return ListView.builder(
                itemBuilder: (context, index) {
                  final Receipt receipt = receipts![index];
                  return _ReceiptItem(
                    receipt,
                    onClick: () => _showReceiptForm(context, receipt),
                  );
                },
                itemCount: receipts?.length ?? 0,
              );
          }
          return const Text('Unknown error');
        },
      ),
      floatingActionButton: Visibility(
        visible: widget.isNotHistory,
        child: FloatingActionButton(
          onPressed: () => _showReceiptForm(context, null),
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }

  void _showReceiptForm(BuildContext context, Receipt? receipt) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ReceiptForm(
          receiptSelected: receipt,
          isNotHistory: widget.isNotHistory,
        ),
      ),
    )
        .then((value) {
      setState(() {});
    });
  }

  void _synchronizeToGsheets(BuildContext context) async {
    FocusScope.of(context).unfocus();
    FullScreenLoading(context).start();
    try {
      await gsheetsReceiptsSync();
      setState(() {});
      FlutterUtils.showSnackBar(context, 'Sincronizado com sucesso');
    } on Exception catch (e) {
      FlutterUtils.showErrorSnackBar(context, e);
    }
    FullScreenLoading(context).stop();
  }

  void _showHistoryList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReceiptsList(isNotHistory: false),
      ),
    );
  }
}

class _ReceiptItem extends StatelessWidget {
  final Receipt receipt;
  final Function onClick;

  const _ReceiptItem(
    this.receipt, {
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          '${DartUtils.dateToString(receipt.date)} ${receipt.description}',
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
