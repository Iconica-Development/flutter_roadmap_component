// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_line.dart';
import 'package:flutter_roadmap/src/models/roadmap_point.dart';
import 'package:flutter_roadmap/src/models/segment.dart';
import 'package:flutter_roadmap/src/models/theme.dart';
import 'package:flutter_roadmap/src/ui/widgets/marker_painter.dart';

class RoadmapPainter extends CustomPainter {
  const RoadmapPainter({
    required this.points,
    required this.lines,
    required this.theme,
    required this.context,
  });
  final BuildContext context;
  final RoadmapTheme theme;
  final List<RoadmapPoint> points;
  final List<RoadmapLine> lines;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = theme.lineColor ?? Theme.of(context).colorScheme.primary
      ..strokeWidth = theme.lineWidth
      ..style = PaintingStyle.stroke;

    if (points.length > 1) {
      var path = Path();
      path.moveTo(
        points[0].point.x * size.width,
        points[0].point.y * size.height,
      );
      // for all points except the first
      var index = 0;
      for (var point in points.skip(1)) {
        if (lines.length > index) {
          var segmentLine = lines[index];
          if (segmentLine.segment != null) {
            _drawSegment(
              segmentLine.segment!,
              canvas,
              size,
              point.point,
              path,
            );
          } else {
            for (var i = 0; i < segmentLine.segments!.length; i++) {
              _drawSegment(
                segmentLine.segments![i],
                canvas,
                size,
                segmentLine.segments![i].segmentEndPoint ?? point.point,
                path,
              );
            }
          }
        } else {
          path.lineTo(point.point.x * size.width, point.point.y * size.height);
        }
        index++;
      }
      // make it a dotted line
      var dashPath = Path();
      var distance = 0.0;
      var pathMetrics = path.computeMetrics();
      for (var pathMetric in pathMetrics) {
        var pathLength = pathMetric.length;
        while (distance < pathLength) {
          var start = distance;
          distance += theme.dashLength;
          if (distance > pathLength) {
            distance = pathLength;
          }
          var end = distance;
          distance += theme.dashSpace;
          var subPath = pathMetric.extractPath(start, end);
          dashPath.addPath(subPath, Offset.zero);
        }
      }
      canvas.drawPath(dashPath, paint);

      for (var i = 0; i < points.length; i++) {
        var point = points[i];
        paint.color =
            theme.markerColor ?? Theme.of(context).colorScheme.secondary;
        drawMarker(canvas, size, context, theme: theme, point: point, index: i);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawSegment(
    Segment segment,
    Canvas canvas,
    Size size,
    Point<double> end,
    Path path,
  ) {
    if (segment.quadracticPoint != null) {
      path.quadraticBezierTo(
        segment.quadracticPoint!.x * size.width,
        segment.quadracticPoint!.y * size.height,
        end.x * size.width,
        end.y * size.height,
      );
    } else if (segment.cubicPointOne != null && segment.cubicPointTwo != null) {
      path.cubicTo(
        segment.cubicPointOne!.x * size.width,
        segment.cubicPointOne!.y * size.height,
        segment.cubicPointTwo!.x * size.width,
        segment.cubicPointTwo!.y * size.height,
        end.x * size.width,
        end.y * size.height,
      );
    } else {
      path.lineTo(
        end.x * size.width,
        end.y * size.height,
      );
    }
  }
}
