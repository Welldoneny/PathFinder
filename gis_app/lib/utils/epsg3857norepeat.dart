import 'package:flutter_map/flutter_map.dart';

class Epsg3857NoRepeat extends Epsg3857 {
  const Epsg3857NoRepeat();

  @override
  bool get replicatesWorldLongitude => false;
}