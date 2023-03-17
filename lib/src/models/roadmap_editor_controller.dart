import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_data.dart';
import 'package:flutter_roadmap/src/models/roadmap_line.dart';
import 'package:flutter_roadmap/src/models/roadmap_point.dart';
import 'package:flutter_roadmap/src/models/segment.dart';

class RoadmapEditorController extends ChangeNotifier {
  RoadmapEditorController({
    RoadmapData? data,
  }) : _data = data ?? const RoadmapData(lines: [], points: []);
  RoadmapData _data;

  RoadmapData get data => _data;

  set data(RoadmapData data) {
    _data = data;
    notifyListeners();
  }

  void changeSegmentCurveType(
    Segment segment,
    int lineIndex,
    int? segmentIndex,
  ) {
    if (segment.quadraticPoint != null) {
      // change the segment to a cubic curve

      var previousPoint = (segmentIndex != null)
          ? data.lines[lineIndex].segments![segmentIndex - 1].segmentEndPoint!
          : data.points[lineIndex].point;
      var updatedSegment = segment.copyWith(
        removeQuadratic: true,
        cubicPointOne: Point(
          (previousPoint.x + segment.segmentEndPoint!.x) / 2 + 0.01,
          (previousPoint.y + segment.segmentEndPoint!.y) / 2,
        ),
        cubicPointTwo: Point(
          (previousPoint.x + segment.segmentEndPoint!.x) / 2 - 0.01,
          (previousPoint.y + segment.segmentEndPoint!.y) / 2,
        ),
      );
      if (segmentIndex != null) {
        data = data.copyWith(
          lines: [
            ...data.lines.sublist(0, lineIndex),
            data.lines[lineIndex].copyWith(
              segments: [
                ...data.lines[lineIndex].segments!.sublist(0, segmentIndex),
                updatedSegment,
                ...data.lines[lineIndex].segments!.sublist(segmentIndex + 1),
              ],
            ),
            ...data.lines.sublist(lineIndex + 1),
          ],
        );
      } else {
        data = data.copyWith(
          lines: [
            ...data.lines.sublist(0, lineIndex),
            RoadmapLine(
              segment: updatedSegment,
            ),
            ...data.lines.sublist(lineIndex + 1),
          ],
        );
      }
    } else {
      // change the segment to a quadratic curve
    }
  }

  void splitSegment(Segment segment) {
    // split the segment into two segments
  }

  void removeSegment(Segment segment) {
    // remove the segment
  }

  void addPoint(Point<double> point) {
    data = data.copyWith(
      points: [
        ...data.points,
        RoadmapPoint(
          point: point,
        )
      ],
    );
    if (data.points.length > 1) {
      data = data.copyWith(
        lines: [
          ...data.lines,
          RoadmapLine(
            segment: Segment(
              quadraticPoint: Point(
                (data.points[data.points.length - 2].point.x +
                        data.points.last.point.x) /
                    2,
                (data.points[data.points.length - 2].point.y +
                        data.points.last.point.y) /
                    2,
              ),
              segmentEndPoint: data.points.last.point,
            ),
          ),
        ],
      );
    }
  }

  void removePoint(RoadmapPoint point) {}
}
