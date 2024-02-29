import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_roadmap/flutter_roadmap.dart';

void main() {
  runApp(const MaterialApp(home: FlutterRoadmapDemo()));
}

class RoadmapColorTheme {
  static const Color primaryColor = Color(0xFF72c7d2);
  static const Color secondaryColor = Color(0xFF01a4af);
  static const Color backgroundColor = Colors.white;
}

class FlutterRoadmapDemo extends StatefulWidget {
  const FlutterRoadmapDemo({super.key});

  @override
  State<FlutterRoadmapDemo> createState() => _FlutterRoadmapDemoState();
}

class _FlutterRoadmapDemoState extends State<FlutterRoadmapDemo> {
  bool _showCreator = false;
  final RoadmapController _controller = RoadmapController();

  final RoadmapTheme theme = const RoadmapTheme(
    lineColor: Color.fromARGB(255, 30, 8, 111),
    selectedMarkerColor: Colors.green,
    markerColor: RoadmapColorTheme.primaryColor,
    markerTextColor: Colors.white,
    markerShape: MarkerShape.hexagon,
    dashLength: 30,
    dashSpace: 15,
  );

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: RoadmapColorTheme.backgroundColor,
      body: Stack(
        children: [
          if (_showCreator) ...[
            RoadmapEditor(
              controller: _controller,
              theme: theme.copyWith(
                lineWidth: min(size.width, size.height) / 150,
              ),
              lineEditBuilder: (lineIndex, segmentIndex, context) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // button to delete the segment
                        TextButton(
                          onPressed: () {
                            _controller.removeSegment(
                              _controller
                                  .data.lines[lineIndex].segments[segmentIndex],
                              lineIndex,
                              segmentIndex,
                            );
                            setState(() {});
                          },
                          child: const Text('Remove segment'),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        // button to add a segment
                        TextButton(
                          onPressed: () {
                            _controller.splitSegment(
                              _controller
                                  .data.lines[lineIndex].segments[segmentIndex],
                              lineIndex,
                              segmentIndex,
                            );
                            setState(() {});
                          },
                          child: const Text('Split segment'),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),

                        // button to switch the segment type
                        TextButton(
                          onPressed: () {
                            _controller.changeSegmentCurveType(
                              _controller
                                  .data.lines[lineIndex].segments[segmentIndex],
                              lineIndex,
                              segmentIndex,
                            );
                            setState(() {});
                          },
                          child: const Text('Change segment type'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            RoadmapComponent(
              controller: RoadmapController(
                data: const RoadmapData(
                  points: [
                    RoadmapPoint(
                      markerShape: MarkerShape.circle,
                      point: Point(0.05, 0.6),
                    ),
                    RoadmapPoint(
                      point: Point(0.18, 0.5),
                    ),
                    RoadmapPoint(
                      point: Point(0.32, 0.45),
                    ),
                    RoadmapPoint(
                      point: Point(0.42, 0.17),
                    ),
                    RoadmapPoint(
                      point: Point(0.5, 0.65),
                    ),
                    RoadmapPoint(
                      point: Point(0.65, 0.3),
                    ),
                    RoadmapPoint(
                      point: Point(0.8, 0.4),
                    ),
                    RoadmapPoint(
                      markerShape: MarkerShape.circle,
                      point: Point(0.85, 0.7),
                    ),
                  ],
                  lines: [
                    RoadmapLine(
                      segments: [
                        Segment(
                          quadraticPoint: Point(0.1, 0.62),
                          showArrow: true,
                        ),
                      ],
                    ),
                    RoadmapLine(
                      segments: [
                        Segment(
                          cubicPointOne: Point(0.22, 0.22),
                          cubicPointTwo: Point(0.23, 0.5),
                          showArrow: true,
                          text: 'Doing good',
                        ),
                      ],
                    ),
                    RoadmapLine(
                      segments: [
                        Segment(
                          quadraticPoint: Point(0.37, 0.15),
                          showArrow: true,
                        ),
                      ],
                    ),
                    RoadmapLine(
                      segments: [
                        Segment(
                          quadraticPoint: Point(0.5, 0.17),
                          showArrow: true,
                          text: 'Going strong',
                          segmentEndPoint: Point(0.5, 0.30),
                        ),
                        Segment(
                          quadraticPoint: Point(0.42, 0.4),
                          segmentEndPoint: Point(0.42, 0.3),
                        ),
                        Segment(
                          quadraticPoint: Point(0.5, 0.65),
                          segmentEndPoint: Point(0.5, 0.65),
                        ),
                      ],
                    ),
                    RoadmapLine(
                      segments: [
                        Segment(
                          quadraticPoint: Point(0.65, 0.65),
                          showArrow: true,
                        ),
                      ],
                    ),
                    RoadmapLine(
                      segments: [
                        Segment(
                          quadraticPoint: Point(0.75, 0),
                          showArrow: true,
                          text: 'Almost there!',
                        ),
                      ],
                    ),
                    RoadmapLine(
                      segments: [
                        Segment(
                          quadraticPoint: Point(0.65, 0.9),
                          showArrow: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              theme: theme.copyWith(
                lineWidth: min(size.width, size.height) / 150,
              ),
              overlays: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: size.width * 0.05,
                      top: size.height * 0.02,
                    ),
                    child: Container(
                      width: size.width * 0.2,
                      height: size.height * 0.1,
                      decoration: const BoxDecoration(
                        color: RoadmapColorTheme.primaryColor,
                      ),
                      padding: EdgeInsets.all(size.width * 0.02),
                    ),
                  ),
                ),
              ],
              widgetBuilder: (index, context) {
                return Container(
                  width: size.width * 0.2,
                  height: size.width * 0.2,
                  decoration: const BoxDecoration(
                    color: RoadmapColorTheme.primaryColor,
                  ),
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content of ${index + 1}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          // button for switching between creator and roadmap
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                top: size.height * 0.02,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showCreator = !_showCreator;
                  });
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
