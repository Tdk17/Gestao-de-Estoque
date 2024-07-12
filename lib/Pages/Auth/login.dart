import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:gestaoestoque/Pages/pagina_inicla.dart';

class AccessCodeScreen extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();

  AccessCodeScreen({super.key});

  void _checkAccessCode(BuildContext context) {
    if (_codeController.text == '12345678') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de acesso inválido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 500,
                  width: 500,
                  child: Animate(
                    effects: const [FadeEffect()],
                    child: Image.asset(
                      'assets/logo.gif',
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Digite o código de acesso',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _checkAccessCode(context),
                  child: const Text('Entrar',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
