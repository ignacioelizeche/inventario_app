import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para MethodChannel

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Inventario de Productos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode(); // <-- Add this
  final FocusNode _barcodeFocusNode = FocusNode(); // <-- Nuevo

  // Define el nombre del canal. Debe coincidir con el nombre en Kotlin.
  static const platform = MethodChannel('com.example.inventario_app/scanner');

  @override
  void initState() {
    super.initState();
    // Configura el listener para las llamadas de métodos desde el código nativo (Kotlin)
    platform.setMethodCallHandler(_handleMethodCall);
  }

  // Maneja las llamadas de métodos desde Kotlin
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onBarcodeScanned':
        final String barcode = call.arguments;

        // Guarda el focus actual
        final currentFocus = FocusScope.of(context).focusedChild;

        setState(() {
          _barcodeController.text = barcode;
        });

        // Opcional: selecciona todo el texto del barcode
        _barcodeController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _barcodeController.text.length,
        );

        // Restaura el focus anterior si existía
        if (currentFocus != null) {
          FocusScope.of(context).requestFocus(currentFocus);
        }

        break;
      default:
        print('Método desconocido llamado: ${call.method}');
  }
}

  @override
  void dispose() {
    _quantityController.dispose();
    _barcodeController.dispose();
    _quantityFocusNode.dispose(); // <-- Dispose focus node
    _barcodeFocusNode.dispose(); // <-- Nuevo
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ingrese la cantidad del producto',
                  border: OutlineInputBorder(),
                ),
                onTap: () {
                  // Permite el foco para que el escáner o el teclado físico funcionen
                  FocusScope.of(context).requestFocus(_quantityFocusNode);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _barcodeController,
                focusNode: _barcodeFocusNode,
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras',
                  hintText: 'Escanee o ingrese el código de barras',
                  border: OutlineInputBorder(),
                ),        
                onTap: () {
                  // Permite el foco para que el escáner o el teclado físico funcionen
                  FocusScope.of(context).requestFocus(_barcodeFocusNode);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Ejemplo: imprimir los valores
                  print('Cantidad: ${_quantityController.text}');
                  print('Código de Barras: ${_barcodeController.text}');
                  // Aquí podrías agregar lógica para guardar los datos, etc.
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}