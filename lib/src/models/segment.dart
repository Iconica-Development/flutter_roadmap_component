// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class Segment {
  const Segment({
    this.quadraticPoint,
    this.cubicPointOne,
    this.cubicPointTwo,
    this.segmentEndPoint,
    this.text,
    this.showArrow,
  }) : assert(
          !(quadraticPoint != null &&
              (cubicPointOne != null && cubicPointTwo != null)),
          'Cannot have both quadracticPoint and cubicPointOne or cubicPointTwo',
        );

  /// Creates a segment from json data that is camelCase
  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
        text: json['text'] as String?,
        showArrow: json['showArrow'] as bool?,
        quadraticPoint: json['quadracticPoint'] == null
            ? null
            : Point(
                (json['quadracticPoint'] as Map<String, dynamic>)['x']
                    as double,
                (json['quadracticPoint'] as Map<String, dynamic>)['y']
                    as double,
              ),
        cubicPointOne: json['cubicPointOne'] == null
            ? null
            : Point(
                (json['cubicPointOne'] as Map<String, dynamic>)['x'] as double,
                (json['cubicPointOne'] as Map<String, dynamic>)['y'] as double,
              ),
        cubicPointTwo: json['cubicPointTwo'] == null
            ? null
            : Point(
                (json['cubicPointTwo'] as Map<String, dynamic>)['x'] as double,
                (json['cubicPointTwo'] as Map<String, dynamic>)['y'] as double,
              ),
        segmentEndPoint: json['segmentEndPoint'] == null
            ? null
            : Point(
                (json['segmentEndPoint'] as Map<String, dynamic>)['x']
                    as double,
                (json['segmentEndPoint'] as Map<String, dynamic>)['y']
                    as double,
              ),
      );

  /// Quadratic bezier curve point
  final Point<double>? quadraticPoint;

  /// First Cubic bezier curve point
  final Point<double>? cubicPointOne;

  /// Second Cubic bezier curve point
  final Point<double>? cubicPointTwo;

  /// Point at the end of the segment, use this when adding
  /// multiple segments in a line
  final Point<double>? segmentEndPoint;

  /// Text displayed along the segment
  final String? text;

  /// Whether to show an arrow at the end of the segment
  final bool? showArrow;

  /// Returns a json representation of the segment
  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'showArrow': showArrow,
        'quadraticPoint': quadraticPoint == null
            ? null
            : <String, dynamic>{
                'x': quadraticPoint!.x,
                'y': quadraticPoint!.y,
              },
        'cubicPointOne': cubicPointOne == null
            ? null
            : <String, dynamic>{
                'x': cubicPointOne!.x,
                'y': cubicPointOne!.y,
              },
        'cubicPointTwo': cubicPointTwo == null
            ? null
            : <String, dynamic>{
                'x': cubicPointTwo!.x,
                'y': cubicPointTwo!.y,
              },
        'segmentEndPoint': segmentEndPoint == null
            ? null
            : <String, dynamic>{
                'x': segmentEndPoint!.x,
                'y': segmentEndPoint!.y,
              },
      };

  Segment copyWith({
    Point<double>? quadraticPoint,
    Point<double>? cubicPointOne,
    Point<double>? cubicPointTwo,
    Point<double>? segmentEndPoint,
    String? text,
    bool? showArrow,
    bool removeQuadratic = false,
    bool removeCubic = false,
  }) =>
      Segment(
        quadraticPoint:
            removeQuadratic ? null : quadraticPoint ?? this.quadraticPoint,
        cubicPointOne: removeCubic ? null : cubicPointOne ?? this.cubicPointOne,
        cubicPointTwo: removeCubic ? null : cubicPointTwo ?? this.cubicPointTwo,
        segmentEndPoint: segmentEndPoint ?? this.segmentEndPoint,
        text: text ?? this.text,
        showArrow: showArrow ?? this.showArrow,
      );
}
