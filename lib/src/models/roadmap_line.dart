// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/segment.dart';

@immutable
class RoadmapLine {
  const RoadmapLine({
    required this.segments,
  });

  /// Creates a roadmap line from json data that is camelCase
  /// json can be a list of segments or a single segment
  factory RoadmapLine.fromJson(List<dynamic> json) => RoadmapLine(
        segments: json
            .map(
              (dynamic segment) =>
                  Segment.fromJson(segment as Map<String, dynamic>),
            )
            .toList(),
      );

  /// List of segments between two points, used for making complex lines
  final List<Segment> segments;

  /// Returns a json representation of the roadmap line
  Map<String, dynamic> toJson() => <String, dynamic>{
        'segments': segments.map((segment) => segment.toJson()).toList(),
      };

  RoadmapLine copyWith({
    List<Segment>? segments,
  }) {
    return RoadmapLine(
      segments: segments ?? this.segments,
    );
  }
}
