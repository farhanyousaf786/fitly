import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }
  
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
  
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays == -1) {
      return 'Tomorrow';
    } else if (difference.inDays > 1 && difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return formatDate(date);
    }
  }
  
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
  
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
  
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
  
  static DateTime endOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }
  
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
  
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  static bool isYesterday(DateTime date) {
    return isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));
  }
  
  static bool isTomorrow(DateTime date) {
    return isSameDay(date, DateTime.now().add(const Duration(days: 1)));
  }
  
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
  
  static List<DateTime> getDaysInMonth(DateTime month) {
    final start = startOfMonth(month);
    final end = endOfMonth(month);
    final days = <DateTime>[];
    
    for (int i = 0; i <= daysBetween(start, end); i++) {
      days.add(start.add(Duration(days: i)));
    }
    
    return days;
  }
}
