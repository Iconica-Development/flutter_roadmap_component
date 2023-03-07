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
