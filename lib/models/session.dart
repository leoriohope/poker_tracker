// Session类用于表示一局扑克游戏的记录
class Session {
  final int? id;  // 可空，因为创建新记录时还没有ID
  final DateTime date;  // 游戏日期
  final double buyIn;  // 买入金额
  final double cashOut;  // 退出金额
  final String location;  // 游戏地点
  final int duration;  // 游戏时长（分钟）
  final String notes;  // 备注

  // 构造函数
  Session({
    this.id,  // ID是可选的
    required this.date,  // required表示这些参数是必需的
    required this.buyIn,
    required this.cashOut,
    required this.location,
    required this.duration,
    this.notes = '',  // 默认值为空字符串
  });

  // 计算盈亏
  double get profit => cashOut - buyIn;

  // 将对象转换为Map，用于数据库存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),  // 将DateTime转换为字符串
      'buyIn': buyIn,
      'cashOut': cashOut,
      'location': location,
      'duration': duration,
      'notes': notes,
    };
  }

  // 从Map创建Session对象，用于从数据库读取数据
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      date: DateTime.parse(map['date']),  // 将字符串解析为DateTime
      buyIn: map['buyIn'],
      cashOut: map['cashOut'],
      location: map['location'],
      duration: map['duration'],
      notes: map['notes'],
    );
  }
} 