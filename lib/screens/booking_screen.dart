import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import '../component/paybox.dart';
import '../models/ppxcard_model.dart';
import '../models/response_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ====== Datos dummy (puedes reemplazar por Firestore si ya lo gestionas) ======
  final _barbers = const [
    {'id': 'b1', 'name': 'Ana'},
    {'id': 'b2', 'name': 'Luis'},
  ];

  final _branches = const [
    {'id': 'br1', 'name': 'Centro'},
    {'id': 'br2', 'name': 'Norte'},
  ];

  final _services = const [
    {'id': 's1', 'name': 'Corte Clásico', 'minutes': 30, 'price': 12.0},
    {'id': 's2', 'name': 'Corte + Barba', 'minutes': 45, 'price': 18.0},
    {'id': 's3', 'name': 'Corte Premium', 'minutes': 60, 'price': 25.0},
  ];

  // ====== Selecciones ======
  String? _barberId;
  String? _branchId;
  Map<String, dynamic>? _service;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _loading = false;

  // ====== Pickers ======
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: _selectedDate ?? now,
    );
    if (!mounted) return;
    setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (!mounted) return;
    setState(() => _selectedTime = t);
  }

  // ====== Crear reserva + abrir pasarela ======
  Future<void> _reserveAndPay() async {
    if (_barberId == null || _branchId == null || _service == null) {
      _showSnack('Selecciona barber@, sucursal y servicio');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showSnack('Selecciona fecha y hora');
      return;
    }

    final localStart = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final startUtc = localStart.toUtc();
    final endUtc = startUtc.add(Duration(minutes: _service!['minutes'] as int));

    final user = FirebaseAuth.instance.currentUser!;
    final serviceId = _service!['id'] as String;

    setState(() => _loading = true);
    String bookingId;

    try {
      // 1) Crea reserva en pending
      bookingId = await bookingService.createPending(
        userId: user.uid,
        barberId: _barberId!,
        serviceId: serviceId,
        branchId: _branchId!,
        startUtc: startUtc,
        endUtc: endUtc,
      );
    } catch (e) {
      setState(() => _loading = false);
      _showSnack(e.toString());
      return;
    }

    // 2) Armar el modelo para la pasarela (ajusta los valores reales)
    final card = PpxCardModel()
      ..payboxRemail = user.email ?? 'djegameryt@gmail.com'
      ..payboxSendmail = 'djegameryt@gmail.com'
      ..payboxRename = 'Barbería EliteStyle'
      ..payboxSendname = user.displayName ?? 'Cliente'
      ..payboxListCard = 0
      ..payboxProduction = false // Cambia a true en producción real
      ..payboxLanguage = 'es'
      ..payboxDirection = 'Dirección del cliente'
      ..payboxClientPhone = '0999999999'
      ..payboxClientIdentification = '9999999999'
      ..payboxIdPlan = null // si usas plan/suscripción, ajusta
      ..payboxEnvironment = 'sandbox'; // 'product' / 'prod' / 'sandbox'

    // 3) Abrir el modal de pago
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ModalPagoPluxView(
          cardModel: card,
          onClose: (PagoResponseModel resp) async {
            // 4) Interpretar respuesta de pasarela de forma segura
            final String state = (() {
              final d = resp.detail as dynamic;
              return (d?.state ?? '').toString().toLowerCase();
            })();

            final String paymentId = (() {
              final d = resp.detail as dynamic;
              final candidates = [
                d?.voucher,
                d?.id,
                // d?.transactionId, // si tu modelo lo añade en el futuro
              ];
              final first = candidates.firstWhere(
                (e) => e != null && e.toString().trim().isNotEmpty,
                orElse: () => 'N/A',
              );
              return first.toString();
            })();

            if (state.contains('aprob') || state == 'paid' || state == 'success') {
              await bookingService.markPaid(bookingId, paymentId: paymentId);
              _showSnack('¡Pago aprobado y reserva confirmada!');
            } else {
              // si quieres cancelar la reserva en caso de fallo:
              // await bookingService.cancel(bookingId, reason: state);
              _showSnack('Pago no aprobado: $state');
            }
          },
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    final price = (_service?['price'] as num?)?.toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Reservar corte')),
      body: AbsorbPointer(
        absorbing: _loading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _barberId,
              items: _barbers
                  .map((b) => DropdownMenuItem(
                        value: b['id'] as String,
                        child: Text(b['name'] as String),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _barberId = v),
              decoration: const InputDecoration(
                labelText: 'Barber@',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _branchId,
              items: _branches
                  .map((b) => DropdownMenuItem(
                        value: b['id'] as String,
                        child: Text(b['name'] as String),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _branchId = v),
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _service,
              items: _services
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s['name']}  (\$${s['price']})'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _service = v),
              decoration: const InputDecoration(
                labelText: 'Servicio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event),
                    label: Text(_selectedDate == null
                        ? 'Fecha'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(_selectedTime == null
                        ? 'Hora'
                        : _selectedTime!.format(context)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (price != null)
              Text(
                'Total a pagar: \$${price.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: Text(_loading ? 'Procesando...' : 'Reservar y pagar'),
              onPressed: _loading ? null : _reserveAndPay,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
