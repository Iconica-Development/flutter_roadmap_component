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
    this.selectedLine,
    this.selectedSegment,
  });
  final List<RoadmapPoint> points;
  final List<RoadmapLine> lines;
  final int? selectedLine;
  final int? selectedSegment;

  RoadmapData copyWith({
    List<RoadmapPoint>? points,
    List<RoadmapLine>? lines,
    int? selectedLine,
    int? selectedSegment,
    bool clearSelection = false,
  }) {
    return RoadmapData(
      points: points ?? this.points,
      lines: lines ?? this.lines,
      selectedLine: clearSelection ? null : selectedLine ?? this.selectedLine,
      selectedSegment:
          clearSelection ? null : selectedSegment ?? this.selectedSegment,
    );
  }
}
