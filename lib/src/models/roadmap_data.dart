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
  });
  final List<RoadmapPoint> points;
  final List<RoadmapLine> lines;

  RoadmapData copyWith({
    List<RoadmapPoint>? points,
    List<RoadmapLine>? lines,
  }) {
    return RoadmapData(
      points: points ?? this.points,
      lines: lines ?? this.lines,
    );
  }
}
