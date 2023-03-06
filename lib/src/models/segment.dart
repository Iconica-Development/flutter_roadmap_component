// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class Segment {
  const Segment({
    this.quadracticPoint,
    this.cubicPointOne,
    this.cubicPointTwo,
    this.text,
    this.showArrow,
  }) : assert(
          (quadracticPoint != null &&
                  cubicPointOne == null &&
                  cubicPointTwo == null) ||
              (quadracticPoint == null &&
                  cubicPointOne != null &&
                  cubicPointTwo != null),
          'Must have either quadracticPoint or cubicPointOne and cubicPointTwo',
        );

  /// Quadratic bezier curve point
  final Point<double>? quadracticPoint;

  /// First Cubic bezier curve point
  final Point<double>? cubicPointOne;

  /// Second Cubic bezier curve point
  final Point<double>? cubicPointTwo;

  /// Text displayed along the segment
  final String? text;

  /// Whether to show an arrow at the end of the segment
  final bool? showArrow;
}
