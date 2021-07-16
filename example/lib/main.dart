import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PinchZoom demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PinchZoom Page'),
      ),
      body: PinchZoom(
        child: Image.network('https://placekitten.com/640/360'),
        resetDuration: const Duration(milliseconds: 100),
        maxScale: 2.5,
        onZoomStart: (){print('Start zooming');},
        onZoomEnd: (){print('Stop zooming');},
      ),
    );
  }
}
