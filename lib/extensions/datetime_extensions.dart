import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  // Méthodes statiques pour éviter les recalculs répétés
  static final DateTime _now = DateTime.now();
  static final DateTime _today = DateTime(_now.year, _now.month, _now.day);
  static final DateTime _yesterday = _today.subtract(const Duration(days: 1));
  
  // Utilise les formatters natifs de Dart pour de meilleures performances
  static final DateFormat _timeFormatter = DateFormat.Hm();
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _shortDateFormatter = DateFormat('dd/MM');
  static final DateFormat _sortableDateFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat _weekdayFormatter = DateFormat.EEEE('fr_FR');
  static final DateFormat _monthFormatter = DateFormat.MMMM('fr_FR');
  static final DateFormat _fullDateFormatter = DateFormat('dd MMMM yyyy', 'fr_FR');

  String get timeAgo {
    final difference = DateTime.now().difference(this);
    final absDifference = difference.abs();

    if (absDifference.inSeconds < 60) {
      return 'à l\'instant';
    } else if (absDifference.inMinutes < 60) {
      return '${absDifference.inMinutes}min';
    } else if (absDifference.inHours < 24) {
      return '${absDifference.inHours}h';
    } else if (absDifference.inDays < 7) {
      return '${absDifference.inDays}j';
    } else if (absDifference.inDays < 30) {
      return '${(absDifference.inDays / 7).floor()}sem';
    } else if (absDifference.inDays < 365) {
      return '${(absDifference.inDays / 30).floor()}mois';
    } else {
      return '${(absDifference.inDays / 365).floor()}ans';
    }
  }

  // Utilise les formatters natifs pour de meilleures performances et localisation
  String get formattedTime => _timeFormatter.format(this);
  String get formattedDate => _dateFormatter.format(this);
  String get formattedDateTime => _dateTimeFormatter.format(this);
  String get shortFormattedDate => _shortDateFormatter.format(this);
  String get sortableDate => _sortableDateFormatter.format(this);
  String get fullFormattedDate => _fullDateFormatter.format(this);

  // Optimisation avec DateTime.utc pour comparaisons plus précises
  bool get isToday {
    final today = DateTime.now();
    return isSameDay(today);
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
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
