/// Utility helpers for working with time and durations throughout the app.
///
/// Keeping the formatting logic in a single place avoids subtle differences
/// between screens and makes it easier to introduce locale aware formatting
/// in the future.
String formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds <= 0) {
    return '00:00';
  }

  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Convenience wrapper for formatting a value represented in seconds.
String formatSeconds(int seconds) => formatDuration(Duration(seconds: seconds));
