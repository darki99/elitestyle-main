import 'package:flutter/material.dart';

import '../component/paybox.dart';
import '../models/ppxcard_model.dart';
import '../models/response_model.dart';

/// Demo de uso del botón de pago
class PayboxDemoPage extends StatefulWidget {
  const PayboxDemoPage({super.key});

  @override
  State<PayboxDemoPage> createState() => _PayboxDemoPageState();
}

class _PayboxDemoPageState extends State<PayboxDemoPage> {
  late PpxCardModel _cardModelExample;
  String voucher = 'Pendiente Pago';

  @override
  void initState() {
    super.initState();
    _openPpx(); // inicializamos el modelo de la pasarela una sola vez
  }

  /// Inicializa los datos para el proceso de pago
  void _openPpx() {
    _cardModelExample = PpxCardModel();
    _cardModelExample.payboxRemail = 'djegameryt@gmail.com';
    _cardModelExample.payboxSendmail = 'djegameryt@gmail.com';
    _cardModelExample.payboxRename = 'Razer';
    _cardModelExample.payboxSendname = 'John Doe';
    _cardModelExample.payboxListCard = 0;
    _cardModelExample.payboxProduction = false;
    _cardModelExample.payboxLanguage = 'es';
    _cardModelExample.payboxDirection = 'Quito, Pichincha, Ecuador';
    _cardModelExample.payboxClientPhone = '987654321';
    _cardModelExample.payboxClientIdentification = '1002003001';
    _cardModelExample.payboxIdPlan = null;
    _cardModelExample.payboxEnvironment = 'product';
    /*
    _cardModelExample.paybBoxIdSuscription =
        'ZjlhOWQxMGQtOTFjMC00OTc4LTk4NTItNWQ1NDUzMWUwMzRi'; // si aplica
    */
  }

  /// Abre el modal con el WebView de pago usando el modal nativo de Flutter
  Future<void> _launchPaybox() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ModalPagoPluxView(
          cardModel: _cardModelExample,
          onClose: obtenerDatos, // callback cuando llega el mensaje JS "Print"
        ),
      ),
    );
  }

  /// Recibe el resultado desde el WebView (canal JS 'Print')
  void obtenerDatos(PagoResponseModel datos) {
    voucher = 'Voucher: ${datos.detail.state}';
    setState(() {});
    // También puedes hacer lógica extra aquí (guardar en Firestore, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Flutter PPX'),
        actions: const [Icon(Icons.access_alarm)],
      ),
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
        margin: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Text(
          voucher,
          style: const TextStyle(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _launchPaybox,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.payments_rounded),
      ),
    );
  }
}
