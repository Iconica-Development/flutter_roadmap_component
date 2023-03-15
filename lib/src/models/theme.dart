// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/marker.dart';

@immutable
class RoadmapTheme {
  const RoadmapTheme({
    this.lineColor,
    this.markerColor,
    this.markerTextColor,
    this.segmentTextColor,
    this.overlayColor,
    this.lineWidth = 20.0,
    this.dashLength = 10.0,
    this.dashSpace = 10.0,
    this.markerRadius = 40.0,
    this.markerShape = MarkerShape.circle,
  });

  /// Creates a roadmap theme from json data that is camelCase
  /// Colors are stored as ints in json, so they need to be converted
  factory RoadmapTheme.fromJson(Map<String, dynamic> json) => RoadmapTheme(
        lineColor:
            json['lineColor'] == null ? null : Color(json['lineColor'] as int),
        markerColor: json['markerColor'] == null
            ? null
            : Color(json['markerColor'] as int),
        markerTextColor: json['markerTextColor'] == null
            ? null
            : Color(json['markerTextColor'] as int),
        segmentTextColor: json['segmentTextColor'] == null
            ? null
            : Color(json['segmentTextColor'] as int),
        overlayColor: json['overlayColor'] == null
            ? null
            : Color(json['overlayColor'] as int),
      );

  final Color? lineColor;
  final Color? markerColor;
  final Color? markerTextColor;
  final Color? segmentTextColor;
  final Color? overlayColor;
  final double markerRadius;
  final double lineWidth;
  final MarkerShape markerShape;

  final double dashLength;
  final double dashSpace;

  RoadmapTheme copyWith({
    Color? lineColor,
    Color? markerColor,
    Color? markerTextColor,
    Color? segmentTextColor,
    Color? overlayColor,
    double? markerRadius,
    double? lineWidth,
    MarkerShape? markerShape,
    double? dashLength,
    double? dashSpace,
  }) {
    return RoadmapTheme(
      lineColor: lineColor ?? this.lineColor,
      markerColor: markerColor ?? this.markerColor,
      markerTextColor: markerTextColor ?? this.markerTextColor,
      segmentTextColor: segmentTextColor ?? this.segmentTextColor,
      overlayColor: overlayColor ?? this.overlayColor,
      markerRadius: markerRadius ?? this.markerRadius,
      lineWidth: lineWidth ?? this.lineWidth,
      markerShape: markerShape ?? this.markerShape,
      dashLength: dashLength ?? this.dashLength,
      dashSpace: dashSpace ?? this.dashSpace,
    );
  }
}
