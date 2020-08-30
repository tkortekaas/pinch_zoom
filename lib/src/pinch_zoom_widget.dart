import 'package:flutter/material.dart';

class PinchZoom extends StatefulWidget {
  final Widget image;
  final Color zoomedBackgroundColor;
  final Duration resetDuration;
  final double maxScale;

  PinchZoom({
    @required this.image,
    this.zoomedBackgroundColor = Colors.black,
    this.resetDuration = const Duration(milliseconds: 100),
    this.maxScale = 3.0,
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
  bool _opened = false, zooming = false;

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
            scaleEnabled: true,
            panEnabled: false,
            onInteractionStart: _onInteractionStart,
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

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

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

  void _onInteractionEnd(ScaleEndDetails details) {
    _animateResetInitialize();
  }

  OverlayEntry _buildOverlayEntry(BoxConstraints constraints) {
    RenderBox renderBox = context.findRenderObject();
    final offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(color: widget.zoomedBackgroundColor),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Material(
                child: Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  color: widget.zoomedBackgroundColor,
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
              ),
            ),
          ],
        );
      },
    );
  }

  void _show(BoxConstraints constraints) async {
    _overlayEntry = _buildOverlayEntry(constraints);
    Overlay.of(context).insert(_overlayEntry);
    _opened = true;
  }

  void _hide() {
    if (_opened) {
      _overlayEntry.remove();
      _opened = false;
    }
  }
}
