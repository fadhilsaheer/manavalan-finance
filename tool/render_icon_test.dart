import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:manavalan_finance/ui/theme.dart';

void main() {
  test('render original launcher artwork', () async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    BrandPainter().paint(canvas, const ui.Size(1024, 1024));
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('assets/icon/app-icon.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
  });
}
