# pinch_zoom

A widget based on Flutter's new Interactive Viewer that makes picture pinch zoom, and return to its initial size and position when released.

This package offers Instagram based pinch zooming that feels more responsive than other similar packages.

This package is based on the recent Interactive Viewer that Flutter introduced since version 1.20.

This pinch zooming is used in [my app Palbum](https://palbum.app):



## Installation

Add this to your `pubspec.yaml` dependencies:

```
pinch_zoom: ^0.0.1
```

## How to use

Add the widget to your app like this (It automatically takes the size of the image you pass to it):

```dart
PinchZoom(
  image: Image.network('http://placerabbit.com/200/333'),
  zoomedBackgroundColor: Colors.black.withOpacity(0.5),
  resetDuration: const Duration(milliseconds: 100),
  maxScale: 2.5,
),
```