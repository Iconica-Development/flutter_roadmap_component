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
    super.key,
  });
  final RoadmapTheme theme;
  final RoadmapEditorController? controller;

  @override
  State<RoadmapEditor> createState() => _RoadmapEditorState();
}

class _RoadmapEditorState extends State<RoadmapEditor> {
  late RoadmapEditorController _controller;
  int? _selectedLine;
  // int? _selectedSegment;
  Offset? localPosition;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RoadmapEditorController();
  }

  @override
  Widget build(BuildContext context) {
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
                                details.localPosition.dx / constraints.maxWidth,
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
            // check if there is a point at the location of the downclick
            _controller.data = _controller.data.copyWith(
              points: [
                ..._controller.data.points,
                RoadmapPoint(
                  point: Point(
                    details.localPosition.dx / context.size!.width,
                    details.localPosition.dy / context.size!.height,
                  ),
                )
              ],
            );
            // create a line between the last two points
            if (_controller.data.points.length > 1) {
              _controller.data = _controller.data.copyWith(
                lines: [
                  ..._controller.data.lines,
                  RoadmapLine(
                    segment: Segment(
                      quadracticPoint: Point(
                        (_controller
                                    .data
                                    .points[_controller.data.points.length - 2]
                                    .point
                                    .x +
                                _controller.data.points.last.point.x) /
                            2,
                        (_controller
                                    .data
                                    .points[_controller.data.points.length - 2]
                                    .point
                                    .y +
                                _controller.data.points.last.point.y) /
                            2,
                      ),
                      segmentEndPoint: _controller.data.points.last.point,
                    ),
                  ),
                ],
              );
            }
            setState(() {});
            localPosition = null;
          },
          key: ValueKey(_controller.data.points.length),
          data: _controller.data,
          theme: widget.theme,
          widgetBuilder: (point, context) {
            // TODO(freek): create a menu for editing a point
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
        if (_selectedLine != null) ...[
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

class RoadmapEditorController extends ChangeNotifier {
  RoadmapEditorController({
    RoadmapData? data,
  }) : _data = data ?? const RoadmapData(lines: [], points: []);
  RoadmapData _data;

  RoadmapData get data => _data;

  set data(RoadmapData data) {
    _data = data;
    notifyListeners();
  }
}
