import 'package:flutter/material.dart';

class AnimatedSlider extends StatefulWidget {
  AnimatedSlider({
    super.key,
    this.value = 0.0,
    this.barColor = Colors.white,
    this.rightFillColor = const Color.fromARGB(255, 86, 21, 198),
    this.leftFillColor = Colors.white12,
    this.height = 50.0,
    this.barWidth = 6.0,
    this.onChange,
    this.labelStyle = const TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.w800,
    ),
    BorderRadius? cornerRadius,
  })  : _cornerRadius = cornerRadius ?? BorderRadius.circular(8.0),
        assert(value >= 0 && value <= 1.0);

  /// Initial progress value.
  final double value;

  final Color barColor;

  final Color rightFillColor;

  final Color leftFillColor;

  final double height;

  final double barWidth;

  final BorderRadius _cornerRadius;

  final TextStyle labelStyle;

  final void Function(double value)? onChange;

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

const _animationDuration = Duration(milliseconds: 100);
const _barHorizontalMargins = 6.0;

class _AnimatedSliderState extends State<AnimatedSlider> {
  late final _dragBarWidth = widget.barWidth + (_barHorizontalMargins * 2);
  late final _dragRegion = Size(_dragBarWidth + 20, widget.height);

  late final _progressNotifier = ValueNotifier<double>(widget.value);
  late final _overlappingNotifier = ValueNotifier<bool>(false);

  TextStyle get _labelStyle {
    return widget.labelStyle.copyWith(
      color: widget.labelStyle.color?.withOpacity(_overlappingNotifier.value ? 1 : 0.7),
    );
  }

  void _onTextSizeChange(Size size, double leftBoxWidth, double rightBoxWidth) {
    if (leftBoxWidth < (size.width + 16) || rightBoxWidth < (size.width + 16)) {
      _overlappingNotifier.value = true;
    } else {
      _overlappingNotifier.value = false;
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails dragDetails, double sliderWidth) {
    double position = (dragDetails.globalPosition.dx - _dragBarWidth) / sliderWidth;
    _progressNotifier.value = position.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double sliderWidth = constraints.maxWidth;
          double sliderHeight = constraints.maxHeight;
          double sliderWidthWithOutBar = sliderWidth - _dragBarWidth;

          return ValueListenableBuilder(
            valueListenable: _progressNotifier,
            builder: (context, progress, _) {
              double leftBoxWidth = sliderWidthWithOutBar * progress;
              double rightBoxWidth = sliderWidthWithOutBar - leftBoxWidth;
              int progressInPercentage = (progress * 100).toInt();

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      /// Left Box
                      AnimatedContainer(
                        width: leftBoxWidth,
                        height: sliderHeight,
                        duration: _animationDuration,
                        decoration: BoxDecoration(
                          color: widget.leftFillColor,
                          borderRadius: widget._cornerRadius,
                        ),
                      ),

                      /// Bar
                      _SliderBar(
                        color: widget.barColor,
                        width: widget.barWidth,
                        cornerRadius: widget._cornerRadius,
                      ),

                      /// Right Box
                      AnimatedContainer(
                        width: rightBoxWidth,
                        height: sliderHeight,
                        duration: _animationDuration,
                        decoration: BoxDecoration(
                          color: widget.rightFillColor,
                          borderRadius: widget._cornerRadius,
                        ),
                      ),
                    ],
                  ),

                  /// Progress Labels
                  ValueListenableBuilder(
                    valueListenable: _overlappingNotifier,
                    builder: (context, isOverflowing, child) {
                      return AnimatedPositioned.fromRect(
                        duration: _animationDuration,
                        rect: Rect.fromCenter(
                          width: sliderWidth,
                          height: sliderHeight,
                          center: Offset(
                            sliderWidth / 2,
                            sliderHeight / (isOverflowing ? -2 : 2),
                          ),
                        ),
                        child: child!,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Left Progress Text
                          ComputedText(
                            '$progressInPercentage%',
                            style: _labelStyle,
                            onSizeChange: (size) => _onTextSizeChange(size, leftBoxWidth, rightBoxWidth),
                          ),

                          /// Right Progress Text
                          ComputedText(
                            '${100 - progressInPercentage}%',
                            style: _labelStyle,
                            onSizeChange: (size) {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Drag Paddler with extra drag region.
                  Positioned.fromRect(
                    rect: Rect.fromCenter(
                      width: _dragRegion.width,
                      height: _dragRegion.height,
                      center: Offset(leftBoxWidth + _dragBarWidth / 2, sliderHeight / 2),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (dragDetails) => _onHorizontalDragUpdate(dragDetails, sliderWidth),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SliderBar extends StatelessWidget {
  const _SliderBar({
    required this.width,
    required this.color,
    required this.cornerRadius,
  });

  final double width;
  final Color color;
  final BorderRadiusGeometry cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: cornerRadius,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: _barHorizontalMargins,
      ),
    );
  }
}

class ComputedText extends StatefulWidget {
  const ComputedText(
    this.text, {
    super.key,
    required this.style,
    required this.onSizeChange,
  });

  final String text;
  final TextStyle style;
  final void Function(Size) onSizeChange;

  @override
  State<ComputedText> createState() => _ComputedTextState();
}

class _ComputedTextState extends State<ComputedText> {
  Size calculateSize() {
    return (TextPainter(
            text: TextSpan(text: widget.text, style: widget.style),
            maxLines: 1,
            textScaler: TextScaler.noScaling,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSizeChange(calculateSize());
    });
  }

  @override
  void didUpdateWidget(covariant ComputedText oldWidget) {
    if (oldWidget.text != widget.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSizeChange(calculateSize());
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: widget.style,
    );
  }
}
