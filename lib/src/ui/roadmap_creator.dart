import 'package:flutter/material.dart';
import 'package:flutter_roadmap/flutter_roadmap.dart';

class RoadmapEditor extends StatefulWidget {
  const RoadmapEditor({
    this.points = const [],
    this.lines = const [],
    this.theme = const RoadmapTheme(),
    this.controller = const RoadmapEditorController(),
    super.key,
  });

  final List<RoadmapPoint> points;
  final List<RoadmapLine> lines;
  final RoadmapTheme theme;
  final RoadmapEditorController controller;

  @override
  State<RoadmapEditor> createState() => _RoadmapEditorState();
}

class _RoadmapEditorState extends State<RoadmapEditor> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RoadmapEditorController {
  const RoadmapEditorController();
}
