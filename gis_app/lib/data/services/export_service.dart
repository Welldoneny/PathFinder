import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gis_app/data/models/route_point.dart';
import 'dart:convert';

import 'package:gis_app/utils/result.dart';

class ExportService {
  static Future<MyResult<String>> saveToFile(
    String content,
    String fileName,
  ) async {
    try {
      if (kIsWeb) {
        // на вебе file_picker сам сохраняет bytes, путь не нужен
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранить маршрут',
          fileName: fileName,
          bytes: utf8.encode(content),
        );
        if (path == null) return Error(Exception('Сохранение отменено'));
        return Ok(fileName); // на вебе реального пути нет
      } else {
        // mobile/desktop — получаем путь, пишем сами
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранить маршрут',
          fileName: fileName,
        );
        if (path == null) return Error(Exception('Сохранение отменено'));

        final file = File(path);
        await file.writeAsString(content);
        return Ok(path);
      }
    } catch (e) {
      return Error(Exception('Не удалось сохранить файл: $e'));
    }
  }

  static String toGpx(List<RoutePoint> points, String name) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<gpx version="1.1" creator="PathFinder" xmlns="http://www.topografix.com/GPX/1/1">',
    );
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>$name</name>');
    buffer.writeln('    <trkseg>');
    for (final point in points) {
      buffer.writeln(
        '      <trkpt lat="${point.latitude}" lon="${point.longitude}">',
      );
      buffer.writeln('        <ele>${point.altitude}</ele>');
      buffer.writeln('      </trkpt>');
    }
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    return buffer.toString();
  }

  static String toKml(List<RoutePoint> points, String name) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<kml xmlns="http://www.opengis.net/kml/2.2">');
    buffer.writeln('  <Document>');
    buffer.writeln('    <name>$name</name>');
    buffer.writeln('    <Placemark>');
    buffer.writeln('      <name>$name</name>');
    buffer.writeln('      <LineString>');
    buffer.writeln('        <altitudeMode>absolute</altitudeMode>');
    buffer.writeln('        <coordinates>');
    for (final point in points) {
      buffer.writeln(
        '          ${point.longitude},${point.latitude},${point.altitude ?? 0}',
      );
    }
    buffer.writeln('        </coordinates>');
    buffer.writeln('      </LineString>');
    buffer.writeln('    </Placemark>');
    buffer.writeln('  </Document>');
    buffer.writeln('</kml>');
    return buffer.toString();
  }

  static Future<MyResult<String>> exportRoute(
    List<RoutePoint> points,
    String name,
    String format,
  ) async {
    final content = format == 'gpx' ? toGpx(points, name) : toKml(points, name);
    final fileName = '$name.$format';
    return await saveToFile(content, fileName);
  }
}
