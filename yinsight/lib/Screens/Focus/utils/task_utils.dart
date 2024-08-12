class TaskUtils {
  
  /// Extracts the task ID from the given string.
  ///
  /// [taskIdString]: The string containing the task ID.
  ///
  /// Returns the extracted task ID.
  static String extractTaskId(String taskIdString) {
    if (taskIdString.startsWith('[#') && taskIdString.endsWith(']')) {
      return taskIdString.substring(2, taskIdString.length - 1);
    } else {
      throw Exception('Malformed task ID string: $taskIdString');
    }
  }

  /// Formats the time string to hours and minutes.
  ///
  /// [time]: The time string to format.
  ///
  /// Returns the formatted time string.
  static String formatTimeToHoursAndMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return "";
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return "${hours}h ${minutes}m";
  }

  /// Parses a duration string to a [Duration] object.
  ///
  /// [input]: The duration string to parse.
  ///
  /// Returns the parsed [Duration] object.
  static Duration parseDuration(String input) {
    final parts = input.split(':');
    if (parts.length != 2) {
      return Duration.zero;
    }
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  /// Formats a [Duration] object to a string.
  ///
  /// [duration]: The duration to format.
  ///
  /// Returns the formatted duration string.
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
