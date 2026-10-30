import 'package:flutter/material.dart';

import '../models/price_snapshot.dart';

class PriceHistorySparkline extends StatelessWidget {
  final List<PriceSnapshot> snapshots;
  final double height;

  const PriceHistorySparkline({
    super.key,
    required this.snapshots,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshots.length < 2) {
      return const SizedBox.shrink();
    }

    final values = snapshots
    .map(
      (snapshot) => snapshot.marketValue,
    )
    .toList();

final minValue =
    values.reduce(
  (a, b) => a < b ? a : b,
);

final maxValue =
    values.reduce(
  (a, b) => a > b ? a : b,
);

return SizedBox(
  width: double.infinity,
  height: height + 24,
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: CustomPaint(
          painter:
              _PriceHistorySparklinePainter(
            snapshots: snapshots,
          ),
        ),
      ),
      const SizedBox(
        height: 4,
      ),
      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Low \$${minValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          Text(
            'High \$${maxValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ],
  ),
);
  }
}

class _PriceHistorySparklinePainter
    extends CustomPainter {
  final List<PriceSnapshot> snapshots;

  _PriceHistorySparklinePainter({
    required this.snapshots,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (snapshots.length < 2) {
      return;
    }

    final chronological =
        snapshots.reversed.toList();

    final values = chronological
        .map(
          (snapshot) =>
              snapshot.marketValue,
        )
        .toList();

    final minValue =
        values.reduce(
      (a, b) => a < b ? a : b,
    );

    final maxValue =
        values.reduce(
      (a, b) => a > b ? a : b,
    );

    final range =
        maxValue - minValue;

    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill;

    final path = Path();

    for (var index = 0;
        index < values.length;
        index++) {
      final x =
          values.length == 1
              ? 0.0
              : (index /
                      (values.length - 1)) *
                  size.width;

      final normalized =
          range == 0
              ? 0.5
              : (values[index] -
                      minValue) /
                  range;

      final y =
          size.height -
              (normalized *
                  size.height);

      if (index == 0) {
        path.moveTo(
          x,
          y,
        );
      } else {
        path.lineTo(
          x,
          y,
        );
      }

      canvas.drawCircle(
        Offset(
          x,
          y,
        ),
        3,
        pointPaint,
      );
    }

    canvas.drawPath(
      path,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PriceHistorySparklinePainter
        oldDelegate,
  ) {
    return oldDelegate.snapshots !=
        snapshots;
  }
}