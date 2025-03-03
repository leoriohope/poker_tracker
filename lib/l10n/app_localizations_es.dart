// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Registro de Póker';

  @override
  String get analytics => 'Análisis';

  @override
  String get noRecords => 'No hay registros aún, haga clic en el botón para agregar';

  @override
  String totalSessions(int count) {
    return 'Sesiones totales: $count';
  }

  @override
  String get totalProfit => 'Ganancia total';

  @override
  String totalDuration(String hours) {
    return 'Duración total: $hours horas';
  }

  @override
  String get profitPerHour => 'Ganancia por hora';

  @override
  String get monthlyStats => 'Estadísticas mensuales';

  @override
  String get clickForDetails => 'Clic para detalles';

  @override
  String get profitTrend => 'Tendencia de ganancias';

  @override
  String get locationStats => 'Estadísticas por ubicación';

  @override
  String get date => 'Fecha';

  @override
  String get location => 'Ubicación';

  @override
  String get profit => 'Ganancia';

  @override
  String get duration => 'Duración';

  @override
  String get minutes => 'minutos';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get loadError => 'Error al cargar';

  @override
  String get editSession => 'Editar sesión';

  @override
  String get buyIn => 'Compra';

  @override
  String get cashOut => 'Retiro';

  @override
  String get notes => 'Notas';

  @override
  String get save => 'Guardar';

  @override
  String get updateSuccess => 'Actualización exitosa';

  @override
  String get updateError => 'Error al actualizar';

  @override
  String get enterLocation => 'Ingrese la ubicación';

  @override
  String get enterValidNumber => 'Ingrese un número válido';

  @override
  String get enterDuration => 'Ingrese la duración';

  @override
  String get enterValidInteger => 'Ingrese un número entero válido';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String get confirmDeleteMessage => '¿Está seguro de que desea eliminar este registro?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteError => 'Error al eliminar';

  @override
  String get dayOfMonth => '';

  @override
  String get sessionList => 'Lista de sesiones';
}
