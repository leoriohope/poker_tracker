// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Poker Tracker';

  @override
  String get analytics => 'Analytics';

  @override
  String get noRecords => 'No records yet, click the button below to add';

  @override
  String totalSessions(int count) {
    return 'Total Sessions: $count';
  }

  @override
  String get totalProfit => 'Total Profit';

  @override
  String totalDuration(String hours) {
    return 'Total Duration: $hours hours';
  }

  @override
  String get profitPerHour => 'Profit per Hour';

  @override
  String get monthlyStats => 'Monthly Statistics';

  @override
  String get clickForDetails => 'Click for details';

  @override
  String get profitTrend => 'Profit Trend';

  @override
  String get locationStats => 'Location Statistics';

  @override
  String get date => 'Date';

  @override
  String get location => 'Location';

  @override
  String get profit => 'Profit';

  @override
  String get duration => 'Duration';

  @override
  String get minutes => 'minutes';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get loadError => 'Load failed';

  @override
  String get editSession => 'Edit Session';

  @override
  String get buyIn => 'Buy In';

  @override
  String get cashOut => 'Cash Out';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get updateSuccess => 'Update successful';

  @override
  String get updateError => 'Update failed';

  @override
  String get enterLocation => 'Please enter location';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get enterDuration => 'Please enter duration';

  @override
  String get enterValidInteger => 'Please enter a valid integer';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage => 'Are you sure you want to delete this record?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteError => 'Delete failed';

  @override
  String get dayOfMonth => 'th';

  @override
  String get sessionList => 'Session List';
}
