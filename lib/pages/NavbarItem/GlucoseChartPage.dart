import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';


enum TimeRange { weekly, monthly }

class GlucoseChart extends StatefulWidget {
  const GlucoseChart({super.key});

  @override
  State<GlucoseChart> createState() => _GlucoseChartState();
}

class _GlucoseChartState extends State<GlucoseChart> {
  final AuthService authService = AuthService();
  final Glucoserepository _repository = Glucoserepository();
  
  List<Glucoserecord> allRecords = []; // For Chart
  List<Glucoserecord> historyRecords = []; // For Pagination List
  
  bool isLoading = true;
  bool isHistoryLoading = false;
  bool hasMoreHistory = true;
  int currentHistoryPage = 0;
  final int historyPageSize = 20;
  final ScrollController _scrollController = ScrollController();

  String? currentUserId;
  TimeRange selectedTimeRange = TimeRange.weekly;

  DateTime displayedMonth = DateTime.now();
  late DateTime displayedWeek;
  String selectedHistoryFilter = 'Semua';
  DateTimeRange? selectedDateRange; // Range tanggal terpilih

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    displayedWeek = _getStartOfWeek(DateTime.now());
    _scrollController.addListener(_onScroll);
    _initializeAndLoadRecords();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!isHistoryLoading && hasMoreHistory) {
        _loadMoreHistory();
      }
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday % 7; 
    DateTime start = date.subtract(Duration(days: daysToSubtract));
    return DateTime(start.year, start.month, start.day); 
  }

  /// Initialize user dan load records
  Future<void> _initializeAndLoadRecords() async {
    if (!authService.isLoggedIn) {
      _handleNotLoggedIn();
      return;
    }

    currentUserId = authService.currentUserId;
    
    if (currentUserId == null) {
      _handleNotLoggedIn();
      return;
    }

    print('🔍 Current User ID: $currentUserId');
    
    // Load ALL records for Chart (Initial Load)
    await loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
    try {
      // 1. Load All Records for Chart
      final records = await _repository.getAllGlucoseRecords(currentUserId!);
      allRecords = records;
      allRecords.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      // 2. Load First Page for History
      currentHistoryPage = 0;
        // If filter is active, we don't paginate from DB normally (complex).
        // For simplicity, if "Semua" is selected, we paginate from DB.
        // If filter is active, we might filter from allRecords or implement filtered pagination.
        // The user asked "jika pilih smua artinya menampilkan semua data, denga page size 20".
        // So pagination applies primarily to "All".
      
      historyRecords = [];
      hasMoreHistory = true;
      await _loadMoreHistory();

      setState(() => isLoading = false);
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMoreHistory() async {
    if (isHistoryLoading || !hasMoreHistory) return;

    setState(() => isHistoryLoading = true);

    try {
      // If we are showing "All" (no date/category filter), use DB pagination
      if (selectedHistoryFilter == 'Semua' && selectedDateRange == null) {
        final newRecords = await _repository.getGlucoseRecordsPaginated(
          currentUserId!,
          historyPageSize,
          currentHistoryPage * historyPageSize,
        );

        if (newRecords.length < historyPageSize) {
          hasMoreHistory = false;
        }

        setState(() {
          historyRecords.addAll(newRecords);
          currentHistoryPage++;
          isHistoryLoading = false;
        });
      } else {
        // If filtered, just use filtered list from allRecords (No pagination logic needed effectively or just paginate local)
        // User specific request was about "pilih smua".
        // So for filters, we assume we show all matches (or implement local pagination if needed).
        // Let's stick to using getFilteredHistoryRecords for filtered view.
        setState(() => isHistoryLoading = false);
      }
    } catch (e) {
      print('Error loading history page: $e');
      setState(() => isHistoryLoading = false);
    }
  }

  void _handleNotLoggedIn() {
    setState(() => isLoading = false);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.sessionNotActive)),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  /// This replaces old loadRecords
  Future<void> loadRecords() async {
    await loadInitialData();
  }

  // Modified to support pagination view vs filtered view
  List<Glucoserecord> getFilteredHistoryRecords() {
    // If "All" and no date filter -> return paginated historyRecords
    if (selectedHistoryFilter == 'Semua' && selectedDateRange == null) {
      return historyRecords;
    }

    // Else filter from allRecords
    List<Glucoserecord> filtered = List.from(allRecords);

    if (selectedDateRange != null) {
      filtered = filtered.where((r) {
        final recordDate = DateTime(r.timeStamp.year, r.timeStamp.month, r.timeStamp.day);
        final start = DateTime(selectedDateRange!.start.year, selectedDateRange!.start.month, selectedDateRange!.start.day);
        final end = DateTime(selectedDateRange!.end.year, selectedDateRange!.end.month, selectedDateRange!.end.day);
        return (recordDate.isAtSameMomentAs(start) || recordDate.isAfter(start)) && 
               (recordDate.isAtSameMomentAs(end) || recordDate.isBefore(end));
      }).toList();
    }

    switch (selectedHistoryFilter) {
      case 'Before Meal':
        filtered = filtered.where((r) => r.condition == GlucoseCondition.beforeMeal).toList();
        break;
      case 'After Meal':
        filtered = filtered.where((r) => r.condition == GlucoseCondition.afterMeal).toList();
        break;
      case 'Low':
        filtered = filtered.where((r) => r.glucoseLevel < 70).toList();
        break;
      case 'Normal':
        filtered = filtered.where((r) => r.glucoseLevel >= 70 && r.glucoseLevel <= 140).toList();
        break;
      case 'High':
        filtered = filtered.where((r) => r.glucoseLevel > 140).toList();
        break;
    }
    return filtered;
  }


  Future<void> pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2C7796),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2C7796)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  List<Glucoserecord> getWeeklyRecords() {
    DateTime endOfWeek = displayedWeek.add(const Duration(days: 7));
    // Inclusive start, exclusive end logic often safer, or check day matches
    
    return allRecords.where((record) {
      return record.timeStamp.isAfter(displayedWeek.subtract(const Duration(seconds: 1))) &&
             record.timeStamp.isBefore(endOfWeek);
    }).toList();
  }

  double getWeeklyAverage() {
    List<Glucoserecord> weeklyRecords = getWeeklyRecords();
    if (weeklyRecords.isEmpty) return 0;

    double sum =
        weeklyRecords.fold(0, (prev, record) => prev + record.glucoseLevel);
    return sum / weeklyRecords.length;
  }

  Map<int, List<Glucoserecord>> getWeeklyGroupedRecords() {
    List<Glucoserecord> weeklyRecords = getWeeklyRecords();
    Map<int, List<Glucoserecord>> grouped = {};

    for (int i = 0; i < 7; i++) {
      grouped[i] = [];
    }

    for (var record in weeklyRecords) {
      // weekday % 7 gives Sunday=0, Mon=1 ... which matches our labels S,M,T...
      int dayOfWeek = record.timeStamp.weekday % 7;
      grouped[dayOfWeek]!.add(record);
    }

    return grouped;
  }




  Color getGlucoseColor(double level, GlucoseCondition condition) {
    if (level < 70) {
      return const Color(0xFFFFF59D); // Kuning muda - Low
    } else if (condition == GlucoseCondition.beforeMeal) {
      if (level >= 70 && level <= 99) {
        return const Color(0xFF66BB6A); // Hijau - Good
      } else {
        return const Color(0xFFEF5350); // Merah - High
      }
    } else {
      if (level < 140) {
        return const Color(0xFF66BB6A); // Hijau - Good
      } else {
        return const Color(0xFFEF5350); // Merah - High
      }
    }
  }

  String getGlucoseLabel(double level, GlucoseCondition condition) {
    if (level < 70) {
      return AppLocalizations.of(context)!.low;
    } else if (condition == GlucoseCondition.beforeMeal) {
      if (level >= 70 && level <= 99) {
        return AppLocalizations.of(context)!.normal;
      } else {
        return AppLocalizations.of(context)!.high;
      }
    } else {
      if (level < 140) {
        return AppLocalizations.of(context)!.normal;
      } else {
        return AppLocalizations.of(context)!.high;
      }
    }
  }

  Widget _buildWeeklyInsightCard() {
    List<Glucoserecord> weeklyRecords = getWeeklyRecords();
    if (weeklyRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.noDataAnalysis,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    // Calculations
    double avg = weeklyRecords.fold(0.0, (sum, r) => sum + r.glucoseLevel) / weeklyRecords.length;
    double min = weeklyRecords.fold(double.infinity, (min, r) => r.glucoseLevel < min ? r.glucoseLevel : min);
    double max = weeklyRecords.fold(double.negativeInfinity, (max, r) => r.glucoseLevel > max ? r.glucoseLevel : max);
    
    int highCount = weeklyRecords.where((r) => r.glucoseLevel > 140).length;
    int lowCount = weeklyRecords.where((r) => r.glucoseLevel < 70).length;
    int normalCount = weeklyRecords.where((r) => r.glucoseLevel >= 70 && r.glucoseLevel <= 140).length;

    // Insight Logic
    String title = AppLocalizations.of(context)!.glucoseStability;
    String message = "";
    Color cardColor = const Color(0xFFE3F2FD); // Light Blue default
    IconData icon = Icons.analytics_outlined;
    Color iconColor = const Color(0xFF1565C0);

    if (highCount > weeklyRecords.length * 0.5) {
      title = AppLocalizations.of(context)!.attentionRequired;
      message = AppLocalizations.of(context)!.highGlucoseTrend;
      cardColor = const Color(0xFFFFEBEE); // Red tint
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFC62828);
    } else if (lowCount > weeklyRecords.length * 0.3) {
      title = AppLocalizations.of(context)!.hypoglycemiaAlert;
      message = AppLocalizations.of(context)!.lowGlucoseTrend;
      cardColor = const Color(0xFFFFF8E1); // Amber tint
      icon = Icons.health_and_safety_outlined;
      iconColor = const Color(0xFFF57F17);
    } else if (normalCount > weeklyRecords.length * 0.7) {
      title = AppLocalizations.of(context)!.goodJob;
      message = AppLocalizations.of(context)!.stableGlucoseMessage;
      cardColor = const Color(0xFFE8F5E9); // Green tint
      icon = Icons.check_circle_outline;
      iconColor = const Color(0xFF2E7D32);
    } else {
      title = AppLocalizations.of(context)!.fairlyStable;
      message = AppLocalizations.of(context)!.stableVariationMessage(avg.toStringAsFixed(0));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.weeklySummary,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(AppLocalizations.of(context)!.average, "${avg.toStringAsFixed(0)} ${AppLocalizations.of(context)!.mgDl}"),
              _buildStatItem(AppLocalizations.of(context)!.highest, "${max.toStringAsFixed(0)} ${AppLocalizations.of(context)!.mgDl}"),
              _buildStatItem(AppLocalizations.of(context)!.lowest, "${min.toStringAsFixed(0)} ${AppLocalizations.of(context)!.mgDl}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  
  List<Glucoserecord> getMonthlyRecords() {
    DateTime startOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    DateTime endOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0, 23, 59, 59);

    return allRecords.where((record) {
      return record.timeStamp.isAfter(startOfMonth) && 
             record.timeStamp.isBefore(endOfMonth);
    }).toList();
  }

  Map<int, List<Glucoserecord>> getMonthlyGroupedRecords() {
    List<Glucoserecord> monthlyRecords = getMonthlyRecords();
    Map<int, List<Glucoserecord>> grouped = {};

    // Group by week (up to 5 weeks in a month)
    for (int i = 0; i < 5; i++) {
      grouped[i] = [];
    }

    // Week 1 starts from day 1
    for (var record in monthlyRecords) {
      // Calculate week number (0-4)
      // (Day - 1) ~/ 7 gives 0 for days 1-7, 1 for days 8-14, etc.
      int dayOfMonth = record.timeStamp.day;
      int weekIndex = (dayOfMonth - 1) ~/ 7;
      
      if (weekIndex > 4) weekIndex = 4; // Just in case, though 31 days -> max index 4.
      
      grouped[weekIndex]!.add(record);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C7796),
          ),
        ),
      );
    }

    return AppLayout(
      showBack: false,
      showHeader: true,
      headerBottomRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      headerBackgroundColor: const Color(0xFFF5F5F5),
      headerForegroundColor: Colors.black,
      bodyBackgroundColor: const Color(0xFFF5F5F5),
      headerContent: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
        child: Text(
          AppLocalizations.of(context)!.glucoseChart,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Button (Moved to Body)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                         _buildToggleButton(AppLocalizations.of(context)!.weekly, TimeRange.weekly),
                         _buildToggleButton(AppLocalizations.of(context)!.monthly, TimeRange.monthly),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),


              // Chart Card (Daily/Weekly/Monthly)
              _buildChartCard(),

              const SizedBox(height: 20),

              // Weekly Insight Card (Only visible when Weekly view is selected)
              if (selectedTimeRange == TimeRange.weekly)
                _buildWeeklyInsightCard(),

              const SizedBox(height: 30),

              // History Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.history,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Date Range Filter Button
                      Row(
                        children: [
                          if (selectedDateRange != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    selectedDateRange = null; // Clear date filter (Show All)
                                  });
                                },
                              ),
                            ),
                          ElevatedButton.icon(
                            onPressed: pickDateRange,
                            icon: const Icon(Icons.date_range, size: 16),
                            label: Text(
                              selectedDateRange == null 
                                ? AppLocalizations.of(context)!.selectDate 
                                : "${DateFormat('d MMM').format(selectedDateRange!.start)} - ${DateFormat('d MMM').format(selectedDateRange!.end)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C7796),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppLocalizations.of(context)!.all, 
                        AppLocalizations.of(context)!.beforeMeal, 
                        AppLocalizations.of(context)!.afterMeal, 
                        AppLocalizations.of(context)!.low, 
                        AppLocalizations.of(context)!.normal, 
                        AppLocalizations.of(context)!.high
                      ].map((filter) {
                        final isSelected = selectedHistoryFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  selectedHistoryFilter = filter;
                                  selectedDateRange = null; 
                                });
                              }
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF2C7796).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF2C7796),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFF2C7796) : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF2C7796) : Colors.grey[300]!,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),


// ... (inside build method, inside Column)

              // History List using ContentList
              Builder(
                builder: (context) {
                  List<Glucoserecord> recordsToShow = getFilteredHistoryRecords();
                  String statusMessage;

                  if (selectedDateRange != null) {
                       statusMessage = AppLocalizations.of(context)!.noDataDateRange;
                  } else if (selectedHistoryFilter != AppLocalizations.of(context)!.all) {
                       statusMessage = AppLocalizations.of(context)!.noDataCategory(selectedHistoryFilter);
                  } else {
                       statusMessage = AppLocalizations.of(context)!.noHistoryData;
                  }

                  // Setup empty widget
                  Widget emptyState = Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          statusMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );

                  return Column(
                    children: [
                      ContentList<Glucoserecord>(
                        items: recordsToShow,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        emptyWidget: emptyState,
                        itemBuilder: (context, record, index) {
                           Color statusColor = getGlucoseColor(record.glucoseLevel, record.condition);
                           String statusLabel = getGlucoseLabel(record.glucoseLevel, record.condition);

                           return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white, // White background
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Leading: Value Box
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1), // Soft background
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          record.glucoseLevel.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor, // Colored text
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.mgDl,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: statusColor.withOpacity(0.8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Middle: Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date & Time
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('d MMM yyyy, HH:mm').format(record.timeStamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Status & Condition
                                        Row(
                                          children: [
                                            // Status Label
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                statusLabel,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Condition Label
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                record.condition == GlucoseCondition.beforeMeal
                                                    ? "Before Meal"
                                                    : "After Meal",
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Trailing: IoT Icon if applicable
                                  if (record.isFromIoT)
                                    Column(
                                      children: [
                                        Icon(Icons.sensors, size: 16, color: Colors.blue[300]),
                                        const SizedBox(height: 4),
                                        Text(
                                          "IoT",
                                          style: TextStyle(fontSize: 8, color: Colors.blue[300]),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                           );
                        },
                      ),

                      // Loading Indicator (Still needed outside ContentList if we want it at bottom, 
                      // actually ContentList handles loadingWidget but that replaces the list usually, or we can use custom logic.
                      // Since we are doing infinite scroll manual logic here with 'items' growing, 
                      // we can just append the loading indicator below the list like before.)
                      if (isHistoryLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 20),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2C7796)),
                          ),
                        ),

                      if (!hasMoreHistory && recordsToShow.isNotEmpty && selectedHistoryFilter == 'Semua' && selectedDateRange == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "Semua data telah ditampilkan",
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, TimeRange range) {
    final isSelected = selectedTimeRange == range;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeRange = range;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C7796) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    // Determine data based on selected range
    int dataPoints = 0;
    List<String> labels = [];
    List<FlSpot> beforeSpots = [];
    List<FlSpot> afterSpots = [];
    String titleText = "";

    if (selectedTimeRange == TimeRange.weekly) {
        dataPoints = 7;
        labels = ["M", "T", "W", "T", "F", "S", "S"];
        Map<int, List<Glucoserecord>> groupedRecords = getWeeklyGroupedRecords();
        
        DateTime endOfWeek = displayedWeek.add(const Duration(days: 6));
        String startStr = DateFormat('d MMM').format(displayedWeek);
        String endStr = DateFormat('d MMM').format(endOfWeek);
        titleText = '${AppLocalizations.of(context)!.monitoring} $startStr - $endStr';

        for (int i = 0; i < dataPoints; i++) {
          List<Glucoserecord> records = groupedRecords[i] ?? [];
          if (records.isNotEmpty) {
            final before = records.where((r) => r.condition == GlucoseCondition.beforeMeal).toList();
            final after = records.where((r) => r.condition == GlucoseCondition.afterMeal).toList();
            
            if (before.isNotEmpty) {
              double avg = before.fold(0.0, (sum, r) => sum + r.glucoseLevel) / before.length;
              beforeSpots.add(FlSpot(i.toDouble(), avg));
            }
            if (after.isNotEmpty) {
              double avg = after.fold(0.0, (sum, r) => sum + r.glucoseLevel) / after.length;
              afterSpots.add(FlSpot(i.toDouble(), avg));
            }
          }
        }
    } else {
        dataPoints = 5; // 5 weeks max
        labels = ["W1", "W2", "W3", "W4", "W5"];
        Map<int, List<Glucoserecord>> groupedRecords = getMonthlyGroupedRecords();
        
        titleText = '${AppLocalizations.of(context)!.monitoring} ${DateFormat('MMMM yyyy').format(displayedMonth)}';

        for (int i = 0; i < dataPoints; i++) {
          List<Glucoserecord> records = groupedRecords[i] ?? [];
          if (records.isNotEmpty) {
             final before = records.where((r) => r.condition == GlucoseCondition.beforeMeal).toList();
             final after = records.where((r) => r.condition == GlucoseCondition.afterMeal).toList();
             
             if (before.isNotEmpty) {
               double avg = before.fold(0.0, (sum, r) => sum + r.glucoseLevel) / before.length;
               beforeSpots.add(FlSpot(i.toDouble(), avg));
             }
             if (after.isNotEmpty) {
               double avg = after.fold(0.0, (sum, r) => sum + r.glucoseLevel) / after.length;
               afterSpots.add(FlSpot(i.toDouble(), avg));
             }
          }
        }
    }
    
    // Check if empty
    bool isEmpty = beforeSpots.isEmpty && afterSpots.isEmpty;
    String emptyMessage = selectedTimeRange == TimeRange.weekly 
      ? AppLocalizations.of(context)!.noDataThisWeek
      : AppLocalizations.of(context)!.noDataThisMonth;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          // Chart Header with Date Nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
                onPressed: () {
                    setState(() {
                      if (selectedTimeRange == TimeRange.weekly) {
                        displayedWeek = displayedWeek.subtract(const Duration(days: 7));
                      } else {
                        displayedMonth = DateTime(
                            displayedMonth.year, displayedMonth.month - 1);
                      }
                    });
                },
              ),
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onPressed: () {
                    setState(() {
                      if (selectedTimeRange == TimeRange.weekly) {
                        displayedWeek = displayedWeek.add(const Duration(days: 7));
                      } else {
                        displayedMonth = DateTime(
                            displayedMonth.year, displayedMonth.month + 1);
                      }
                    });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          if (isEmpty)
             SizedBox(
                height: 200,
                child: Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey))),
             )
          else
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (dataPoints - 1).toDouble(),
                minY: 0,
                maxY: 300, // Fixed scale for glucose
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                             return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                   labels[value.toInt()],
                                   style: const TextStyle(
                                     color: Colors.grey,
                                     fontSize: 12,
                                   ),
                                ),
                             );
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 70 || value == 140 || value == 200 || value == 300) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Before Meal Line
                  if (beforeSpots.isNotEmpty)
                    LineChartBarData(
                      spots: beforeSpots,
                      isCurved: true,
                      color: const Color(0xFF2C7796),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2C7796).withOpacity(0.05),
                      ),
                    ),
                  // After Meal Line
                  if (afterSpots.isNotEmpty)
                    LineChartBarData(
                      spots: afterSpots,
                      isCurved: true,
                      color: Colors.orange[400],
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange[400]!.withOpacity(0.05),
                      ),
                    ),
                ],
                // Range Annotations (Color Zones)
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 0, y2: 70,
                      color: const Color(0xFFFFF9C4).withOpacity(0.2), // Low
                    ),
                    HorizontalRangeAnnotation(
                      y1: 70, y2: 140,
                      color: const Color(0xFFC8E6C9).withOpacity(0.2), // Normal
                    ),
                    HorizontalRangeAnnotation(
                      y1: 140, y2: 300,
                      color: const Color(0xFFFFCDD2).withOpacity(0.2), // High
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final label = labels[touchedSpot.x.toInt()];
                        final isBefore = touchedSpot.barIndex == 0 && beforeSpots.isNotEmpty;
                        final type = isBefore ? "Before" : "After";
                        return LineTooltipItem(
                          "$label ($type): ${touchedSpot.y.toStringAsFixed(0)} mg/dL",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          // Legend for Categories (Lines)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLineLegendItem(const Color(0xFF2C7796), "Before Meal"),
              const SizedBox(width: 20),
              _buildLineLegendItem(Colors.orange[400]!, "After Meal"),
            ],
          ),
          const SizedBox(height: 12),
          // Legend for Zones (Background)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFFEF5350).withOpacity(0.5), "High"),
              const SizedBox(width: 15),
              _buildLegendItem(const Color(0xFF66BB6A).withOpacity(0.5), "Normal"),
              const SizedBox(width: 15),
              _buildLegendItem(const Color(0xFFFFF59D).withOpacity(0.5), "Low"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneIndicator(Color color, String label, String range) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          range,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

} 
