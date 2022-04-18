import 'package:flutter/material.dart';

const _arrowWidth = 7.0; // 箭头宽度
const _arrowHeight = 10.0; // 箭头高度
const _minHeight = 32.0; // 内容最小高度
const _minWidth = 50.0; // 内容最小宽度

class Bubble extends StatelessWidget {
  final BubbleDirection direction; // 箭头方向
  final Widget child;
  final Color color;

  const Bubble(
      {Key? key,
      this.direction = BubbleDirection.left,
      required this.child,
      this.color = Colors.blueAccent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BubbleClipper(direction, const Radius.circular(4.0)),
      child: Container(
        constraints: (const BoxConstraints())
            .copyWith(minHeight: _minHeight, minWidth: _minWidth),
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
        color: color,
        child: child,
      ),
    );
  }
}

// 方向
enum BubbleDirection { left, right }

class _BubbleClipper extends CustomClipper<Path> {
  final BubbleDirection direction;
  final Radius radius;
  _BubbleClipper(this.direction, this.radius);

  @override // 获取裁剪
  Path getClip(Size size) {
    final path = Path();
    final path2 = Path();
    final centerPoint = (size.height / 2).clamp(_minHeight / 2, _minHeight / 2);

    if (direction == BubbleDirection.left) {
      //绘制三角形
      path.moveTo(0, centerPoint);
      path.lineTo(_arrowWidth, centerPoint - _arrowHeight / 2);
      path.lineTo(_arrowWidth, centerPoint + _arrowHeight / 2);
      path.close();
      //绘制矩形
      path2.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
              _arrowWidth, 0, (size.width - _arrowWidth), size.height),
          radius));
      //合并
      path.addPath(path2, const Offset(0, 0));
    } else {
      path.moveTo(size.width, centerPoint);
      path.lineTo(size.width - _arrowWidth, centerPoint - _arrowHeight / 2);
      path.lineTo(size.width - _arrowWidth, centerPoint + _arrowHeight / 2);
      path.close();

      path2.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, (size.width - _arrowWidth), size.height),
          radius));

      path.addPath(path2, const Offset(0, 0));
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // 不重新裁剪
  }
}
