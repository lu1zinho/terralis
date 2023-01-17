import 'package:flutter/material.dart';
import 'package:terralis/screens/formulas_tabs_list.dart';
import 'package:terralis/screens/receipts_list.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Image.network('https://cdn.pixabay.com/photo/2022/03/01/09/35/iceland-poppy-7040946_1280.jpg')
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Image.asset('images/terralis L2.png'),
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FeatureItem(
                  'Recebimentos',
                  Icons.monetization_on,
                  onClick: () => _showReceiptsList(context),
                ),
                _FeatureItem(
                  'Receitas Terralis',
                  Icons.description,
                  onClick: () => _showFormulasTabsList(context, 'Terralis'),
                ),_FeatureItem(
                  'Receitas Yoga-se',
                  Icons.description,
                  onClick: () => _showFormulasTabsList(context, 'Yoga-se'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptsList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReceiptsList(),
      ),
    );
  }

  _showFormulasTabsList(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormulasTabsList(id),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Function onClick;

  const _FeatureItem(
    this.name,
    this.icon, {
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          onTap: () => onClick(),
          child: Container(
              padding: const EdgeInsets.all(8.0),
              height: 100,
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
