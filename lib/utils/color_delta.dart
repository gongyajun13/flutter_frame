import 'dart:math' as math;

/// CIE 色彩差异计算工具（CIEDE2000 / ΔE00）
class ColorDelta {
  ColorDelta._();

  static List<double> rgbToLab(int r, int g, int b) {
    double fn(num c) {
      final s = c / 255.0;
      return (s > 0.04045
              ? math.pow((s + 0.055) / 1.055, 2.4)
              : s / 12.92)
          .toDouble();
    }

    final rL = fn(r);
    final gL = fn(g);
    final bL = fn(b);

    final x = rL * 0.4124 + gL * 0.3576 + bL * 0.1805;
    final y = rL * 0.2126 + gL * 0.7152 + bL * 0.0722;
    final z = rL * 0.0193 + gL * 0.1192 + bL * 0.9505;

    double f(num t) => (t > 0.008856
            ? math.pow(t, 1 / 3)
            : t * 7.787 + 16 / 116)
        .toDouble();

    final fx = f(x / 0.95047);
    final fy = f(y / 1.00000);
    final fz = f(z / 1.08883);

    return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
  }

  static double deltaE76SqFromLab(List<double> lab1, List<double> lab2) {
    final dL = lab1[0] - lab2[0];
    final dA = lab1[1] - lab2[1];
    final dB = lab1[2] - lab2[2];
    return dL * dL + dA * dA + dB * dB;
  }

  static double deltaE00FromLab(List<double> lab1, List<double> lab2) {
    const kL = 1.0;
    const kC = 1.0;
    const kH = 1.0;

    final l1 = lab1[0];
    final a1 = lab1[1];
    final b1 = lab1[2];
    final l2 = lab2[0];
    final a2 = lab2[1];
    final b2 = lab2[2];

    final avgLp = (l1 + l2) / 2.0;

    final c1 = math.sqrt(a1 * a1 + b1 * b1);
    final c2 = math.sqrt(a2 * a2 + b2 * b2);
    final avgC = (c1 + c2) / 2.0;

    final g =
        0.5 * (1 - math.sqrt(math.pow(avgC, 7) / (math.pow(avgC, 7) + math.pow(25, 7))));
    final a1p = (1 + g) * a1;
    final a2p = (1 + g) * a2;

    final c1p = math.sqrt(a1p * a1p + b1 * b1);
    final c2p = math.sqrt(a2p * a2p + b2 * b2);
    final avgCp = (c1p + c2p) / 2.0;

    double hp1 = math.atan2(b1, a1p) * 180 / math.pi;
    if (hp1 < 0) hp1 += 360;
    double hp2 = math.atan2(b2, a2p) * 180 / math.pi;
    if (hp2 < 0) hp2 += 360;

    double avgHp;
    if ((c1p * c2p).abs() < 1e-10) {
      avgHp = hp1 + hp2;
    } else if ((hp1 - hp2).abs() <= 180) {
      avgHp = (hp1 + hp2) / 2;
    } else if (hp1 + hp2 < 360) {
      avgHp = (hp1 + hp2 + 360) / 2;
    } else {
      avgHp = (hp1 + hp2 - 360) / 2;
    }

    final t = 1 -
        0.17 * math.cos((avgHp - 30) * math.pi / 180) +
        0.24 * math.cos((2 * avgHp) * math.pi / 180) +
        0.32 * math.cos((3 * avgHp + 6) * math.pi / 180) -
        0.20 * math.cos((4 * avgHp - 63) * math.pi / 180);

    double deltaHpAngle;
    if ((c1p * c2p).abs() < 1e-10) {
      deltaHpAngle = 0;
    } else if ((hp2 - hp1).abs() <= 180) {
      deltaHpAngle = hp2 - hp1;
    } else if (hp2 <= hp1) {
      deltaHpAngle = hp2 - hp1 + 360;
    } else {
      deltaHpAngle = hp2 - hp1 - 360;
    }

    final dLp = l2 - l1;
    final dCp = c2p - c1p;
    final dHp = 2 * math.sqrt(c1p * c2p) * math.sin(deltaHpAngle * math.pi / 180 / 2);

    final sl = 1 + 0.015 * math.pow(avgLp - 50, 2) / math.sqrt(20 + math.pow(avgLp - 50, 2));
    final sc = 1 + 0.045 * avgCp;
    final sh = 1 + 0.015 * avgCp * t;

    final deltaTheta = 30 * math.exp(-math.pow((avgHp - 275) / 25, 2));
    final rc = 2 * math.sqrt(math.pow(avgCp, 7) / (math.pow(avgCp, 7) + math.pow(25, 7)));
    final rt = -rc * math.sin(2 * deltaTheta * math.pi / 180);

    final dL = dLp / (kL * sl);
    final dC = dCp / (kC * sc);
    final dH = dHp / (kH * sh);

    return math.sqrt(dL * dL + dC * dC + dH * dH + rt * dC * dH);
  }

  static double deltaE00(int r1, int g1, int b1, int r2, int g2, int b2) {
    return deltaE00FromLab(rgbToLab(r1, g1, b1), rgbToLab(r2, g2, b2));
  }

  /// ΔE00 between two color codes via precomputed Lab cache.
  static double deltaE00BetweenCodes(
    String codeA,
    String codeB,
    Map<String, List<double>> labCache,
  ) {
    final labA = labCache[codeA];
    final labB = labCache[codeB];
    if (labA == null || labB == null) return double.infinity;
    return deltaE00FromLab(labA, labB);
  }
}
