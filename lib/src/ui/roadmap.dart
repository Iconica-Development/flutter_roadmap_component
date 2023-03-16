// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_data.dart';
import 'package:flutter_roadmap/src/models/theme.dart';
import 'package:flutter_roadmap/src/ui/widgets/roadmap_painter.dart';

class RoadmapComponent extends StatefulWidget {
  const RoadmapComponent({
    required this.data,
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

  final RoadmapData data;
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
  int? _selectedStep;

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
                      data: widget.data,
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
            if (_selectedStep != null && widget.widgetBuilder != null) ...[
              // show a grey overlay
              InkWell(
                onTapUp: (details) => handleTapUp(details, constraints),
                onTapDown: handleTapDown,
                hoverColor: Colors.transparent,
                child: Container(
                  color:
                      widget.theme.overlayColor ?? Colors.grey.withOpacity(0.7),
                ),
              ),
              Center(child: widget.widgetBuilder!(_selectedStep!, context)),
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
    if (_selectedStep != null) {
      setState(() {
        _selectedStep = null;
      });
    } else {
      // determine which point was tapped
      var selectedPoint = -1;
      // check if any of the points where tapped within a certain radius
      for (var i = 0; i < widget.data.points.length; i++) {
        var point = widget.data.points[i].point;
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
          data: widget.data,
          size: constraints.biggest,
          position: details.localPosition,
          onSegmentHit: (lineIndex, segmentIndex) {
            widget.onSegmentHit?.call(lineIndex, segmentIndex);
          },
        )) {
          widget.onTapUp?.call(details);
        }
      } else {
        setState(() {
          _selectedStep = selectedPoint;
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
