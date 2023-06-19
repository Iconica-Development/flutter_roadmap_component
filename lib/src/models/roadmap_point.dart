// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/marker.dart';

@immutable
class RoadmapPoint {
  const RoadmapPoint({
    required this.point,
    this.text,
    this.overlay,
    this.widgetBuilder,
    this.markerShape,
  });

  /// Creates a roadmap point from json data that is camelCase
  factory RoadmapPoint.fromJson(Map<String, dynamic> json) => RoadmapPoint(
        point: Point(
          json['x'] as double,
          json['y'] as double,
        ),
        text: json['text'] as String?,
        markerShape: (json['markerShape'] == null)
            ? null
            : MarkerShape.values.firstWhereOrNull(
                (element) => element.name == json['markerShape'],
              ),
      );

  /// The point on the roadmap with value between 0 and 1
  final Point<double> point;

  /// Label displayed at the point on the roadmap instead of the default counter
  final String? text;

  /// Widget displayed instead of the default marker
  final Widget? overlay;

  /// Markershape of the point
  final MarkerShape? markerShape;

  /// Widget builder for the point
  final Widget Function(BuildContext context)? widgetBuilder;

  /// Returns a json representation of the roadmap point
  Map<String, dynamic> toJson() => <String, dynamic>{
        'x': point.x,
        'y': point.y,
        'text': text,
        'markerShape': markerShape?.name,
      };

  RoadmapPoint copyWith({
    Point<double>? point,
    String? text,
    Widget? overlay,
    MarkerShape? markerShape,
    Widget Function(BuildContext context)? widgetBuilder,
  }) =>
      RoadmapPoint(
        point: point ?? this.point,
        text: text ?? this.text,
        overlay: overlay ?? this.overlay,
        markerShape: markerShape ?? this.markerShape,
        widgetBuilder: widgetBuilder ?? this.widgetBuilder,
      );
}
