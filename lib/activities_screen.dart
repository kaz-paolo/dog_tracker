import 'package:dog_tracker/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'dog_list_manager.dart';
import 'dog.dart';
import 'activity_manager.dart';

class ActivityTask {
  final String taskType;
  final String dogName;
  final DateTime date;
  final TimeOfDay time;
  final String notes;
  bool isDone;
  final String? repeatInterval;

  ActivityTask({
    required this.taskType,
    required this.dogName,
    required this.date,
    required this.time,
    this.notes = '',
    this.isDone = false,
    this.repeatInterval,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskType': taskType,
      'dogName': dogName,
      'date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'notes': notes,
      'isDone': isDone,
      'repeatInterval': repeatInterval,
    };
  }

  static ActivityTask fromJson(Map<String, dynamic> json) {
    final dateParts = json['date'].split('-');
    final timeParts = json['time'].split(':');

    return ActivityTask(
      taskType: json['taskType'],
      dogName: json['dogName'],
      date: DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      ),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      notes: json['notes'] ?? '',
      isDone: json['isDone'] ?? false,
      repeatInterval: json['repeatInterval'] ?? '',
    );
  }
}

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActivityCard(
              context,
              'Food and Water',
              'Track meals, water intake, and feeding schedules',
              Icons.restaurant,
              Colors.orange.shade100,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityDetailsScreen(
                    title: 'Food and Water',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              context,
              'Exercise',
              'Log walks, playtime, and physical activities',
              Icons.directions_walk,
              Colors.green.shade100,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityDetailsScreen(
                    title: 'Exercise',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              context,
              'Health',
              'Record vet visits, medications and wellness tracking',
              Icons.favorite,
              Colors.red.shade100,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityDetailsScreen(
                    title: 'Health',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityDetailsScreen extends StatefulWidget {
  final String title;
  final int initialTabIndex;
  
  const ActivityDetailsScreen({
    super.key, 
    required this.title,
    this.initialTabIndex = 0, // 0 is upcoming
  });

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Dog> dogs = [];
  String? selectedDog;
  String? selectedTaskType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? repeatInterval;

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  //store tasks
  List<ActivityTask> tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex, // provided index
    );
    _loadDogs();
    _loadTasks();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDogs() async {
    try {
      final loadedDogs = await DogListManager.loadDogList();
      if (mounted) {
        setState(() {
          dogs = loadedDogs;
          if (dogs.isNotEmpty) {
            selectedDog = dogs[0].name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dogs: $e')),
        );
      }
    }
  }

  Future<void> _loadTasks() async {
    try {
      final loadedTasks = await ActivityManager.loadTasks();
      if (mounted) {
        setState(() {
          tasks = loadedTasks;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('Upcoming'),
          _buildTaskList('Overdue'),
          _buildTaskList('Done'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _updateTaskStatus(ActivityTask task, bool isDone) {
    setState(() {
      task.isDone = isDone;
      
      // If task is marked as done and is repeating, create the next instance
      if (isDone && task.repeatInterval != null) {
        DateTime nextDate;
        
        // Calculate next date based on repeat interval
        switch (task.repeatInterval) {
          case 'daily':
            nextDate = task.date.add(const Duration(days: 1));
            break;
          case 'weekly':
            nextDate = task.date.add(const Duration(days: 7));
            break;
          case 'monthly':
            // Add a month by setting to the same day in the next month
            if (task.date.month == 12) {
              nextDate = DateTime(task.date.year + 1, 1, task.date.day);
            } else {
              nextDate = DateTime(task.date.year, task.date.month + 1, task.date.day);
            }
            break;
          default:
            nextDate = task.date.add(const Duration(days: 1));
        }
        
        // Create new task
        final nextTask = ActivityTask(
          taskType: task.taskType,
          dogName: task.dogName,
          date: nextDate,
          time: task.time,
          notes: task.notes,
          isDone: false,
          repeatInterval: task.repeatInterval,
        );
        
        tasks.add(nextTask);
      }
    });
    
    ActivityManager.saveTasks(tasks).then((_) {
      debugPrint("Tasks saved successfully after status update");
    }).catchError((error) {
      debugPrint("Error saving tasks: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task update: $error')),
        );
      }
    });
  }

  Widget _buildTaskList(String status) {
    List<ActivityTask> filteredTasks = [];
    final now = DateTime.now();

    // filtering
    List<ActivityTask> activityTypeTasks = [];
    if (widget.title == 'Food and Water') {
      activityTypeTasks = tasks
          .where(
              (task) => ['Feed', 'Water', 'Buy Food'].contains(task.taskType))
          .toList();
    } else if (widget.title == 'Exercise') {
      activityTypeTasks = tasks
          .where((task) => ['Exercise', 'Walk', 'Play'].contains(task.taskType))
          .toList();
    } else if (widget.title == 'Health') {
      activityTypeTasks = tasks
          .where((task) => ['Vet Visit', 'Medication', 'Vaccination', 'Weigh']
              .contains(task.taskType))
          .toList();
    } else {
      activityTypeTasks = tasks;
    }

    //  filter by status
    if (status == 'Upcoming') {
      filteredTasks = activityTypeTasks
          .where((task) =>
              !task.isDone &&
              (task.date.isAfter(now) ||
                  (task.date.year == now.year &&
                      task.date.month == now.month &&
                      task.date.day == now.day)))
          .toList();
    } else if (status == 'Overdue') {
      filteredTasks = activityTypeTasks
          .where((task) =>
              !task.isDone &&
              task.date.isBefore(DateTime(now.year, now.month, now.day)))
          .toList();
    } else if (status == 'Done') {
      filteredTasks = activityTypeTasks.where((task) => task.isDone).toList();
      // Sort by most recent first for "Done" tasks
      filteredTasks.sort((a, b) {
        // First compare dates in descending order
        int dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;
        
        // If dates are the same, compare times
        final aMinutes = a.time.hour * 60 + a.time.minute;
        final bMinutes = b.time.hour * 60 + b.time.minute;
        return bMinutes.compareTo(aMinutes);
      });
    }

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text('No $status ${widget.title} tasks yet.'),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: _getIconForTaskType(task.taskType),
                title: Text(task.taskType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dog: ${task.dogName}'),
                    Text(
                        'Date: ${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')} at ${task.time.format(context)}'),
                    if (task.notes.isNotEmpty) Text('Notes: ${task.notes}'),
                  ],
                ),
                trailing: status == 'Done' 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          _updateTaskStatus(task, value ?? false);
                        },
                      ),
                onTap: () => _showTaskDetails(context, task),
              ),
              // Add repeating label if task is repeating
              if (task.repeatInterval != null && task.repeatInterval!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.repeat, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Repeating: ${_getRepeatText(task.repeatInterval!)}',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 210, 133, 25),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showTaskDetails(BuildContext context, ActivityTask task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              _getIconForTaskType(task.taskType),
              const SizedBox(width: 10),
              Expanded(child: Text(task.taskType)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text('Dog: ${task.dogName}'),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Date: ${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}'),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('Time: ${task.time.format(context)}'),
                ),
                if (task.notes.isNotEmpty) 
                  ListTile(
                    leading: const Icon(Icons.note),
                    title: const Text('Notes:'),
                    subtitle: Text(task.notes),
                  ),
                // Show repeat information if available
                if (task.repeatInterval != null)
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: Text('Repeats: ${_getRepeatText(task.repeatInterval!)}'),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            if (!task.isDone) 
              TextButton(
                onPressed: () {
                  _updateTaskStatus(task, true);
                  Navigator.pop(context);
                },
                child: const Text('MARK DONE'),
              ),
            TextButton(
              onPressed: () {
                _deleteTask(task);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('DELETE'),
            ),
            if (task.repeatInterval != null)
              TextButton(
                onPressed: () {
                  _stopRepeating(task);
                  Navigator.pop(context);
                },
                child: const Text('STOP REPEATING'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Widget _getIconForTaskType(String taskType) {
    switch (taskType) {
      case 'Feed':
        return const Icon(Icons.restaurant);
      case 'Water':
        return const Icon(Icons.local_drink);
      case 'Buy Food':
        return const Icon(Icons.shopping_cart);
      case 'Exercise':
      case 'Walk':
        return const Icon(Icons.directions_walk);
      case 'Play':
        return const Icon(Icons.toys);
      case 'Vet Visit':
        return const Icon(Icons.medical_services);
      case 'Medication':
        return const Icon(Icons.medication);
      case 'Vaccination':
        return const Icon(Icons.vaccines);
      case 'Weigh':
        return const Icon(Icons.monitor_weight);
      default:
        return const Icon(Icons.pets);
    }
  }

  void _addTask() async {
    //  form values
    selectedTaskType = null;
    selectedDate = null;
    selectedTime = null;
    repeatInterval = null;
    _dateController.clear();
    _timeController.clear();
    _notesController.clear();
    _amountController.clear();
    _durationController.clear();
    _distanceController.clear();

    await _loadDogs();

    if (!mounted) return;

    //  dialog to add new task
    final result = await showDialog<ActivityTask>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${widget.title} Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDog,
                      hint: const Text('Select Dog'),
                      decoration: const InputDecoration(labelText: 'Dog'),
                      items: dogs.map((Dog dog) {
                        return DropdownMenuItem<String>(
                          value: dog.name,
                          child: Text(dog.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedDog = value;
                        });
                      },
                    ),
                    _buildTaskTypeDropdown(widget.title, setState),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                            _dateController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
                            _timeController.text =
                                "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    if (widget.title == 'Food and Water' &&
                        selectedTaskType == 'Feed')
                      TextFormField(
                        controller: _amountController,
                        decoration:
                            const InputDecoration(labelText: 'Amount (g)'),
                        keyboardType: TextInputType.number,
                      ),
                    DropdownButtonFormField<String>(
                      value: repeatInterval,
                      hint: const Text('Repeat'),
                      decoration: const InputDecoration(labelText: 'Repeat'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('None')),
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          repeatInterval = value;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDog == null ||
                        selectedTaskType == null ||
                        selectedDate == null ||
                        selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all required fields')),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      ActivityTask(
                        taskType: selectedTaskType!,
                        dogName: selectedDog!,
                        date: selectedDate!,
                        time: selectedTime!,
                        notes: _notesController.text,
                        repeatInterval: repeatInterval,
                      ),
                    );
                  },
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );

    // add the new task and save
    if (result != null && mounted) {
      setState(() {
        tasks.add(result);
      });
      
      try {
        await ActivityManager.saveTasks(tasks);
        if (mounted) {
          debugPrint("New task saved successfully");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving new task: $e')),
          );
        }
      }
    }
  }

  Widget _buildTaskTypeDropdown(String category, StateSetter setStateDialog) {
    List<String> taskTypes = [];

    if (category == 'Food and Water') {
      taskTypes = ['Feed', 'Water', 'Buy Food'];
    } else if (category == 'Exercise') {
      taskTypes = ['Walk', 'Play', 'Training'];
    } else if (category == 'Health') {
      taskTypes = ['Vet Visit', 'Medication', 'Vaccination', 'Weigh'];
    }

    return DropdownButtonFormField<String>(
      value: selectedTaskType,
      hint: const Text('Select Task Type'),
      decoration: const InputDecoration(labelText: 'Task Type'),
      items: taskTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setStateDialog(() {
          selectedTaskType = value;
        });
      },
    );
  }

  // Helper function to get readable repeat text
  String _getRepeatText(String repeatInterval) {
    switch (repeatInterval) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return repeatInterval;
    }
  }

  // Delete a task
  void _deleteTask(ActivityTask task) {
    setState(() {
      tasks.removeWhere((t) => 
        t.taskType == task.taskType && 
        t.dogName == task.dogName && 
        t.date == task.date && 
        t.time.hour == task.time.hour && 
        t.time.minute == task.time.minute
      );
    });
    
    ActivityManager.saveTasks(tasks).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $error')),
        );
      }
    });
  }

  // Stop repeating a task
  void _stopRepeating(ActivityTask task) {
    // Create a new task without repeat
    final newTask = ActivityTask(
      taskType: task.taskType,
      dogName: task.dogName,
      date: task.date,
      time: task.time,
      notes: task.notes,
      isDone: task.isDone,
      // No repeatInterval
    );
    
    setState(() {
      // Remove old task
      tasks.removeWhere((t) => 
        t.taskType == task.taskType && 
        t.dogName == task.dogName && 
        t.date == task.date && 
        t.time.hour == task.time.hour && 
        t.time.minute == task.time.minute
      );
      // Add new task without repeat
      tasks.add(newTask);
    });
    
    ActivityManager.saveTasks(tasks).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task will no longer repeat')),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $error')),
        );
      }
    });
  }
}

