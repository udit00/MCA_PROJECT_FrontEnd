import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zymm/features/attendance/data/models/attendance_model.dart';
import 'package:zymm/features/attendance/data/repositories/attendance_repository.dart';

class ViewEmployeeAttendanceScreen extends StatefulWidget {
  final int userId;
  final String? employeeName;

  const ViewEmployeeAttendanceScreen({
    super.key,
    required this.userId,
    this.employeeName,
  });

  @override
  State<ViewEmployeeAttendanceScreen> createState() =>
      _ViewEmployeeAttendanceScreenState();
}

class _ViewEmployeeAttendanceScreenState
    extends State<ViewEmployeeAttendanceScreen> {
  final AttendanceRepository _repository = AttendanceRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<AttendanceModel> _attendanceList = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _repository.getAllAttendanceForUser(widget.userId);

      if (response.hasError) {
        final errorMsg = response.error?.toLowerCase() ?? '';
        if (errorMsg.contains('no') &&
            (errorMsg.contains('data') ||
                errorMsg.contains('record') ||
                errorMsg.contains('found'))) {
          // Empty list, not an error
          setState(() {
            _attendanceList = [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                response.error ?? 'Failed to fetch attendance records';
            _isLoading = false;
          });
        }
      } else {
        if (response.data == null) {
          _attendanceList = [];
        } else if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          _attendanceList =
              data.map((json) => AttendanceModel.fromJson(json)).toList();
        } else {
          _attendanceList = [];
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeName != null
            ? '${widget.employeeName} - Attendance'
            : 'Employee Attendance'),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchAttendance,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _attendanceList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance records found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchAttendance,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _attendanceList.length,
                        itemBuilder: (context, index) {
                          final attendance = _attendanceList[index];
                          return AttendanceCard(attendance: attendance);
                        },
                      ),
                    ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceCard({
    super.key,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: attendance.isPunchedOut
              ? Colors.grey.shade300
              : Colors.green.shade300,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(attendance.punchInTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!attendance.isPunchedOut)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),

            // Punch In Details
            _buildTimeSection(
              icon: Icons.login,
              label: 'Punch In',
              time: timeFormat.format(attendance.punchInTime),
              address: attendance.punchInAddress,
              iconColor: Colors.green,
            ),

            if (attendance.isPunchedOut) ...[
              const SizedBox(height: 16),
              // Punch Out Details
              _buildTimeSection(
                icon: Icons.logout,
                label: 'Punch Out',
                time: timeFormat.format(attendance.punchOutTime!),
                address: attendance.punchOutAddress ?? 'N/A',
                iconColor: Colors.red,
              ),
              const SizedBox(height: 16),
              // Work Duration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_formatDuration(attendance.workDuration!)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection({
    required IconData icon,
    required String label,
    required String time,
    required String address,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

