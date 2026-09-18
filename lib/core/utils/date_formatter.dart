import 'package:intl/intl.dart';

class DateFormatter {
  static String formatNoteDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Less than 60 seconds
    if (difference.inSeconds < 60 && difference.inSeconds >= 0) {
      return 'Just now';
    }

    final isToday = now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == dateTime.year &&
        yesterday.month == dateTime.month &&
        yesterday.day == dateTime.day;

    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (isToday) {
      return 'Today, $timeStr';
    } else if (isYesterday) {
      return 'Yesterday, $timeStr';
    } else if (now.year == dateTime.year) {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, y, h:mm a').format(dateTime);
    }
  }
}
