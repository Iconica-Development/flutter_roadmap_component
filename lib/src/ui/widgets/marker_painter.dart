// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/marker.dart';
import 'package:flutter_roadmap/src/models/roadmap_point.dart';
import 'package:flutter_roadmap/src/models/theme.dart';

void drawMarker(
  Canvas canvas,
  Size size,
  BuildContext context, {
  required RoadmapTheme theme,
  required RoadmapPoint point,
  required int index,
}) {
  var markerShape = point.markerShape ?? theme.markerShape;
  var paint = Paint()
    ..color = theme.markerColor ?? Theme.of(context).colorScheme.secondary
    ..strokeWidth = theme.lineWidth
    ..style = PaintingStyle.fill;

  if (markerShape == MarkerShape.hexagon) {
    var hexagonPath = Path();
    hexagonPath.moveTo(
      point.point.x * size.width,
      point.point.y * size.height - theme.markerRadius,
    );
    hexagonPath.lineTo(
      point.point.x * size.width + theme.markerRadius,
      point.point.y * size.height - theme.markerRadius / 2,
    );
    hexagonPath.lineTo(
      point.point.x * size.width + theme.markerRadius,
      point.point.y * size.height + theme.markerRadius / 2,
    );
    hexagonPath.lineTo(
      point.point.x * size.width,
      point.point.y * size.height + theme.markerRadius,
    );
    hexagonPath.lineTo(
      point.point.x * size.width - theme.markerRadius,
      point.point.y * size.height + theme.markerRadius / 2,
    );
    hexagonPath.lineTo(
      point.point.x * size.width - theme.markerRadius,
      point.point.y * size.height - theme.markerRadius / 2,
    );
    hexagonPath.close();
    canvas.drawPath(hexagonPath, paint);
  } else if (markerShape == MarkerShape.circle) {
    canvas.drawCircle(
      Offset(point.point.x * size.width, point.point.y * size.height),
      theme.markerRadius,
      paint,
    );
  } else if (markerShape == MarkerShape.square) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          point.point.x * size.width,
          point.point.y * size.height,
        ),
        width: theme.markerRadius * 2,
        height: theme.markerRadius * 2,
      ),
      paint,
    );
  }
  if (markerShape != MarkerShape.custom) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: (index + 1).toString(),
        style: TextStyle(
          color:
              theme.markerTextColor ?? Theme.of(context).colorScheme.onPrimary,
          fontSize: min(size.width, size.height) / 20,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        point.point.x * size.width - textPainter.width / 2,
        point.point.y * size.height - textPainter.height / 2,
      ),
    );
  }
}
