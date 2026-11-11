///////////////////////////////////////////////////////////////////////////////////////////////////
/// PROGRESS STATE
///////////////////////////////////////////////////////////////////////////////////////////////////
class ProgressState {
  const ProgressState({required this.unlockedLevel, required this.bestTimes});

  final int unlockedLevel;

  /// Best finishing time per level number, in seconds.
  final Map<int, int> bestTimes;

  bool isUnlocked(int level) => level <= unlockedLevel;

  Duration? bestTime(int level) =>
      bestTimes[level] == null ? null : Duration(seconds: bestTimes[level]!);
}
