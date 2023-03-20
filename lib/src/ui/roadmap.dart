// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_controller.dart';
import 'package:flutter_roadmap/src/models/theme.dart';
import 'package:flutter_roadmap/src/ui/widgets/roadmap_painter.dart';

class RoadmapComponent extends StatefulWidget {
  const RoadmapComponent({
    required this.controller,
    this.theme = const RoadmapTheme(),
    this.overlays = const [],
    this.widgetBuilder,
    this.onTapDown,
    this.onTapUp,
    this.onDragStart,
    this.onDragUpdate,
    this.onSegmentHit,
    super.key,
  });

  final RoadmapController controller;
  final RoadmapTheme theme;
  final List<Widget> overlays;

  /// onTapDown is used to detect clicks outside of the roadmap points
  final GestureTapDownCallback? onTapDown;

  /// onTapUp is used to detect clicks outside of the roadmap points
  final GestureTapUpCallback? onTapUp;

  /// onDragStart is used to detect drags outside of the roadmap points
  final GestureDragStartCallback? onDragStart;

  /// onDragUpdate is used to detect drags outside of the roadmap points
  final void Function(DragUpdateDetails, BoxConstraints)? onDragUpdate;

  /// widgetbuilder which gets the index of the point and returns a widget
  final Widget Function(int index, BuildContext context)? widgetBuilder;

  final void Function(int lineIndex, int segmentIndex)? onSegmentHit;

  @override
  State<RoadmapComponent> createState() => _RoadmapComponentState();
}

class _RoadmapComponentState extends State<RoadmapComponent> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                widget.onDragStart?.call(details);
              },
              onHorizontalDragUpdate: (details) {
                widget.onDragUpdate?.call(details, constraints);
              },
              onHorizontalDragEnd: (details) {},
              onVerticalDragStart: (details) {
                widget.onDragStart?.call(details);
              },
              onVerticalDragUpdate: (details) {
                widget.onDragUpdate?.call(details, constraints);
              },
              onVerticalDragEnd: (details) {},
              child: InkWell(
                hoverColor: Colors.transparent,
                onTapDown: handleTapDown,
                onTapUp: (details) => handleTapUp(details, constraints),
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: RoadmapPainter(
                      controller: widget.controller,
                      theme: widget.theme,
                      context: context,
                      size: constraints.biggest,
                    ),
                  ),
                ),
              ),
            ),
            // wrap each overlay in an inkwell
            ...widget.overlays
                .asMap()
                .map(
                  (index, overlay) => MapEntry(
                    index,
                    InkWell(
                      onTapUp: (details) => handleTapUp(details, constraints),
                      onTapDown: handleTapDown,
                      hoverColor: Colors.transparent,
                      child: overlay,
                    ),
                  ),
                )
                .values,
            if (widget.controller.data.selectedPoint != null &&
                widget.widgetBuilder != null) ...[
              InkWell(
                onTapUp: (details) => handleTapUp(details, constraints),
                onTapDown: handleTapDown,
                hoverColor: Colors.transparent,
                child: Container(
                  color:
                      widget.theme.overlayColor ?? Colors.grey.withOpacity(0.7),
                ),
              ),
              Center(
                child: widget.widgetBuilder?.call(
                  widget.controller.data.selectedPoint!,
                  context,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void handleTapUp(
    TapUpDetails details,
    BoxConstraints constraints,
  ) {
    if (widget.controller.data.selectedPoint != null) {
      setState(() {
        widget.controller.data = widget.controller.data.copyWith(
          clearSelection: true,
        );
      });
    } else {
      // determine which point was tapped
      var selectedPoint = -1;
      // check if any of the points where tapped within a certain radius
      for (var i = 0; i < widget.controller.data.points.length; i++) {
        var point = widget.controller.data.points[i].point;
        var radius = widget.theme.markerRadius *
            1.5; // 1.5x the radius to account for strange shapes
        var x = point.x * constraints.maxWidth;
        var y = point.y * constraints.maxHeight;
        var dx = x - details.localPosition.dx;
        var dy = y - details.localPosition.dy;
        var distance = sqrt(dx * dx + dy * dy);
        if (distance < radius) {
          selectedPoint = i;
          break;
        }
      }
      if (selectedPoint == -1) {
        // check if any of the lines where tapped
        if (!RoadmapPainter.lineHitDetected(
          data: widget.controller.data,
          size: constraints.biggest,
          position: details.localPosition,
          onSegmentHit: (lineIndex, segmentIndex) {
            widget.onSegmentHit?.call(lineIndex, segmentIndex);
          },
        )) {
          setState(() {
            widget.controller.data = widget.controller.data.copyWith(
              clearSelection: true,
              selectedSegment: widget.controller.data.selectedSegment,
              selectedLine: widget.controller.data.selectedLine,
            );
          });
          widget.onTapUp?.call(details);
        }
      } else {
        setState(() {
          widget.controller.data = widget.controller.data.copyWith(
            selectedPoint: selectedPoint,
            clearSelection: true,
          );
        });
      }
    }
  }

  void handleTapDown(
    TapDownDetails details,
  ) {
    widget.onTapDown?.call(details);
  }
}
