import 'dart:async';

import 'package:flutter/material.dart';

class PinchZoom extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final bool zoomEnabled;
  final Function? onZoomStart, onZoomEnd;

  /// Create a PinchZoom.
  ///
  /// * [child] is the widget used for zooming.
  /// This parameter must not be null.
  ///
  /// * [maxScale] is the maximum allowed scale.
  /// Defaults to 3.0.
  /// Cannot be null, and must be greater than zero.
  ///
  /// * [zoomEnabled] can be used to enable/disable zooming.
  ///
  /// * [onZoomStart] called when the widget goes to its zoomed state.
  ///
  /// * [onZoomEnd] called when the widget is back to its idle state.

  const PinchZoom(
      {super.key,
      required this.child,
      // This default maxScale value is eyeballed as reasonable limit for common
      // use cases.
      this.maxScale = 3.0,
      this.zoomEnabled = true,
      this.onZoomStart,
      this.onZoomEnd});

  @override
  State<PinchZoom> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  OverlayEntry? _overlayEntry;
  final _widgetKey = GlobalKey();
  Timer? _endScrollTimer;
  bool? _endHandled;
  final Matrix4 _identity = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      key: _widgetKey,
      scaleEnabled: widget.zoomEnabled,
      panEnabled: widget.zoomEnabled,
      maxScale: widget.maxScale,
      onInteractionStart: (details) {
        _endHandled = null;
        if (details.pointerCount == 0) {
          _endHandled = false;
          _transformationController.value = _identity;
        } else {
          _endScrollTimer?.cancel();
        }
      },
      onInteractionUpdate: (details) {
        if (details.pointerCount == 0) {
          _endHandled = false;
          _transformationController.value = _identity;
        } else {
          _endScrollTimer?.cancel();
        }
      },
      onInteractionEnd: (details) {
        if (details.pointerCount == 0) {
          _endHandled = false;
          _transformationController.value = _identity;
        } else {
          _endScrollTimer = Timer(const Duration(milliseconds: 100), () {
            _endHandled = false;
            _transformationController.value = _identity;
          });
        }
      },
      transformationController: _transformationController,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(
      () {
        bool isIdentity = _transformationController.value.isIdentity();
        OverlayEntry? entry = _overlayEntry;

        if (_endHandled == true) {
          _transformationController.value = _identity;
        } else if (_endHandled == false) {
          _endHandled = true;
          if (widget.onZoomEnd != null) {
            widget.onZoomEnd!();
          }
          if (entry != null) {
            entry.remove();
            _overlayEntry = null;
          }
        } else if (!isIdentity && entry == null) {
          RenderBox? box =
              _widgetKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;
          Offset position = box.localToGlobal(Offset.zero);
          entry = OverlayEntry(
            builder: (context) => ValueListenableBuilder(
              valueListenable: _transformationController,
              builder: (BuildContext context, Matrix4 value, Widget? child) {
                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  width: box.size.width,
                  height: box.size.height,
                  child: IgnorePointer(
                    child: Transform(
                      transform: value,
                      child: widget.child,
                    ),
                  ),
                );
              },
            ),
          );
          _overlayEntry = entry;
          Overlay.of(context).insert(entry);
          if (widget.onZoomStart != null) {
            widget.onZoomStart!();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _overlayEntry?.dispose();
    _endScrollTimer?.cancel();
    super.dispose();
  }
}
