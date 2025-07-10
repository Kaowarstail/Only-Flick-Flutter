extension DateTimeExtensions on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mois';
    } else {
      return '${(difference.inDays / 365).floor()}ans';
    }
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  String get shortFormattedDate {
    return '$day/${month.toString().padLeft(2, '0')}';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  String get conversationDisplayTime {
    if (isToday) {
      return formattedTime;
    } else if (isYesterday) {
      return 'Hier';
    } else if (isThisWeek) {
      return _getWeekdayName();
    } else if (isThisYear) {
      return shortFormattedDate;
    } else {
      return formattedDate;
    }
  }

  String get messageDisplayTime {
    if (isToday) {
      return formattedTime;
    } else if (isYesterday) {
      return 'Hier $formattedTime';
    } else if (isThisWeek) {
      return '${_getWeekdayName()} $formattedTime';
    } else {
      return formattedDateTime;
    }
  }

  String _getWeekdayName() {
    switch (weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  String get monthName {
    switch (month) {
      case 1:
        return 'Janvier';
      case 2:
        return 'Février';
      case 3:
        return 'Mars';
      case 4:
        return 'Avril';
      case 5:
        return 'Mai';
      case 6:
        return 'Juin';
      case 7:
        return 'Juillet';
      case 8:
        return 'Août';
      case 9:
        return 'Septembre';
      case 10:
        return 'Octobre';
      case 11:
        return 'Novembre';
      case 12:
        return 'Décembre';
      default:
        return '';
    }
  }

  String get fullFormattedDate {
    return '$day $monthName $year';
  }

  // Pour les groupes de messages dans le chat
  String get messageDateSeparator {
    if (isToday) {
      return 'Aujourd\'hui';
    } else if (isYesterday) {
      return 'Hier';
    } else if (isThisWeek) {
      return _getWeekdayName();
    } else if (isThisYear) {
      return '$day $monthName';
    } else {
      return fullFormattedDate;
    }
  }

  // Pour trier les messages par date
  String get sortableDate {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  // Vérifier si deux dates sont le même jour
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Début de la journée (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  // Fin de la journée (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}
