import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(WorkTimeTrackerApp());
}

class WorkTimeTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work Time Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WorkTimeTrackerScreen(),
    );
  }
}

class WorkTimeTrackerScreen extends StatefulWidget {
  @override
  _WorkTimeTrackerScreenState createState() => _WorkTimeTrackerScreenState();
}

class _WorkTimeTrackerScreenState extends State<WorkTimeTrackerScreen> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String displayText = "Please set your working hours";
  bool isTracking = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _startTracking() {
    if (startTime != null && endTime != null) {
      setState(() {
        isTracking = true;
      });

      // Update the time every second
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _updateDisplayText();
      });
    }
  }

  void _updateDisplayText() {
    if (startTime == null || endTime == null) {
      displayText = "Please set your working hours";
      return;
    }

    final now = TimeOfDay.now();
    final startDateTime = DateTime(0, 0, 0, startTime!.hour, startTime!.minute);
    final endDateTime = DateTime(0, 0, 0, endTime!.hour, endTime!.minute);
    final nowDateTime = DateTime(0, 0, 0, now.hour, now.minute);

    if (!isTracking) {
      displayText = "Press 'Track' to start tracking your working hours.";
    } else if (nowDateTime.isBefore(startDateTime) ||
        nowDateTime.isAfter(endDateTime)) {
      // Calculate relaxation time passed (since the last working period ended)
      Duration relaxationTimePassed;
      if (nowDateTime.isBefore(startDateTime)) {
        relaxationTimePassed =
            nowDateTime.difference(endDateTime.subtract(Duration(days: 1)));
      } else {
        relaxationTimePassed = nowDateTime.difference(endDateTime);
      }

      // Calculate remaining relaxation time until the next start time
      DateTime nextStartDateTime;
      if (nowDateTime.isAfter(endDateTime)) {
        nextStartDateTime = startDateTime.add(Duration(days: 1));
      } else {
        nextStartDateTime = startDateTime;
      }
      final remainingRelaxationTime = nextStartDateTime.difference(nowDateTime);

      displayText =
          "Relaxation Time:\nPassed: ${relaxationTimePassed.inHours}h ${relaxationTimePassed.inMinutes % 60}m\nRemaining: ${remainingRelaxationTime.inHours}h ${remainingRelaxationTime.inMinutes % 60}m";
    } else {
      // Display work time if within working hours
      final elapsed = nowDateTime.difference(startDateTime);
      final remaining = endDateTime.difference(nowDateTime);
      displayText =
          "Working time:\nElapsed: ${elapsed.inHours}h ${elapsed.inMinutes % 60}m\nRemaining: ${remaining.inHours}h ${remaining.inMinutes % 60}m";
    }

    // Update the state to refresh the display text
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Work Time Tracker'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () => _selectTime(context, true),
              child: Text(startTime == null
                  ? "Select Start Time"
                  : "Start Working Time: ${startTime!.format(context)}"),
            ),
            TextButton(
              onPressed: () => _selectTime(context, false),
              child: Text(endTime == null
                  ? "Select End Time"
                  : "End Working Time: ${endTime!.format(context)}"),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTracking,
              child: Text("Track"),
            ),
            SizedBox(height: 24),
            Text(
              displayText,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
