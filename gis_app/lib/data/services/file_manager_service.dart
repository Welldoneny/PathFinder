// data/services/route_import_service.dart
import 'dart:io';

import 'package:gis_app/data/models/route_point.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:xml/xml.dart';
class FileManagerService {
  Future<List<RoutePoint>?> pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gpx', 'kml'],
    );
    if (result == null) return null;

    final file = result.files.first;
    String xmlString;

    if (file.bytes != null) {
      xmlString = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      xmlString = await File(file.path!).readAsString();
    } else {
      return null;
    }

    if (file.extension == 'gpx') return _parseGpx(xmlString);
    if (file.extension == 'kml') return _parseKml(xmlString);
    return null;
  }

  List<RoutePoint> _parseGpx(String xmlString) {
    final points = <RoutePoint>[];
    final gpx = GpxReader().fromString(xmlString);
    for (final track in gpx.trks) {
      for (final segment in track.trksegs) {
        for (final point in segment.trkpts) {
          points.add(RoutePoint(
            latitude: point.lat ?? 0,
            longitude: point.lon ?? 0,
            altitude: point.ele ?? 0,
          ));
        }
      }
    }
    return points;
  }

  List<RoutePoint> _parseKml(String kmlString) {
    final document = XmlDocument.parse(kmlString);
    final lineString = document.findAllElements('LineString').firstOrNull;
    if (lineString == null) return [];

    final coordinates = lineString
        .findElements('coordinates')
        .first
        .innerText
        .trim();

    return coordinates
        .split(RegExp(r'\s+'))
        .where((coord) => coord.isNotEmpty)
        .map((coord) {
          final parts = coord.split(',');
          if (parts.length < 2) return null;
          return RoutePoint(
            longitude: double.tryParse(parts[0]) ?? 0,
            latitude: double.tryParse(parts[1]) ?? 0,
            altitude: parts.length > 2 ? double.tryParse(parts[2]) ?? 0 : 0,
          );
        })
        .whereType<RoutePoint>()
        .toList();
  }
}