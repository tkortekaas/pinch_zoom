import 'package:flutter/material.dart';

class PinchZoom extends StatefulWidget {
  final Widget image;
  final Color zoomedBackgroundColor;
  final double maxScale;
  final Duration resetDuration;
  final bool zoomEnabled;
  final Function onZoomStart, onZoomEnd;

  /// Create an PinchZoom.
  ///
  /// * [image] is the widget used for zooming.
  /// This parameter must not be null.
  ///
  /// * [maxScale] is the maximum allowed scale.
  /// Defaults to 3.0.
  /// Cannot be null, and must be greater than zero.
  ///
  /// * [resetDuration] is the length of time this animation should last.
  ///
  /// * [zoomedBackgroundColor] is background color during the animation.
  ///
  /// * [zoomEnabled] can be used to enable/disable zooming.
  ///
  /// * [onZoomStart] called when the widget goes to its zoomed state.
  ///
  /// * [onZoomEnd] called when the widget is back to its idle state.

  PinchZoom({
    @required this.image,
    this.zoomedBackgroundColor = Colors.black,
    this.resetDuration = const Duration(milliseconds: 100),
    // This default maxScale value is eyeballed as reasonable limit for common
    // use cases.
    this.maxScale = 3.0,
    this.zoomEnabled = true,
    this.onZoomStart,
    this.onZoomEnd
  });

  @override
  _PinchZoomState createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
  TransformationController();

  Animation<Matrix4> _animationReset;
  AnimationController _controllerReset;
  OverlayEntry _overlayEntry;
  bool zooming = false,
  // Is true when the zoomed in widget is still showing
      _opened = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (zooming && !_opened) {
          Future.delayed(Duration.zero, () => _show(constraints));
        } else if (!zooming && _opened) {
          _hide();
        }
        return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: InteractiveViewer(
            child: widget.image,
            scaleEnabled: widget.zoomEnabled,
            panEnabled: false,
            onInteractionStart: widget.zoomEnabled ? _onInteractionStart : null,
            onInteractionEnd: _onInteractionEnd,
            transformationController: _transformationController,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
      duration: widget.resetDuration,
    );
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    _hide();
    super.dispose();
  }

  // Go back to static state after resetting has ended
  void _onAnimateReset() {
    _transformationController.value = _animationReset.value;
    if (!_controllerReset.isAnimating) {
      _animationReset?.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
      setState(() {
        zooming = false;
      });
    }
  }

  // Start resetting the animation
  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  // Stop the reset animation
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  // Start zooming in
  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    } else {
      setState(() {
        zooming = true;
      });
    }
  }

  // Start reset animation after zooming stopped
  void _onInteractionEnd(ScaleEndDetails details) {
    _animateResetInitialize();
  }

  // Create the Overlay for the zoomed in widget
  OverlayEntry _buildOverlayEntry(BoxConstraints constraints) {
    RenderBox renderBox = context.findRenderObject();
    final offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) {
        return ColoredBox(
          color: widget.zoomedBackgroundColor,
          child: Container(
            margin: EdgeInsets.only(left: offset.dx, top: offset.dy),
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: InteractiveViewer(
              child: widget.image,
              scaleEnabled: true,
              panEnabled: false,
              maxScale: widget.maxScale,
              onInteractionStart: _onInteractionStart,
              onInteractionEnd: _onInteractionEnd,
              transformationController: _transformationController,
            ),
          ),
        );
      },
    );
  }

  // Show the zoomed in widget
  void _show(BoxConstraints constraints) async {
    _overlayEntry = _buildOverlayEntry(constraints);
    Overlay.of(context).insert(_overlayEntry);
    _opened = true;
    widget.onZoomStart();
  }

  // Remove the zoomed in widget
  void _hide() {
    if (_opened) {
      _overlayEntry.remove();
      _opened = false;
      widget.onZoomEnd();
    }
  }
}
