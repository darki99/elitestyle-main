import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Slot {
  final DateTime startUtc;
  final DateTime endUtc;
  final String label; // ej. 15:00

  Slot(this.startUtc, this.endUtc, this.label);
}

class SlotService {
  final _db = FirebaseFirestore.instance;

  // date es el día en hora local de la sucursal (00:00)
  Future<List<Slot>> generateSlots({
    required String barberId,
    required String serviceId,
    required DateTime date, // local
    int bufferMin = 5,
    String branchTz = 'America/Guayaquil',
  }) async {
    // 1) carga duración del servicio
    final serviceSnap = await _db.collection('services').doc(serviceId).get();
    final durationMin = (serviceSnap.data()?['durationMin'] ?? 30) as int;

    // 2) horario del barbero
    final sched = await _db.collection('schedules').doc(barberId).get();
    final working = sched.data()?['workingDays'] ?? {};
    final breaks = List<Map<String, dynamic>>.from(sched.data()?['breaks'] ?? []);
    final weekday = DateFormat('E').format(date).toLowerCase().substring(0,3); // mon,tue,...

    if (!working.containsKey(weekday)) return [];

    final fromStr = working[weekday]['from'] as String; // "09:00"
    final toStr   = working[weekday]['to']   as String; // "18:00"

    DateTime atTime(String hhmm) {
      final h = int.parse(hhmm.split(':')[0]);
      final m = int.parse(hhmm.split(':')[1]);
      return DateTime(date.year, date.month, date.day, h, m);
    }

    final workStart = atTime(fromStr);
    final workEnd   = atTime(toStr);

    // 3) rangos NO disponibles (breaks)
    final breakRanges = breaks.map((b) {
      return [atTime(b['from']), atTime(b['to'])];
    }).toList();

    // 4) reservas existentes (pending/paid)
    final dayStartUtc = workStart.toUtc();
    final dayEndUtc   = workEnd.toUtc();
    final bookings = await _db.collection('bookings')
      .where('barberId', isEqualTo: barberId)
      .where('status', whereIn: ['pending','paid'])
      .where('startAt', isLessThan: dayEndUtc)
      .where('endAt', isGreaterThan: dayStartUtc)
      .get();

    final busy = bookings.docs.map((d) {
      final s = (d['startAt'] as Timestamp).toDate();
      final e = (d['endAt'] as Timestamp).toDate();
      return [s.toLocal(), e.toLocal()];
    }).toList();

    // 5) genera slots
    final List<Slot> result = [];
    DateTime cursor = workStart;
    final step = Duration(minutes: 5); // iteramos fino para respetar buffer
    final dur  = Duration(minutes: durationMin + bufferMin);

    bool overlaps(DateTime s1, DateTime e1, DateTime s2, DateTime e2) =>
        s1.isBefore(e2) && s2.isBefore(e1);

    while (cursor.add(Duration(minutes: durationMin)).isBefore(workEnd) ||
           cursor.add(Duration(minutes: durationMin)).isAtSameMomentAs(workEnd)) {

      final slotStart = cursor;
      final slotEnd   = cursor.add(Duration(minutes: durationMin));

      // descarta si se pisa con breaks o busy
      final blocked = [
        ...breakRanges,
        ...busy,
      ].any((r) => overlaps(slotStart, slotEnd, r[0], r[1]));

      if (!blocked) {
        result.add(Slot(slotStart.toUtc(), slotEnd.toUtc(), DateFormat('HH:mm').format(slotStart)));
      }

      cursor = cursor.add(step);
      // evita terminar en medio de la jornada (no estrictamente necesario)
      if (cursor.isAfter(workEnd)) break;
    }

    return result;
  }
}

final slotService = SlotService();
