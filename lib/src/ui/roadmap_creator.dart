// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_roadmap/flutter_roadmap.dart';

class RoadmapEditor extends StatefulWidget {
  const RoadmapEditor({
    this.theme = const RoadmapTheme(),
    this.controller,
    this.lineEditBuilder,
    this.pointEditBuilder,
    this.useDefaultPosition = true,
    super.key,
  });
  final RoadmapTheme theme;
  final RoadmapController? controller;

  /// widgetbuilder which gets the index of the point and returns a widget
  final Widget Function(int pointIndex, BuildContext context)? pointEditBuilder;

  /// widgetbuilder which gets the index of the point and returns a widget
  final Widget Function(int lineIndex, int segmentIndex, BuildContext context)?
      lineEditBuilder;

  /// pointEditBuilder and lineEditBuilder will get positioned
  /// at a specific point on the roadmap
  /// The position may get updated in future versions
  final bool useDefaultPosition;

  @override
  State<RoadmapEditor> createState() => _RoadmapEditorState();
}

class _RoadmapEditorState extends State<RoadmapEditor> {
  late RoadmapController _controller;
  Offset? localPosition;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RoadmapController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            RoadmapComponent(
              useDefaultPosition: widget.useDefaultPosition,
              onDragStart: (details) {
                localPosition = details.localPosition;
              },
              onDragUpdate: (details, constraints) {
                if (localPosition != null) {
                  var dragstartPoint = _controller.data.points.firstWhereOrNull(
                    (element) =>
                        sqrt(
                          pow(
                                element.point.x * constraints.maxWidth -
                                    localPosition!.dx,
                                2,
                              ) +
                              pow(
                                element.point.y * constraints.maxHeight -
                                    localPosition!.dy,
                                2,
                              ),
                        ) <
                        widget.theme.markerRadius * 1.5,
                  );
                  if (dragstartPoint != null) {
                    var newPoint = Point<double>(
                      (details.localPosition.dx / constraints.maxWidth)
                          .clamp(0, 1),
                      (details.localPosition.dy / constraints.maxHeight)
                          .clamp(0, 1),
                    );
                    // update the point in the list, create a copy of the list
                    // and replace the point in the list with the updated point
                    _controller.data = _controller.data.copyWith(
                      points: _controller.data.points
                          .map(
                            (e) => e == dragstartPoint
                                ? e.copyWith(point: newPoint)
                                : e,
                          )
                          .toList(),
                      lines: _controller.data.lines
                          .map(
                            (e) => e.copyWith(
                              segments: e.segments
                                  .map(
                                    (e) => (e.segmentEndPoint ==
                                            dragstartPoint.point)
                                        ? e.copyWith(
                                            segmentEndPoint: newPoint,
                                          )
                                        : e,
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    );
                  }
                }
                localPosition = details.localPosition;
                setState(() {});
              },
              onTapUp: (details) {
                if (_controller.data.selectedLine != null ||
                    _controller.data.selectedSegment != null) {
                  setState(() {
                    _controller.data = _controller.data.copyWith(
                      clearSelection: true,
                    );
                  });
                  return;
                }
                _controller.addPoint(
                  Point(
                    details.localPosition.dx / constraints.maxWidth,
                    details.localPosition.dy / constraints.maxHeight,
                  ),
                );
                // create a line between the last two points
                setState(() {});
                localPosition = null;
              },
              onSegmentHit: (lineIndex, segmentIndex) {
                setState(() {
                  _controller.data = _controller.data.copyWith(
                    selectedLine: lineIndex,
                    selectedSegment: segmentIndex,
                  );
                });
              },
              controller: _controller,
              theme: widget.theme,
              widgetBuilder: (point, context) =>
                  widget.pointEditBuilder?.call(point, context) ??
                  // default widget builder
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.red,
                  ),
            ),
            // Add toplayer with
            // draw circles at the point of the line
            if (_controller.data.selectedLine != null &&
                _controller.data.selectedSegment != null) ...[
              widget.lineEditBuilder?.call(
                    _controller.data.selectedLine!,
                    _controller.data.selectedSegment!,
                    context,
                  ) ??
                  Container(),
              ...drawSegmentLinePoints(
                constraints,
                _controller.selectedSegment,
              ),
            ],
          ],
        ),
      );

  List<Widget> drawSegmentLinePoints(
    BoxConstraints constraints,
    Segment segment,
  ) {
    var points = <String, Point>{};
    if (segment.quadraticPoint != null) {
      points['quadratic'] = segment.quadraticPoint!;
    }
    if (segment.cubicPointOne != null) {
      points['cubicOne'] = segment.cubicPointOne!;
      points['cubicTwo'] = segment.cubicPointTwo!;
    }
    // if (segment.segmentEndPoint != null) {
    //   points.add(segment.segmentEndPoint!);
    // }
    var widgets = <Widget>[];
    points.forEach(
      (key, e) => widgets.add(
        Positioned(
          top: e.y * constraints.maxHeight - widget.theme.markerRadius / 2,
          left: e.x * constraints.maxWidth - widget.theme.markerRadius / 2,
          child: GestureDetector(
            onPanUpdate: (details) {
              var currentPoint = getSegmentProperty(segment, key);
              setState(() {
                _controller.data = _controller.data.copyWith(
                  lines: _controller.data.lines
                      .map(
                        (line) => line == _controller.selectedLine
                            ? line.copyWith(
                                segments: [
                                  ...line.segments.sublist(
                                    0,
                                    _controller.data.selectedSegment,
                                  ),
                                  setSegmentProperty(
                                    segment,
                                    key,
                                    Point(
                                      (currentPoint.x +
                                              details.delta.dx /
                                                  constraints.maxWidth)
                                          .clamp(0, 1),
                                      (currentPoint.y +
                                              details.delta.dy /
                                                  constraints.maxHeight)
                                          .clamp(0, 1),
                                    ),
                                  ),
                                  ...line.segments.sublist(
                                    _controller.data.selectedSegment! + 1,
                                  ),
                                ],
                              )
                            : line,
                      )
                      .toList(),
                );
              });
            },
            child: Center(
              child: Container(
                height: widget.theme.markerRadius,
                width: widget.theme.markerRadius,
                decoration: BoxDecoration(
                  color: widget.theme.pointDragColor ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return widgets;
  }

  Segment setSegmentProperty(
    Segment segment,
    String property,
    Point<double> point,
  ) {
    switch (property) {
      case 'quadratic':
        return segment.copyWith(quadraticPoint: point);
      case 'cubicOne':
        return segment.copyWith(cubicPointOne: point);
      case 'cubicTwo':
        return segment.copyWith(cubicPointTwo: point);
      default:
        return segment;
    }
  }

  Point getSegmentProperty(Segment segment, String property) {
    switch (property) {
      case 'quadratic':
        return segment.quadraticPoint!;
      case 'cubicOne':
        return segment.cubicPointOne!;
      case 'cubicTwo':
        return segment.cubicPointTwo!;
      default:
        return const Point(0, 0);
    }
  }
}
