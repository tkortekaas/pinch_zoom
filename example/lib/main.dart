import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PinchZoom demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PinchZoom Page'),
      ),
      body: Column(
        children: [
          PinchZoom(
            maxScale: 2.5,
            onZoomStart: () {
              print('Start zooming cat');
            },
            onZoomEnd: () {
              print('Stop zooming cat');
            },
            child: Image.network('https://placekitten.com/640/360'),
          ),
          PinchZoom(
            maxScale: 2.5,
            onZoomStart: () {
              print('Start zooming dog');
            },
            onZoomEnd: () {
              print('Stop zooming dog');
            },
            child: Image.network('https://placedog.net/640/360'),
          ),
        ],
      ),
    );
  }
}
