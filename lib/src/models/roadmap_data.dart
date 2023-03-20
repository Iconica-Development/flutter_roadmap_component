// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_line.dart';
import 'package:flutter_roadmap/src/models/roadmap_point.dart';

@immutable
class RoadmapData {
  const RoadmapData({
    required this.points,
    required this.lines,
    this.selectedPoint,
    this.selectedLine,
    this.selectedSegment,
  });
  final List<RoadmapPoint> points;
  final List<RoadmapLine> lines;
  final int? selectedLine;
  final int? selectedSegment;
  final int? selectedPoint;

  RoadmapData copyWith({
    List<RoadmapPoint>? points,
    List<RoadmapLine>? lines,
    int? selectedLine,
    int? selectedSegment,
    int? selectedPoint,
    bool clearSelection = false,
  }) {
    return RoadmapData(
      points: points ?? this.points,
      lines: lines ?? this.lines,
      selectedLine: selectedLine == null && clearSelection
          ? null
          : selectedLine ?? this.selectedLine,
      selectedSegment: selectedSegment == null && clearSelection
          ? null
          : selectedSegment ?? this.selectedSegment,
      selectedPoint: selectedPoint == null && clearSelection
          ? null
          : selectedPoint ?? this.selectedPoint,
    );
  }
}
