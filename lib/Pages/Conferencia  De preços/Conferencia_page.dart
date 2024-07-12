import 'package:flutter/material.dart';
import 'package:gestaoestoque/Db/Db_model.dart';
import 'package:gestaoestoque/model/produt_model.dart';
import 'dart:io';

import 'package:gestaoestoque/Pages/pagina_inicla.dart';

class PriceCheckScreen extends StatefulWidget {
  const PriceCheckScreen({super.key});

  @override
  _PriceCheckScreenState createState() => _PriceCheckScreenState();
}

class _PriceCheckScreenState extends State<PriceCheckScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final products = await DatabaseHelper().getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 42, 42),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
        title: const Text(
          'Conferência de Preços',
          style: TextStyle(color: Colors.white),
        ),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (product.imagePath != null)
                  SizedBox(
                      height: 300, child: Image.file(File(product.imagePath!))),
                const SizedBox(height: 10),
                Text(
                  'Produto: ${product.name}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Preço Atual: R\$ ${product.price.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                Text('Quantidade em Estoque: ${product.quantity}'),
                const SizedBox(height: 10),
                Text('Código de Barras: ${product.barcode}'),
                const SizedBox(height: 10),
                const Divider(),
                const Text(
                  'Histórico de Preços',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildPriceHistoryList(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHistoryList(Product product) {
    // Exemplo de dados de histórico, substitua com os dados reais
    List<PriceHistory> priceHistory = [
      PriceHistory(
          date: '2024-06-01', price: product.price, supplier: 'Fornecedor A'),
      PriceHistory(
          date: '2024-06-02',
          price: product.price * 1.05,
          supplier: 'Fornecedor B'),
    ];

    return Column(
      children: priceHistory.map((history) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
          child: ListTile(
            title: Text('Data: ${history.date}'),
            subtitle: Text('Preço: R\$ ${history.price.toStringAsFixed(2)}'),
            trailing: Text('Fornecedor: ${history.supplier}'),
          ),
        );
      }).toList(),
    );
  }
}
