# pinch_zoom

A widget based on Flutter's Interactive Viewer that makes picture pinch zoom, and return to its initial size and position when released.

This package offers Instagram based pinch zooming that feels more responsive than other similar packages.

The package is designed for zooming in on images; however, it can also be used to zoom in on a video.

![Example one](https://jelter.net/pinch_zoom_example_1.png)
![Example two](https://jelter.net/pinch_zoom_example_2.png)

## Installation

Add this to your `pubspec.yaml` dependencies:

```
pinch_zoom: ^2.0.1
```

## How to use

Add the widget to your app like this (It automatically takes the size of the image you pass to it):

```dart
PinchZoom(
    child: Image.network('https://placecats.com/640/360'),
    maxScale: 2.5,
    onZoomStart: (){print('Start zooming');},
    onZoomEnd: (){print('Stop zooming');},
),
```