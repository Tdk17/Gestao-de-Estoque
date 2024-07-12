import 'package:flutter/material.dart';
import 'package:gestaoestoque/Db/Db_model.dart';
import 'package:gestaoestoque/Pages/AnalisePdf/analise_pdf.dart';
import 'package:gestaoestoque/Pages/Cadastro%20de%20produtos/cadastro_product.dart';

import 'package:gestaoestoque/Pages/Conferencia%20%20De%20pre%C3%A7os/Conferencia_page.dart';

import 'package:gestaoestoque/Pages/Scanner/scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 42, 42),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Gestão de Estoque',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Dashboard(),
            const SizedBox(height: 90),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scanner Produto',
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ProductRegistrationScreen()));
                    },
                  ),
                  ActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scanner',
                    onPressed: () {
                      // Ação do botão de scanner
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScannerScreen()));
                    },
                  ),
                  ActionButton(
                    icon: Icons.import_export,
                    label: 'Importar/Exportar',
                    onPressed: () {
                      // Ação do botão de importar/exportar
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AnalysisScreen()));
                    },
                  ),
                  ActionButton(
                    icon: Icons.history,
                    label: 'Histórico',
                    onPressed: () {
                      // Ação do botão de histórico
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PriceCheckScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

  Future<void> _fetchSummaryData() async {
    final summaryData = await DatabaseHelper().getStockSummary();
    setState(() {
      _summaryData = summaryData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 179, 67, 2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Resumo de Estoque',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Total de Itens: ${_summaryData?['totalItems'] ?? 0}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(
                      'Itens em Falta: ${_summaryData?['outOfStockItems'] ?? 0}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(
                      'Última Atualização: ${_summaryData?['lastUpdate'] ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 63, 133, 238),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
