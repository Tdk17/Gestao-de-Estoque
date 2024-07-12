import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestaoestoque/Db/Db_model.dart';
import 'package:gestaoestoque/Pages/pagina_inicla.dart';
import 'package:gestaoestoque/model/produt_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = false;
  // ignore: unused_field
  String _reportPath = '';
  final String _apiKey =
      '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'; // Substitua pela sua chave de API
  final String _reportContent = '';
  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch data from SQLite
      final products = await DatabaseHelper().getProducts();
      final summaryData = await DatabaseHelper().getStockSummary();

      // Generate report using OpenAI API
      final reportContent = await _fetchReportFromAI(products, summaryData);

      // Create PDF (Você já deve ter a função _createPdf implementada)
      final pdfFile = await _createPdf(reportContent);

      setState(() {
        _isLoading = false;
        _reportPath = pdfFile.path;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar relatório: $e')),
      );
    }
  }

  Future<String> _fetchReportFromAI(
      List<Product> products, Map<String, dynamic> summaryData) async {
    const apiUrl = 'https://api.openai.com/v1/chat/completions';
    final prompt =
        'Generate a stock report with the following data: ${summaryData.toString()}, Products: ${products.toString()}';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to fetch report from AI: ${response.body}');
    }
  }

  Future<File> _createPdf(String content) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text(content),
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/report.pdf");
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      throw Exception('Failed to create PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Análise de Estoque',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generateReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_reportContent.isNotEmpty)
                      const Text(
                        'Relatório Gerado:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    Text(_reportContent),
                  ],
                ),
              ),
      ),
    );
  }
}
