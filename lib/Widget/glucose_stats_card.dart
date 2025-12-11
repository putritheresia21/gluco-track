import 'package:flutter/material.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:intl/intl.dart';

class GlucoseStatsCard extends StatelessWidget {
  final String title;
  final Glucoserecord? glucoseRecord;
  final bool isLowest;
  final bool isLoading;

  const GlucoseStatsCard({
    super.key,
    required this.title,
    required this.glucoseRecord,
    required this.isLowest,
    this.isLoading = false,
  });

  Color _getCardColor() {
    return isLowest
        ? const Color.fromRGBO(98, 206, 84, 1) // Green for lowest
        : const Color(0xFFD9534F); // Red for highest
  }

  IconData _getIconData() {
    return isLowest ? Icons.trending_down : Icons.trending_up;
  }

  Color _getIconBackgroundColor() {
    return isLowest ? Colors.white.withOpacity(0.25) : Colors.white;
  }

  Color _getIconColor() {
    return isLowest ? Colors.white : const Color(0xFFD9534F);
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('EEEE, d MMM yyyy');
    return formatter.format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  String _getConditionLabel(GlucoseCondition condition) {
    return condition == GlucoseCondition.beforeMeal
        ? 'Before Meal'
        : 'After Meal';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 149,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLoading || glucoseRecord == null
            ? Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.7),
                    ),
                    strokeWidth: 2,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getIconData(),
                          color: _getIconColor(),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date
                  Text(
                    '(${_formatDate(glucoseRecord!.timeStamp)})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Glucose Level
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        glucoseRecord!.glucoseLevel.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'mg/dL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Condition Label with Time
                  Text(
                    '${_getConditionLabel(glucoseRecord!.condition)} at ${_formatTime(glucoseRecord!.timeStamp)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
