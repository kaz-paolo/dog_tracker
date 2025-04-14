import 'package:dog_tracker/activities_screen.dart';
import 'package:dog_tracker/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'activity_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final loadedTasks = await ActivityManager.loadTasks();
      if (mounted) {
        setState(() {
          tasks = loadedTasks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //  upcoming tasks
    final now = DateTime.now();
    final upcomingTasks = tasks
        .where((task) => 
            task != null &&
            task.isDone != null && 
            !task.isDone && 
            task.date != null &&
            (task.date.isAfter(now) || 
             (task.date.year == now.year &&
              task.date.month == now.month &&
              task.date.day == now.day)))
        .toList();
    
    // sort upcoming
    upcomingTasks.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      
      if (a.time == null || b.time == null) return 0;
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });

    // overdue tasks
    final overdueTasks = tasks
        .where((task) => 
            task != null &&
            task.isDone != null &&
            !task.isDone && 
            task.date != null &&
            task.date.isBefore(DateTime(now.year, now.month, now.day)))
        .toList();

    // sort overdue
    overdueTasks.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      return a.date.compareTo(b.date);
    });

    // first 3 from each list
    final displayedUpcomingTasks = upcomingTasks.take(3).toList();
    final displayedOverdueTasks = overdueTasks.take(3).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 222, 202),
      body: SafeArea(
        child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(128), // Fixed withOpacity
                      spreadRadius: 0.5,
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming Task Section
              const Text(
                'Upcoming Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Cards for upcoming
              const SizedBox(height: 12),
              if (displayedUpcomingTasks.isEmpty)
                _buildEmptyTaskCard('No upcoming tasks'),
              ...displayedUpcomingTasks.map((task) => 
                _buildTaskCard(
                  '${task.taskType ?? 'Unknown'} - ${task.dogName ?? 'Unknown'}', 
                  task.date != null && task.time != null 
                      ? _formatTaskDateTime(task.date, task.time) 
                      : 'Date/time unavailable'
                )
              ),

              const SizedBox(height: 24),

              // Overdue Task Section
              const Text(
                'Overdue Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              // Cards for overdue
              const SizedBox(height: 12),
              if (displayedOverdueTasks.isEmpty)
                _buildEmptyTaskCard('No overdue tasks'),
              ...displayedOverdueTasks.map((task) => 
                _buildTaskCard(
                  '${task.taskType ?? 'Unknown'} - ${task.dogName ?? 'Unknown'}', 
                  task.date != null ? _getTimeAgo(task.date) : 'Date unavailable',
                  isOverdue: true
                )
              ),

              const SizedBox(height: 24),
              
              // Support Section
              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSupportCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  String _formatTaskDateTime(DateTime date, TimeOfDay time) {
    final now = DateTime.now();
    final taskDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    String dateStr;
    if (taskDate.isAtSameMomentAs(today)) {
      dateStr = 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = DateFormat('EEEE, MMMM d').format(date);
    }
    
    return '$dateStr, ${time.format(context)}';
  }
  
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).round();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Today';
    }
  }

  Widget _buildEmptyTaskCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(128), // Fixed withOpacity
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String time, {bool isOverdue = false}) {
  return InkWell(
    onTap: () {
      // Extract the task type from the title (format is "TaskType - DogName")
      final taskType = title.split(' - ')[0];
      
      // Determine which category this task belongs to
      String category;
      if (['Feed', 'Water', 'Buy Food'].contains(taskType)) {
        category = 'Food and Water';
      } else if (['Exercise', 'Walk', 'Play', 'Training'].contains(taskType)) {
        category = 'Exercise';
      } else if (['Vet Visit', 'Medication', 'Vaccination', 'Weigh'].contains(taskType)) {
        category = 'Health';
      } else {
        category = 'Food and Water'; // Default category
      }
      
      // Navigate to the activity screen with MaterialPageRoute
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityDetailsScreen(
            title: category,
            initialTabIndex: isOverdue? 1:0, 
          ),
        ),
      );
    },
      child: Container(
        // spacing
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),

        // card style
        decoration: BoxDecoration(
          color: isOverdue ? Colors.red[100] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          // card border
          border: Border.all(
            color: isOverdue ? Colors.red[300]! : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(128), // Fixed withOpacity
              spreadRadius: 0.5,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // card content
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Task info
            Expanded(  // Added Expanded to prevent overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // time nd date
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // arrow button
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isOverdue ? Colors.red : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need help?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View the onboarding again for support.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.description, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Onboarding Page',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
