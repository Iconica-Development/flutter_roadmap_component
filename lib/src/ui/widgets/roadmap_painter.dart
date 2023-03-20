// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_controller.dart';
import 'package:flutter_roadmap/src/models/roadmap_data.dart';
import 'package:flutter_roadmap/src/models/segment.dart';
import 'package:flutter_roadmap/src/models/theme.dart';
import 'package:flutter_roadmap/src/ui/widgets/marker_painter.dart';

class RoadmapPainter extends CustomPainter {
  const RoadmapPainter({
    required this.controller,
    required this.theme,
    required this.context,
    required this.size,
  });
  final RoadmapController controller;
  final BuildContext context;
  final RoadmapTheme theme;
  final Size size;

  @override
  void paint(Canvas canvas, Size size) {
    var data = controller.data;
    var points = data.points;
    var lines = data.lines;
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

          for (var i = 0; i < segmentLine.segments.length; i++) {
            _drawSegment(
              segmentLine.segments[i],
              size,
              segmentLine.segments[i].segmentEndPoint ?? point.point,
              path,
            );
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
      // if there is a selected line, draw it again with a different color
      if (data.selectedLine != null) {
        _drawHighlightedSegment(canvas, paint);
      }
    }
    if (points.isNotEmpty) {
      // draw all points
      for (var i = 0; i < points.length; i++) {
        var point = points[i];
        drawMarker(
          canvas,
          size,
          context,
          theme: theme,
          point: point,
          index: i,
          isSelected: data.selectedPoint == i,
        );
      }
    }
  }

  static bool lineHitDetected({
    required RoadmapData data,
    required Size size,
    required Offset position,
    void Function(int lineIndex, int segmentIndex)? onSegmentHit,
  }) {
    var points = data.points;
    var lines = data.lines;
    if (points.length > 1) {
      var path = Path();
      path.moveTo(
        points[0].point.x * size.width,
        points[0].point.y * size.height,
      );
      // for all points except the first
      // path.contains is to narrow for hit testing so check multiple variants
      var rect = Rect.fromCircle(
        center: position,
        radius: 1,
      );
      var index = 0;
      for (var point in points.skip(1)) {
        if (lines.length > index) {
          var segmentLine = lines[index];
          for (var i = 0; i < segmentLine.segments.length; i++) {
            _drawSegment(
              segmentLine.segments[i],
              size,
              segmentLine.segments[i].segmentEndPoint ?? point.point,
              path,
            );
            if (rect.overlaps(path.getBounds())) {
              onSegmentHit?.call(index, i);
              return true;
            }
          }
        } else {
          path.lineTo(point.point.x * size.width, point.point.y * size.height);
          if (rect.overlaps(path.getBounds())) {
            onSegmentHit?.call(index, 0);
            return true;
          }
        }
        index++;
      }
    }
    return false;
  }

  void _drawHighlightedSegment(Canvas canvas, Paint paint) {
    var data = controller.data;
    var segment =
        data.lines[data.selectedLine!].segments[data.selectedSegment!];
    // previous point of the segment
    var previousPoint = (data.selectedSegment == 0)
        ? data.points[data.selectedLine!].point
        : data.lines[data.selectedLine!].segments[data.selectedSegment! - 1]
            .segmentEndPoint!;
    var path = Path();
    // move the path to the start of the segment
    path.moveTo(
      previousPoint.x * size.width,
      previousPoint.y * size.height,
    );
    // draw the segment
    _drawSegment(
      segment,
      size,
      segment.segmentEndPoint ?? data.points[data.selectedLine! + 1].point,
      path,
    );
    paint.color =
        theme.selectedLineColor ?? Theme.of(context).colorScheme.primary;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

void _drawSegment(
  Segment segment,
  Size size,
  Point<double> end,
  Path path,
) {
  if (segment.quadraticPoint != null) {
    path.quadraticBezierTo(
      segment.quadraticPoint!.x * size.width,
      segment.quadraticPoint!.y * size.height,
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
