// lib/services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final _db = FirebaseFirestore.instance;

  /// Crea una reserva en estado 'pending' si no hay otra que se solape
  Future<String> createPending({
    required String userId,
    required String barberId,
    required String serviceId,
    required String branchId,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final ref = _db.collection('bookings').doc();

    // 1) Comprobación de solape con un solo rango en Firestore
    final snap = await _db
        .collection('bookings')
        .where('barberId', isEqualTo: barberId)
        .where('status', whereIn: ['pending', 'paid'])
        // Un solo rango: startAt < endUtc
        .where('startAt', isLessThan: Timestamp.fromDate(endUtc))
        .orderBy('startAt')
        .limit(10)
        .get();

    // 2) Filtrado en memoria para la otra mitad del solapamiento: endAt > startUtc
    final hasOverlap = snap.docs.any((d) {
      final data = d.data();
      final DateTime s = (data['startAt'] as Timestamp).toDate();
      final DateTime e = (data['endAt'] as Timestamp).toDate();
      // Solapa si (s < endUtc) && (e > startUtc)
      return s.isBefore(endUtc) && e.isAfter(startUtc);
    });

    if (hasOverlap) {
      throw Exception('Ese horario ya fue tomado. Elige otro.');
    }

    // 3) Escritura de la reserva
    await ref.set({
      'userId': userId,
      'barberId': barberId,
      'serviceId': serviceId,
      'branchId': branchId,
      'startAt': Timestamp.fromDate(startUtc),
      'endAt': Timestamp.fromDate(endUtc),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  Future<void> markPaid(String bookingId, {required String paymentId}) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'paid',
      'paymentId': paymentId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancel(String bookingId, {String? reason}) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      if (reason != null) 'cancelReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final bookingService = BookingService();
