import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/ReportService.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatelessWidget {
  final GlucoseReport report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getStatusColor(report.status),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(report.status),
                      _getStatusColor(report.status).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            report.reportTypeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getPeriodText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(report.status),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${report.statusLabel}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main stat card
                  _buildMainStatCard(),
                  const SizedBox(height: 20),

                  // Statistics row
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Minimum', report.minGlucose, Icons.arrow_downward, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Maximum', report.maxGlucose, Icons.arrow_upward, Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Records', report.recordCount.toDouble(), Icons.note_alt, const Color(0xFF2C7796))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatusCard()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Report info
                  Text(
                    'Report Information',
                    style: FontUtils.style(
                      size: FontSize.md,
                      weight: FontWeightType.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(),

                  const SizedBox(height: 24),

                  // Health tips based on status
                  Text(
                    'Health Tips',
                    style: FontUtils.style(
                      size: FontSize.md,
                      weight: FontWeightType.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHealthTips(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodText() {
    final dateFormat = report.reportType == 'daily'
        ? DateFormat('EEEE, d MMMM yyyy')
        : report.reportType == 'weekly'
            ? DateFormat('d MMM')
            : DateFormat('MMMM yyyy');

    if (report.reportType == 'weekly') {
      return '${dateFormat.format(report.periodStart)} - ${dateFormat.format(report.periodEnd.subtract(const Duration(days: 1)))}';
    }
    return dateFormat.format(report.periodStart);
  }

  Widget _buildMainStatCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Average Glucose',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                report.averageGlucose?.toStringAsFixed(0) ?? '-',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(report.status),
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'mg/dL',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(report.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusMessage(),
              style: TextStyle(
                color: _getStatusColor(report.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, double? value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label == 'Records' 
                ? value?.toInt().toString() ?? '-'
                : '${value?.toStringAsFixed(0) ?? "-"} mg/dL',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(report.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(report.status),
                color: _getStatusColor(report.status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.statusLabel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(report.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Report Type', report.reportTypeLabel),
          const Divider(),
          _buildInfoRow('Period Start', DateFormat('d MMM yyyy, HH:mm').format(report.periodStart)),
          const Divider(),
          _buildInfoRow('Period End', DateFormat('d MMM yyyy, HH:mm').format(report.periodEnd)),
          const Divider(),
          _buildInfoRow('Generated', DateFormat('d MMM yyyy, HH:mm').format(report.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips() {
    final tips = _getTipsForStatus();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: tips.map((tip) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFF2C7796),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  List<String> _getTipsForStatus() {
    switch (report.status) {
      case 'low':
        return [
          'Consider having small, frequent meals throughout the day.',
          'Keep fast-acting glucose sources handy.',
          'Consult your doctor about adjusting medication if needed.',
        ];
      case 'high':
        return [
          'Monitor carbohydrate intake and portion sizes.',
          'Stay physically active with regular exercise.',
          'Stay hydrated by drinking plenty of water.',
        ];
      case 'critical':
        return [
          'Please consult your healthcare provider immediately.',
          'Review your medication and diet plan.',
          'Monitor your glucose levels more frequently.',
        ];
      default:
        return [
          'Great job maintaining healthy glucose levels!',
          'Continue with your current diet and exercise routine.',
          'Keep monitoring regularly to stay on track.',
        ];
    }
  }

  String _getStatusMessage() {
    switch (report.status) {
      case 'low':
        return 'Below normal range';
      case 'high':
        return 'Above normal range';
      case 'critical':
        return 'Needs immediate attention';
      default:
        return 'Within normal range';
    }
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

Future<void> startMeasurement() async {
    // 1. Kirim trigger ke database
    final response = await _supabaseService.sendMeasurementTrigger(userId);
    
    // 2. Pantau status pengukuran secara realtime
    await for (final statusUpdate in _supabaseService.streamCommandStatus(userId)) {
        if (statusUpdate['status'] == 'completed') {
            // 3. Ambil data hasil pengukuran
            final data = await _supabaseService.getLatestMeasurement(userId);
            setState(() {
                glucoseData = GlucoseData.fromJson(data);
                status = 'success';
            });
            break; 
        }
    }
}

Future<void> startMeasurement() async {
    // 1. Kirim trigger ke database
    final response = await _supabaseService.sendMeasurementTrigger(userId);
    
    // 2. Pantau status pengukuran secara realtime
    await for (final statusUpdate in _supabaseService.streamCommandStatus(userId)) {
        if (statusUpdate['status'] == 'completed') {
            // 3. Ambil data hasil pengukuran
            final data = await _supabaseService.getLatestMeasurement(userId);
            setState(() {
                glucoseData = GlucoseData.fromJson(data);
                status = 'success';
            });
            break; 
        }
    }
}
