import 'package:intl/intl.dart';

extension MapExt on Map<String, dynamic> {
  Map<String, dynamic> removeNullValues() {
    return Map<String, dynamic>.from(this)
      ..removeWhere((key, value) => value == null || value == '');
  }
}

extension TimeExt on DateTime {
  String get toTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}:${millisecond.toString().padLeft(3, '0')}';
  }

  /// e.g today,2pm or tomorrow,2pm or  Jan 1, 2022, 2pm
  String get  toFriendlyFormat {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target = DateTime(year, month, day);

    final time = DateFormat('h:mm a').format(this).toLowerCase();

    if (target == today) {
      return 'Today, $time';
    }

    if (target == tomorrow) {
      return 'Tomorrow, $time';
    }

    if (year == now.year) {
      return '${DateFormat('MMM d').format(this)}, $time';
    }

    return '${DateFormat('MMM d, yyyy').format(this)}, $time';
  }
  /// minus 5 minutes from current time
  DateTime get setReminder {
    final sh = this;
    return sh.subtract(const Duration(minutes: 5));
  }
}

extension StringExt on String{
  String get capitalize {
    return length > 0
        ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
        : '';

  }
}
