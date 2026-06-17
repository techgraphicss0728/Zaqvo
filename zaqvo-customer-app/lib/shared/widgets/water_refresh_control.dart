import 'package:flutter/material.dart';

class WaterRefreshWrapper extends StatefulWidget {
  const WaterRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<WaterRefreshWrapper> createState() => _WaterRefreshWrapperState();
}

class _WaterRefreshWrapperState extends State<WaterRefreshWrapper> {
  static const _triggerPullDistance = 96.0;
  RefreshIndicatorStatus? _status;
  double _pullExtent = 0;

  bool get _isRefreshing => _status == RefreshIndicatorStatus.refresh;
  bool get _isVisible => _isRefreshing || _pullExtent > 0;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification.metrics.pixels > 0 && _pullExtent != 0) {
      setState(() => _pullExtent = 0);
      return false;
    }

    if (notification is OverscrollNotification &&
        notification.overscroll < 0 &&
        notification.metrics.pixels <= 0) {
      final next = (_pullExtent + (-notification.overscroll)).clamp(0.0, 140.0);
      if (next != _pullExtent) {
        setState(() => _pullExtent = next);
      }
    }

    if (notification is ScrollEndNotification && !_isRefreshing) {
      if (_pullExtent != 0) {
        setState(() => _pullExtent = 0);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final progress = (_pullExtent / _triggerPullDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        RefreshIndicator.noSpinner(
          onRefresh: widget.onRefresh,
          onStatusChange: (status) {
            setState(() {
              _status = status;
              if (status == null && !_isRefreshing) {
                _pullExtent = 0;
              }
            });
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: widget.child,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          top: safeTop + 8,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: _isVisible ? 1 : 0,
              child: Center(
                child: _WaterDropRefreshGlyph(
                  progress: progress,
                  isRefreshing: _isRefreshing,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaterDropRefreshGlyph extends StatefulWidget {
  const _WaterDropRefreshGlyph({
    required this.progress,
    required this.isRefreshing,
  });

  final double progress;
  final bool isRefreshing;

  @override
  State<_WaterDropRefreshGlyph> createState() => _WaterDropRefreshGlyphState();
}

class _WaterDropRefreshGlyphState extends State<_WaterDropRefreshGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _dropAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _WaterDropRefreshGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.isRefreshing ? 1.0 : widget.progress;
    final scale = 0.72 + (widget.progress * 0.38);
    final staticOffsetY = 22 - (widget.progress * 22);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animatedOffsetY = widget.isRefreshing ? _dropAnimation.value : 0;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, staticOffsetY + animatedOffsetY),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.95),
          border: Border.all(color: const Color(0x5536C2F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2236C2F0),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.water_drop_rounded,
          color: Color(0xFF2A88C8),
          size: 27,
        ),
      ),
    );
  }
}
