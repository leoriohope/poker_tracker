// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '德州扑克记录';

  @override
  String get analytics => '统计分析';

  @override
  String get noRecords => '还没有记录，点击右下角添加';

  @override
  String totalSessions(int count) {
    return '总场次：$count';
  }

  @override
  String get totalProfit => '总盈亏';

  @override
  String totalDuration(String hours) {
    return '总时长：$hours小时';
  }

  @override
  String get profitPerHour => '每小时盈亏';

  @override
  String get monthlyStats => '月度统计';

  @override
  String get clickForDetails => '点击查看详情';

  @override
  String get profitTrend => '盈亏趋势';

  @override
  String get locationStats => '场地统计';

  @override
  String get date => '日期';

  @override
  String get location => '场地';

  @override
  String get profit => '盈亏';

  @override
  String get duration => '时长';

  @override
  String get minutes => '分钟';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get loadError => '加载失败';

  @override
  String get editSession => '编辑记录';

  @override
  String get buyIn => '买入金额';

  @override
  String get cashOut => '结束金额';

  @override
  String get notes => '备注';

  @override
  String get save => '保存';

  @override
  String get updateSuccess => '更新成功';

  @override
  String get updateError => '更新失败';

  @override
  String get enterLocation => '请输入地点';

  @override
  String get enterValidNumber => '请输入有效的数字';

  @override
  String get enterDuration => '请输入时长';

  @override
  String get enterValidInteger => '请输入有效的整数';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteMessage => '确定要删除这条记录吗？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get deleteError => '删除失败';

  @override
  String get dayOfMonth => '日';

  @override
  String get sessionList => '详细记录';
}
