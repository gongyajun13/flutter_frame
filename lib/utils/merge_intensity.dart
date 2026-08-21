/// 合并强度三档位（基于 CIEDE2000 ΔE00 阈值）
enum MergeIntensity {
  low('细节优先', 3.0),
  medium('平衡', 6.0),
  high('精简优先', 10.0);

  final String label;
  final double mergeThreshold;

  const MergeIntensity(this.label, this.mergeThreshold);

  static const double detailProtectThreshold = 20.0;
  static const double defaultMergeThreshold = 6.0;

  static MergeIntensity fromIndex(int index) {
    if (index < 0 || index >= values.length) return medium;
    return values[index];
  }
}
