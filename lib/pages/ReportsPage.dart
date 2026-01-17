import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/ReportService.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:glucotrack_app/pages/ReportDetailPage.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  
  List<GlucoseReport> _dailyReports = [];
  List<GlucoseReport> _weeklyReports = [];
  List<GlucoseReport> _monthlyReports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);

    final daily = await _reportService.getReports(type: 'daily');
    final weekly = await _reportService.getReports(type: 'weekly');
    final monthly = await _reportService.getReports(type: 'monthly');

    if (mounted) {
      setState(() {
        _dailyReports = daily;
        _weeklyReports = weekly;
        _monthlyReports = monthly;
        _loading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C7796),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Reports',
          style: FontUtils.style(
            size: FontSize.lg,
            weight: FontWeightType.bold,
            color: Colors.white,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReportList(_dailyReports, 'daily'),
                _buildReportList(_weeklyReports, 'weekly'),
                _buildReportList(_monthlyReports, 'monthly'),
              ],
            ),
    );
  }

  Widget _buildReportList(List<GlucoseReport> reports, String type) {
    if (reports.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return _buildReportCard(reports[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String scheduleText;
    switch (type) {
      case 'daily':
        scheduleText = 'Daily reports are generated\nautomatically at end of each day';
        break;
      case 'weekly':
        scheduleText = 'Weekly reports are generated\nautomatically every Monday';
        break;
      case 'monthly':
        scheduleText = 'Monthly reports are generated\nautomatically on 1st of each month';
        break;
      default:
        scheduleText = 'Reports are generated automatically';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No $type reports yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scheduleText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(GlucoseReport report) {
    final dateFormat = report.reportType == 'daily'
        ? DateFormat('EEEE, d MMM yyyy')
        : report.reportType == 'weekly'
            ? DateFormat('d MMM')
            : DateFormat('MMMM yyyy');

    final periodText = report.reportType == 'weekly'
        ? '${dateFormat.format(report.periodStart)} - ${dateFormat.format(report.periodEnd.subtract(const Duration(days: 1)))}'
        : dateFormat.format(report.periodStart);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailPage(report: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(report.status),
                  color: _getStatusColor(report.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Report info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${report.recordCount} records',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(report.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Average
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    report.averageGlucose?.toStringAsFixed(0) ?? '-',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(report.status),
                    ),
                  ),
                  Text(
                    'mg/dL',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'low':
        return Colors.orange;
      case 'high':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'low':
        return Icons.arrow_downward;
      case 'high':
        return Icons.arrow_upward;
      case 'critical':
        return Icons.warning;
      default:
        return Icons.check_circle;
    }
  }
}
