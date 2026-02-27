import 'package:geolocator/geolocator.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Проверка, включен ли GPS
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return Future.error('GPS выключен');

  // Проверка и запрос разрешений
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return Future.error('Разрешение отклонено');
  }

  if (permission == LocationPermission.deniedForever) return Future.error('Разрешение отклонено навсегда');

  // Получение позиции
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
}
