/* ***************************************************************
 * @author       : Gerardo Yandún
 * @model        : CardModel
 * @description  : Componente modal que presenta el botón de pagos
 * @version      : v1.0.0
 * @copyright    : PagoPlux 2021
 *****************************************************************/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/environment_model.dart';
import '../models/ppxcard_model.dart';
import '../models/response_model.dart';

/// Componente View que presenta el modal con el WebView de PagoPlux
class ModalPagoPluxView extends StatefulWidget {
  final PpxCardModel cardModel;
  final ValueChanged<PagoResponseModel> onClose;

  const ModalPagoPluxView({
    super.key,
    required this.cardModel,
    required this.onClose,
  });

  @override
  State<ModalPagoPluxView> createState() => _ModalPagoPluxViewState();
}

class _ModalPagoPluxViewState extends State<ModalPagoPluxView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final url = getHTML(widget.cardModel); // en tu código original devuelve una URL
    debugPrint('Paybox URL => ${Uri.decodeFull(url)}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            // Si tu pasarela redirige a success/cancel distintos a los channels,
            // puedes detectar aquí:
            // final u = request.url;
            // if (u.startsWith(Environments.successUrl.toString())) { ... }
            // if (u.startsWith(Environments.cancelUrl.toString())) { ... }
            return NavigationDecision.navigate;
          },
        ),
      )
      // Canal JS equivalente a flutter_webview_plugin JavascriptChannel
      ..addJavaScriptChannel(
        'Print',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final Map<String, dynamic> response = jsonDecode(message.message);
            if (response['code'] != 500) {
              final model = PagoResponseModel.fromMap(response);
              widget.onClose(model);
            }
          } catch (e) {
            debugPrint('Error parseando JS message: $e');
          }
          if (mounted) Navigator.of(context).pop();
        },
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('PagoPlux', style: TextStyle(fontSize: 16)),
          centerTitle: false,
          backgroundColor: const Color.fromARGB(250, 22, 155, 213),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.white10,
                  child: Center(
                    child: Text(
                      'Cargando....',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /*
   * Se genera la URL para obtener la URL de pago
   * @param cardModel  Modelo PagoPlux
   */
  String getUrl(PpxCardModel cardModel) {
    String url = '';
    switch (cardModel.payboxEnvironment) {
      case 'product':
        url = Environments.product;
        break;
      case 'prod':
        url = Environments.prod;
        break;
      default:
        url = Environments.sandbox;
        break;
    }
    return url;
  }

  /*
   * Genera la "URL final" (como en tu código original) que apunta
   * a /movilPayboxCards.html con parámetros base64.
   * Si en el futuro pasas a un HTML auto-post, cambia el loadRequest()
   * por loadHtmlString() y devuelve acá el HTML completo.
   */
  String getHTML(PpxCardModel cardModel) {
    String html = '';
    String url = '';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);

    url += '${getUrl(cardModel)}/movilPayboxCards.html?';

    html += 'ppxpaccr=${stringToBase64.encode(cardModel.payboxRemail!)}';
    if (cardModel.payboxSendmail != null) {
      html += '&ppxpaccm=${stringToBase64.encode(cardModel.payboxSendmail!)}';
    }
    if (cardModel.payboxRename != null) {
      html += '&ppxpacae=${stringToBase64.encode(cardModel.payboxRename!)}';
    }
    if (cardModel.payboxSendname != null) {
      html += '&ppxpaccn=${stringToBase64.encode(cardModel.payboxSendname!)}';
    }
    if (cardModel.payboxListCard != null) {
      html +=
          '&ppxpacaw=${stringToBase64.encode(cardModel.payboxListCard.toString())}';
    }
    html +=
        '&ppxpacap=${stringToBase64.encode(cardModel.payboxProduction.toString())}';
    if (cardModel.payboxLanguage != null) {
      html += '&ppxpacal=${stringToBase64.encode(cardModel.payboxLanguage!)}';
    }
    if (cardModel.payboxDirection != null) {
      html += '&ppxpaccd=${stringToBase64.encode(cardModel.payboxDirection!)}';
    }
    if (cardModel.payboxClientPhone != null) {
      html += '&ppxpaccp=${stringToBase64.encode(cardModel.payboxClientPhone!)}';
    }
    if (cardModel.payboxClientIdentification != null) {
      html +=
          '&ppxpacci=${stringToBase64.encode(cardModel.payboxClientIdentification!)}';
    }
    if (cardModel.payboxIdPlan != null) {
      html += '&ppxpacca=${stringToBase64.encode(cardModel.payboxIdPlan.toString())}';
    }
    if (cardModel.payboxEnvironment != null) {
      html += '&ppxpacaa=${stringToBase64.encode(cardModel.payboxEnvironment!)}';
    }
    if (cardModel.paybBoxIdSuscription != null) {
      html += '&ppxpacsu=${stringToBase64.encode(cardModel.paybBoxIdSuscription!)}';
    }
    return url + stringToBase64.encode(html);
  }
}
