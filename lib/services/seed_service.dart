import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  final _db = FirebaseFirestore.instance;

  Future<void> seedDemoData() async {
    final batch = _db.batch();

    // Branch
    final branchRef = _db.collection('branches').doc('central');
    batch.set(branchRef, {
      'name': 'Sucursal Central',
      'address': 'Av. Principal 123',
      'tz': 'America/Guayaquil',
      'phone': '+593999999999',
    });

    // Services
    final corteRef  = _db.collection('services').doc('corte');
    final barbaRef  = _db.collection('services').doc('barba');
    batch.set(corteRef, {'name': 'Corte', 'durationMin': 30, 'price': 8000, 'description': 'Corte clásico'}); // cents
    batch.set(barbaRef, {'name': 'Barba', 'durationMin': 20, 'price': 5000, 'description': 'Arreglo de barba'});

    // Barbers
    final b1 = _db.collection('barbers').doc('barber_juan');
    final b2 = _db.collection('barbers').doc('barber_maria');
    batch.set(b1, {
      'name': 'Juan',
      'photoUrl': null,
      'services': ['corte', 'barba'],
      'branchId': 'central',
      'active': true,
      'rating': 4.8,
    });
    batch.set(b2, {
      'name': 'María',
      'photoUrl': null,
      'services': ['corte'],
      'branchId': 'central',
      'active': true,
      'rating': 4.9,
    });

    await batch.commit();

    // Schedules (uno por barbero)
    await _db.collection('schedules').doc('barber_juan').set({
      'workingDays': {
        'mon': {'from': '09:00', 'to': '18:00'},
        'tue': {'from': '09:00', 'to': '18:00'},
        'wed': {'from': '09:00', 'to': '18:00'},
        'thu': {'from': '09:00', 'to': '18:00'},
        'fri': {'from': '09:00', 'to': '18:00'},
        'sat': {'from': '09:00', 'to': '14:00'},
      },
      'breaks': [
        {'from': '13:00', 'to': '14:00'}
      ],
      'blackoutDates': [] // ['2025-08-25']
    });

    await _db.collection('schedules').doc('barber_maria').set({
      'workingDays': {
        'mon': {'from': '10:00', 'to': '18:00'},
        'tue': {'from': '10:00', 'to': '18:00'},
        'wed': {'from': '10:00', 'to': '18:00'},
        'thu': {'from': '10:00', 'to': '18:00'},
        'fri': {'from': '10:00', 'to': '18:00'},
      },
      'breaks': [],
      'blackoutDates': []
    });
  }
}

final seedService = SeedService();
