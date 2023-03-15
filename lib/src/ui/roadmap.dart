// SPDX-FileCopyrightText: 2023 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/src/models/roadmap_line.dart';
import 'package:flutter_roadmap/src/models/roadmap_point.dart';
import 'package:flutter_roadmap/src/models/theme.dart';
import 'package:flutter_roadmap/src/ui/widgets/roadmap_painter.dart';

class RoadmapComponent extends StatefulWidget {
  const RoadmapComponent({
    required this.points,
    this.lines = const [],
    this.theme = const RoadmapTheme(),
    this.overlays = const [],
    this.widgetBuilder,
    super.key,
  });

  final List<RoadmapPoint> points;
  final List<RoadmapLine> lines;
  final RoadmapTheme theme;
  final List<Widget> overlays;

  // widgetbuilder which gets the index of the point and returns a widget
  final Widget Function(int index, BuildContext context)? widgetBuilder;

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
            InkWell(
              hoverColor: Colors.transparent,
              onTapDown: handleTapDown,
              onTapUp: (details) => handleTapUp(details, constraints),
              child: SizedBox.expand(
                child: CustomPaint(
                  painter: RoadmapPainter(
                    points: widget.points,
                    lines: widget.lines,
                    theme: widget.theme,
                    context: context,
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
      for (var i = 0; i < widget.points.length; i++) {
        var point = widget.points[i].point;
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
      setState(() {
        _selectedStep = (selectedPoint != -1) ? selectedPoint : null;
      });
    }
  }

  void handleTapDown(
    TapDownDetails details,
  ) {
    debugPrint('tap down');
  }
}
