import 'package:dog_tracker/activities_screen.dart';
import 'package:dog_tracker/custom_navbar.dart';
import 'package:dog_tracker/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // Upcoming tasks
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
    
    // Sort upcoming
    upcomingTasks.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      
      if (a.time == null || b.time == null) return 0;
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });

    // Overdue tasks
    final overdueTasks = tasks
        .where((task) => 
            task != null &&
            task.isDone != null &&
            !task.isDone && 
            task.date != null &&
            task.date.isBefore(DateTime(now.year, now.month, now.day)))
        .toList();

    // Sort overdue
    overdueTasks.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      return a.date.compareTo(b.date);
    });

    // First 3 from each list
    final displayedUpcomingTasks = upcomingTasks.take(3).toList();
    final displayedOverdueTasks = overdueTasks.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFA9B63)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header section
                  Center(
                    child: Text(
                      'WoofWatch',
                      style: GoogleFonts.poppins(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFA9B63),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDCAA),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFBE8E66),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFFBE8E66),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFFBE8E66),
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFBE8E66).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Upcoming tasks section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Upcoming Tasks', Colors.black),
                          const SizedBox(height: 12),
                          
                          if (displayedUpcomingTasks.isEmpty)
                            _buildEmptyTaskCard('No upcoming tasks')
                          else
                            ...displayedUpcomingTasks.map((task) => 
                              _buildTaskCard(
                                '${task.taskType ?? 'Unknown'} - ${task.dogName ?? 'Unknown'}', 
                                task.date != null && task.time != null 
                                    ? _formatTaskDateTime(task.date, task.time) 
                                    : 'Date/time unavailable'
                              )
                            ),

                          const SizedBox(height: 24),

                          // Overdue tasks section
                          _buildSectionHeader('Overdue Tasks', Colors.red),
                          const SizedBox(height: 12),
                          
                          if (displayedOverdueTasks.isEmpty)
                            _buildEmptyTaskCard('No overdue tasks')
                          else
                            ...displayedOverdueTasks.map((task) => 
                              _buildTaskCard(
                                '${task.taskType ?? 'Unknown'} - ${task.dogName ?? 'Unknown'}', 
                                task.date != null ? _getTimeAgo(task.date) : 'Date unavailable',
                                isOverdue: true
                              )
                            ),

                          const SizedBox(height: 24),
                          
                          // Quick help card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.blue.shade200),
                            ),
                            color: Colors.blue.shade50,
                            elevation: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const OnboardingScreen())
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.help_outline, color: Colors.blue.shade700),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Need Help?',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap here to view the onboarding guide again',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
      
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(
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
              initialTabIndex: isOverdue ? 1 : 0, 
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOverdue ? Colors.red.shade50 : const Color(0xFFFFF5EA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue ? Colors.red.shade300 : const Color(0xFFFFDCAA),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isOverdue ? Colors.red.shade700 : const Color(0xFFBE8E66),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isOverdue ? Colors.red : const Color(0xFFFA9B63),
            ),
          ],
        ),
      ),
    );
  }
}
