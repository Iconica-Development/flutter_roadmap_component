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

  RoadmapLine get selectedLine => data.lines[data.selectedLine!];

  Segment get selectedSegment => selectedLine.segments[data.selectedSegment!];

  RoadmapData get data => _data;

  set data(RoadmapData data) {
    _data = data;
    notifyListeners();
  }

  void changeSegmentCurveType(
    Segment segment,
    int lineIndex,
    int segmentIndex,
  ) {
    var previousPoint = (segmentIndex != 0)
        ? data.lines[lineIndex].segments[segmentIndex - 1].segmentEndPoint!
        : data.points[lineIndex].point;
    Segment updatedSegment;

    if (segment.quadraticPoint != null) {
      // change the segment to a cubic curve
      updatedSegment = segment.copyWith(
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
    } else {
      // change the segment to a quadratic curve
      updatedSegment = segment.copyWith(
        removeCubic: true,
        quadraticPoint: Point(
          (previousPoint.x + segment.segmentEndPoint!.x) / 2,
          (previousPoint.y + segment.segmentEndPoint!.y) / 2,
        ),
      );
    }
    data = data.copyWith(
      lines: [
        ...data.lines.sublist(0, lineIndex),
        data.lines[lineIndex].copyWith(
          segments: [
            ...data.lines[lineIndex].segments.sublist(0, segmentIndex),
            updatedSegment,
            ...data.lines[lineIndex].segments.sublist(segmentIndex + 1),
          ],
        ),
        ...data.lines.sublist(lineIndex + 1),
      ],
    );
  }

  void splitSegment(Segment segment, int lineIndex, int segmentIndex) {
    var previousPoint = (segmentIndex != 0)
        ? data.lines[lineIndex].segments[segmentIndex - 1].segmentEndPoint!
        : data.points[lineIndex].point;
    var currentPoint =
        data.lines[lineIndex].segments[segmentIndex].segmentEndPoint;
    var splitPoint = Point(
      (previousPoint.x + currentPoint!.x) / 2,
      (previousPoint.y + currentPoint.y) / 2,
    );
    var firstSegmentSplit = Point(
      (previousPoint.x + splitPoint.x) / 2,
      (previousPoint.y + splitPoint.y) / 2,
    );
    var secondSegmentSplit = Point(
      (splitPoint.x + currentPoint.x) / 2,
      (splitPoint.y + currentPoint.y) / 2,
    );
    var firstSegment = segment.copyWith(
      quadraticPoint: firstSegmentSplit,
      removeCubic: true,
      segmentEndPoint: splitPoint,
    );
    var secondSegment = segment.copyWith(
      quadraticPoint: secondSegmentSplit,
      removeCubic: true,
      segmentEndPoint: currentPoint,
    );
    data = data.copyWith(
      lines: [
        ...data.lines.sublist(0, lineIndex),
        data.lines[lineIndex].copyWith(
          segments: [
            ...data.lines[lineIndex].segments.sublist(0, segmentIndex),
            firstSegment,
            secondSegment,
            ...data.lines[lineIndex].segments.sublist(segmentIndex + 1),
          ],
        ),
        ...data.lines.sublist(lineIndex + 1),
      ],
    );
  }

  void removeSegment(Segment segment, int lineIndex, int segmentIndex) {
    if (segmentIndex == 0 && data.lines[lineIndex].segments.length == 1) {
      // remove the line
      data = data.copyWith(
        lines: [
          ...data.lines.sublist(0, lineIndex),
          RoadmapLine(
            segments: [
              segment.copyWith(removeQuadratic: true, removeCubic: true),
            ],
          ),
          ...data.lines.sublist(lineIndex + 1),
        ],
      );
    } else if (segmentIndex == 0) {
      // remove the first segment
      data = data.copyWith(
        lines: [
          ...data.lines.sublist(0, lineIndex),
          data.lines[lineIndex].copyWith(
            segments: [
              ...data.lines[lineIndex].segments.sublist(1),
            ],
          ),
          ...data.lines.sublist(lineIndex + 1),
        ],
      );
    } else if (segmentIndex == data.lines[lineIndex].segments.length - 1) {
      // remove the last segment
      data = data.copyWith(
        lines: [
          ...data.lines.sublist(0, lineIndex),
          data.lines[lineIndex].copyWith(
            segments: [
              ...data.lines[lineIndex].segments.sublist(segmentIndex),
            ],
          ),
          ...data.lines.sublist(lineIndex + 1),
        ],
      );
    } else {
      // remove a middle segment
      data = data.copyWith(
        lines: [
          ...data.lines.sublist(0, lineIndex),
          data.lines[lineIndex].copyWith(
            segments: [
              ...data.lines[lineIndex].segments.sublist(0, segmentIndex),
              ...data.lines[lineIndex].segments.sublist(segmentIndex + 1),
            ],
          ),
          ...data.lines.sublist(lineIndex + 1),
        ],
      );
    }
    // remove the line selection
    data = data.copyWith(clearSelection: true);
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
            segments: [
              Segment(
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
            ],
          ),
        ],
      );
    }
  }

  void removePoint(RoadmapPoint point) {}
}
