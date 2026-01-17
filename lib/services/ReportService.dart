import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/User_service.dart';
import 'package:glucotrack_app/services/NotificationService.dart';

class GlucoseReport {
  final String id;
  final String userId;
  final String reportType; // 'daily', 'weekly', 'monthly'
  final DateTime periodStart;
  final DateTime periodEnd;
  final double? averageGlucose;
  final double? minGlucose;
  final double? maxGlucose;
  final int recordCount;
  final String status; // 'low', 'normal', 'high', 'critical'
  final DateTime createdAt;

  GlucoseReport({
    required this.id,
    required this.userId,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    this.averageGlucose,
    this.minGlucose,
    this.maxGlucose,
    required this.recordCount,
    required this.status,
    required this.createdAt,
  });

  factory GlucoseReport.fromJson(Map<String, dynamic> json) {
    return GlucoseReport(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportType: json['report_type'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      averageGlucose: (json['average_glucose'] as num?)?.toDouble(),
      minGlucose: (json['min_glucose'] as num?)?.toDouble(),
      maxGlucose: (json['max_glucose'] as num?)?.toDouble(),
      recordCount: json['record_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get reportTypeLabel {
    switch (reportType) {
      case 'daily':
        return 'Daily Report';
      case 'weekly':
        return 'Weekly Report';
      case 'monthly':
        return 'Monthly Report';
      default:
        return 'Report';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'low':
        return 'Low';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return 'Normal';
    }
  }
}

class ReportService {
  final _supabase = Supabase.instance.client;
  final _glucoseRepository = Glucoserepository();
  final _userService = UserService();

  // Singleton
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  /// Auto-generate all pending reports (called on app start)
  Future<void> autoGenerateReports() async {
    final userId = _userService.currentUserId;
    if (userId == null) return;

    try {
      // Check and generate daily report
      await _checkAndGenerateDailyReport(userId);
      
      // Check and generate weekly report (every Sunday or Monday)
      await _checkAndGenerateWeeklyReport(userId);
      
      // Check and generate monthly report (1st of each month)
      await _checkAndGenerateMonthlyReport(userId);
    } catch (e) {
      print('Error auto-generating reports: $e');
    }
  }

  Future<void> _checkAndGenerateDailyReport(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if daily report for yesterday exists
    final yesterday = today.subtract(const Duration(days: 1));
    final existingReport = await _getReportForPeriod(
      userId, 
      'daily', 
      yesterday,
      today,
    );

    if (existingReport == null) {
      // Generate daily report for yesterday
      await generateDailyReport(userId, yesterday);
    }
  }

  Future<void> _checkAndGenerateWeeklyReport(String userId) async {
    final now = DateTime.now();
    // Only generate on Monday (weekday == 1)
    if (now.weekday != DateTime.monday) return;

    final today = DateTime(now.year, now.month, now.day);
    final lastWeekStart = today.subtract(const Duration(days: 7));
    
    final existingReport = await _getReportForPeriod(
      userId,
      'weekly',
      lastWeekStart,
      today,
    );

    if (existingReport == null) {
      await generateWeeklyReport(userId, lastWeekStart);
    }
  }

  Future<void> _checkAndGenerateMonthlyReport(String userId) async {
    final now = DateTime.now();
    // Only generate on 1st of month
    if (now.day != 1) return;

    final today = DateTime(now.year, now.month, now.day);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1);
    
    final existingReport = await _getReportForPeriod(
      userId,
      'monthly',
      lastMonthStart,
      lastMonthEnd,
    );

    if (existingReport == null) {
      await generateMonthlyReport(userId, lastMonthStart);
    }
  }

  Future<GlucoseReport?> _getReportForPeriod(
    String userId,
    String type,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Use exact matching for period_start and period_end
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      
      final result = await _supabase
          .from('glucose_reports')
          .select()
          .eq('user_id', userId)
          .eq('report_type', type)
          .eq('period_start', startStr)
          .eq('period_end', endStr)
          .maybeSingle();

      if (result != null) {
        print('Found existing $type report for period $start - $end');
        return GlucoseReport.fromJson(result);
      }
    } catch (e) {
      print('Error checking existing report: $e');
    }
    return null;
  }

  /// Generate daily report for a specific date
  Future<GlucoseReport?> generateDailyReport(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    
    return await _generateReport(userId, 'daily', start, end);
  }

  /// Generate weekly report starting from a specific date
  Future<GlucoseReport?> generateWeeklyReport(String userId, DateTime startDate) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = start.add(const Duration(days: 7));
    
    return await _generateReport(userId, 'weekly', start, end);
  }

  /// Generate monthly report for a specific month
  Future<GlucoseReport?> generateMonthlyReport(String userId, DateTime monthStart) async {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final end = DateTime(monthStart.year, monthStart.month + 1, 1);
    
    return await _generateReport(userId, 'monthly', start, end);
  }

  Future<GlucoseReport?> _generateReport(
    String userId,
    String type,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Fetch glucose records for the period
      final records = await _glucoseRepository.getGlucoseRecordsByDateRange(
        userId,
        start,
        end,
      );

      if (records.isEmpty) {
        print('No records found for $type report from $start to $end');
        return null;
      }

      // Calculate statistics
      double sum = 0;
      double min = double.infinity;
      double max = double.negativeInfinity;

      for (final record in records) {
        sum += record.glucoseLevel;
        if (record.glucoseLevel < min) min = record.glucoseLevel;
        if (record.glucoseLevel > max) max = record.glucoseLevel;
      }

      final average = sum / records.length;
      final status = _determineStatus(average);

      // Insert report
      final result = await _supabase.from('glucose_reports').insert({
        'user_id': userId,
        'report_type': type,
        'period_start': start.toIso8601String(),
        'period_end': end.toIso8601String(),
        'average_glucose': average,
        'min_glucose': min,
        'max_glucose': max,
        'record_count': records.length,
        'status': status,
      }).select().single();

      final report = GlucoseReport.fromJson(result);

      // Send notification
      await _sendReportNotification(report);

      return report;
    } catch (e) {
      print('Error generating $type report: $e');
      return null;
    }
  }

  String _determineStatus(double average) {
    if (average < 70) return 'low';
    if (average > 180) return 'critical';
    if (average > 140) return 'high';
    return 'normal';
  }

  Future<void> _sendReportNotification(GlucoseReport report) async {
    try {
      final title = '${report.reportTypeLabel} Ready!';
      final body = 'Your ${report.reportType} glucose report is ready. '
          'Average: ${report.averageGlucose?.toStringAsFixed(0) ?? "-"} mg/dL';
      
      await NotificationService().showLocalNotification(
        title: title,
        body: body,
      );
    } catch (e) {
      print('Error sending report notification: $e');
    }
  }

  /// Get all reports for user by type
  Future<List<GlucoseReport>> getReports({String? type, int limit = 50}) async {
    final userId = _userService.currentUserId;
    if (userId == null) return [];

    try {
      var query = _supabase
          .from('glucose_reports')
          .select()
          .eq('user_id', userId);

      if (type != null) {
        query = query.eq('report_type', type);
      }

      final result = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (result as List)
          .map((json) => GlucoseReport.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  /// Get latest report by type
  Future<GlucoseReport?> getLatestReport(String type) async {
    final userId = _userService.currentUserId;
    if (userId == null) return null;

    try {
      final result = await _supabase
          .from('glucose_reports')
          .select()
          .eq('user_id', userId)
          .eq('report_type', type)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (result != null) {
        return GlucoseReport.fromJson(result);
      }
    } catch (e) {
      print('Error fetching latest $type report: $e');
    }
    return null;
  }

  /// Force generate reports for testing (generates for current periods, skips if already exists)
  Future<void> forceGenerateAllReports() async {
    final userId = _userService.currentUserId;
    if (userId == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate daily for today (if not exists)
    final dailyEnd = today.add(const Duration(days: 1));
    final existingDaily = await _getReportForPeriod(userId, 'daily', today, dailyEnd);
    if (existingDaily == null) {
      await generateDailyReport(userId, today);
    } else {
      print('Daily report for $today already exists, skipping');
    }

    // Generate weekly for last 7 days (if not exists)
    final weekStart = today.subtract(const Duration(days: 7));
    final existingWeekly = await _getReportForPeriod(userId, 'weekly', weekStart, today);
    if (existingWeekly == null) {
      await generateWeeklyReport(userId, weekStart);
    } else {
      print('Weekly report for $weekStart-$today already exists, skipping');
    }

    // Generate monthly for current month (if not exists)
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    final existingMonthly = await _getReportForPeriod(userId, 'monthly', monthStart, monthEnd);
    if (existingMonthly == null) {
      await generateMonthlyReport(userId, monthStart);
    } else {
      print('Monthly report for $monthStart already exists, skipping');
    }
  }
}
