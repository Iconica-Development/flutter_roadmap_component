// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/segment.dart';

@immutable
class RoadmapLine {
  const RoadmapLine({
    this.segments,
    this.segment,
  })  : assert(
          segments != null || segment != null,
          'Must have either segments or segment',
        ),
        assert(
          segments == null || segment == null,
          'Cannot have both segments and segment',
        );

  /// Creates a roadmap line from json data that is camelCase
  /// json can be a list of segments or a single segment
  factory RoadmapLine.fromJson(dynamic json) => RoadmapLine(
        segments: json is List<dynamic>
            ? json
                .map(
                  (dynamic segment) =>
                      Segment.fromJson(segment as Map<String, dynamic>),
                )
                .toList()
            : null,
        segment: json is Map<String, dynamic> ? Segment.fromJson(json) : null,
      );

  /// List of segments between two points, used for making complex lines
  final List<Segment>? segments;

  /// Single segment between two points, used for making simple lines
  final Segment? segment;

  RoadmapLine copyWith({
    List<Segment>? segments,
    Segment? segment,
  }) {
    return RoadmapLine(
      segments: segments ?? this.segments,
      segment: segment ?? this.segment,
    );
  }
}
