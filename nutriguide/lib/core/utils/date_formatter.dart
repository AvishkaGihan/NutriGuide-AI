import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats a date relative to now (e.g., "Just now", "5m ago", "2h ago")
  /// Used primarily in Chat interfaces.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Fallback to absolute date for older items
      return DateFormat('MMM d').format(date);
    }
  }

  /// Formats date for receipt/history lists (e.g., "Nov 26, 2025")
  static String formatAbsoluteDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats time only (e.g., "10:30 AM")
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Formats a chat message timestamp grouping headers
  /// e.g. "Today", "Yesterday", or "Monday, Nov 26"
  static String formatChatHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }
}
