import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';

class TaskDetailPage extends StatefulWidget {
  final MainTask task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _gamification = GamificationService.instance;
  bool _claiming = false;

  Future<void> _claimSubTask(SubTask subTask) async {
    if (_claiming) return;

    setState(() => _claiming = true);

    final success =
        await _gamification.claimSubTask(widget.task.type, subTask.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat! Anda mendapat ${subTask.points} poin'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal claim poin'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _claiming = false);
    }
  }

  String _getSubTaskTitle(int requiredCount) {
    switch (widget.task.type) {
      case TaskType.manualGlucose:
        return '${requiredCount}x Pencatatan Manual Gula Darah';
      case TaskType.iotGlucose:
        return '${requiredCount}x Pencatatan IoT Gula Darah';
      case TaskType.socialPost:
        return '${requiredCount}x Post any updates on Social Feeds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks =
        widget.task.subTasks.where((t) => t.claimed).toList();
    final uncompletedTasks =
        widget.task.subTasks.where((t) => !t.claimed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C7796),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2C7796),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.task.completedSubTasks}/${widget.task.totalSubTasks} Tasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.task.totalPoints}/${widget.task.maxPoints} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: widget.task.progress,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7CB342),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...uncompletedTasks.map((subTask) => _SubTaskCard(
                        subTask: subTask,
                        title: _getSubTaskTitle(subTask.requiredCount),
                        currentCount: widget.task.currentCount,
                        onClaim: () => _claimSubTask(subTask),
                        claiming: _claiming,
                      )),
                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...completedTasks.map((subTask) => _SubTaskCard(
                          subTask: subTask,
                          title: _getSubTaskTitle(subTask.requiredCount),
                          currentCount: widget.task.currentCount,
                          onClaim: () {},
                          claiming: false,
                        )),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubTaskCard extends StatelessWidget {
  final SubTask subTask;
  final String title;
  final int currentCount;
  final VoidCallback onClaim;
  final bool claiming;

  const _SubTaskCard({
    required this.subTask,
    required this.title,
    required this.currentCount,
    required this.onClaim,
    required this.claiming,
  });

  bool get canClaim =>
      !subTask.claimed && currentCount >= subTask.requiredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: subTask.claimed
              ? Colors.green.shade300
              : const Color(0xFF2C7796).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: subTask.claimed
                  ? Colors.green.shade50
                  : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${subTask.requiredCount}x',
                style: TextStyle(
                  color: subTask.claimed
                      ? Colors.green.shade700
                      : const Color(0xFF2C7796),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: subTask.claimed ? Colors.grey : Colors.black87,
                    decoration: subTask.claimed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${subTask.points} pts',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        subTask.claimed ? Colors.grey : const Color(0xFF7CB342),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (subTask.claimed)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 24,
              ),
            )
          else if (canClaim)
            ElevatedButton(
              onPressed: claiming ? null : onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C7796),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: claiming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Claim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$currentCount/${subTask.requiredCount}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
