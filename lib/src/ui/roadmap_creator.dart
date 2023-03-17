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
    super.key,
  });
  final RoadmapTheme theme;
  final RoadmapEditorController? controller;

  /// widgetbuilder which gets the index of the point and returns a widget
  final Widget Function(int pointIndex, BuildContext context)? pointEditBuilder;

  /// widgetbuilder which gets the index of the point and returns a widget
  final Widget Function(int lineIndex, int segmentIndex, BuildContext context)?
      lineEditBuilder;

  @override
  State<RoadmapEditor> createState() => _RoadmapEditorState();
}

class _RoadmapEditorState extends State<RoadmapEditor> {
  late RoadmapEditorController _controller;
  int? _selectedLine;
  int? _selectedSegment;
  Offset? localPosition;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RoadmapEditorController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            RoadmapComponent(
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
                    // update the point in the list, create a copy of the list
                    // and replace the point in the list with the updated point
                    _controller.data = _controller.data.copyWith(
                      points: List<RoadmapPoint>.from(
                        _controller.data.points.map(
                          (e) => e == dragstartPoint
                              ? e.copyWith(
                                  point: Point(
                                    details.localPosition.dx /
                                        constraints.maxWidth,
                                    details.localPosition.dy /
                                        constraints.maxHeight,
                                  ),
                                )
                              : e,
                        ),
                      ),
                    );
                  }
                }
                localPosition = details.localPosition;
                setState(() {});
              },

              onTapUp: (details) {
                if (_selectedLine != null || _selectedSegment != null) {
                  setState(() {
                    _selectedLine = null;
                    _selectedSegment = null;
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
                debugPrint('hit line $lineIndex segment $segmentIndex');
                setState(() {
                  _selectedLine = lineIndex;
                  _selectedSegment = segmentIndex;
                });
              },
              key: ValueKey(_controller.data.points.length),
              data: _controller.data,
              theme: widget.theme,
              widgetBuilder: (point, context) {
                widget.pointEditBuilder?.call(point, context);
                // default widget builder
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                );
              },
              // add onTap to the roadmap component to detect clicks on lines
            ),
            // Add toplayer with
            // draw circles at the point of the line
            if (_selectedLine != null && _selectedSegment != null) ...[
              widget.lineEditBuilder?.call(
                    _selectedLine!,
                    _selectedSegment!,
                    context,
                  ) ??
                  Container(),
              ...drawSegmentLinePoints(
                constraints,
                _controller
                    .data.lines[_selectedLine!].segments[_selectedSegment!],
              ),
            ],
          ],
        );
      },
    );
  }

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
            onVerticalDragUpdate: (details) {
              var currentPoint = getSegmentProperty(segment, key);
              setState(() {
                _controller.data = _controller.data.copyWith(
                  lines: _controller.data.lines
                      .map(
                        (line) => line == _controller.data.lines[_selectedLine!]
                            ? line.copyWith(
                                segments: [
                                  ...line.segments
                                      .sublist(0, _selectedSegment!),
                                  setSegmentProperty(
                                    segment,
                                    key,
                                    Point(
                                      currentPoint.x +
                                          details.delta.dx /
                                              constraints.maxWidth,
                                      currentPoint.y +
                                          details.delta.dy /
                                              constraints.maxHeight,
                                    ),
                                  ),
                                  ...line.segments
                                      .sublist(_selectedSegment! + 1),
                                ],
                              )
                            : line,
                      )
                      .toList(),
                );
              });
            },
            onHorizontalDragUpdate: (details) {
              var currentPoint = getSegmentProperty(segment, key);
              setState(() {
                _controller.data = _controller.data.copyWith(
                  lines: _controller.data.lines
                      .map(
                        (line) => line == _controller.data.lines[_selectedLine!]
                            ? line.copyWith(
                                segments: [
                                  ...line.segments
                                      .sublist(0, _selectedSegment!),
                                  setSegmentProperty(
                                    segment,
                                    key,
                                    Point(
                                      currentPoint.x +
                                          details.delta.dx /
                                              constraints.maxWidth,
                                      currentPoint.y +
                                          details.delta.dy /
                                              constraints.maxHeight,
                                    ),
                                  ),
                                  ...line.segments
                                      .sublist(_selectedSegment! + 1),
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
