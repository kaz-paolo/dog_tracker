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
  final double? weight;

  ActivityTask({
    required this.taskType,
    required this.dogName,
    required this.date,
    required this.time,
    this.notes = '',
    this.isDone = false,
    this.repeatInterval,
    this.weight,
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
      weight: json['weight'] != null
          ? double.parse(json['weight'].toString())
          : null, // Parse weight
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
    if (dogs.isNotEmpty) {
      selectedDog = dogs.first.name;
    }
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

  Future<void> _updateDogWeight(String dogName, double weight) async {
    try {
      // Find the dog in the list
      final dogIndex = dogs.indexWhere((dog) => dog.name == dogName);
      if (dogIndex == -1) return;

      // Update the dog's weight
      final updatedDog = dogs[dogIndex].copyWith(
          weight: weight.toString()); // Convert to string for Dog class

      // Update the local list
      setState(() {
        dogs[dogIndex] = updatedDog;
      });

      // Save the updated dog list
      await DogListManager.saveDogList(dogs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated weight for $dogName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating weight: $e')),
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

  Future<void> _updateDogHealth(String dogName, String healthStatus) async {
    try {
      // Find the dog in the list
      final dogIndex = dogs.indexWhere((dog) => dog.name == dogName);
      if (dogIndex == -1) return;

      // Update the dog's health status
      final updatedDog = dogs[dogIndex].copyWith(health: healthStatus);

      // Update the local list
      setState(() {
        dogs[dogIndex] = updatedDog;
      });

      // Save the updated dog list
      await DogListManager.saveDogList(dogs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated health status for $dogName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating health status: $e')),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(ActivityTask task, bool isDone) async {
    if (isDone) {
      // Confirm with the user before creating a repeating task
      if (task.repeatInterval != null) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Repeating Task'),
            content: Text(
                'This task repeats ${_getRepeatText(task.repeatInterval!)}. Completing it will create a new instance for the next period.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );

        if (shouldProceed != true) return;
      }

      ActivityTask updatedTask = task;

      if (task.taskType == 'Weigh') {
        final weightText = await _showWeightInputDialog(context, task.dogName);
        if (weightText == null) return;

        final weight = double.tryParse(weightText);
        if (weight == null) return;

        updatedTask = ActivityTask(
          taskType: task.taskType,
          dogName: task.dogName,
          date: task.date,
          time: task.time,
          notes: task.notes,
          isDone: isDone,
          repeatInterval: task.repeatInterval,
          weight: weight,
        );

        _updateDogWeight(task.dogName, weight);
      } else if (task.taskType == 'Vet Visit') {
        final healthStatus =
            await _showHealthStatusDialog(context, task.dogName);
        if (healthStatus == null) return;

        updatedTask = ActivityTask(
          taskType: task.taskType,
          dogName: task.dogName,
          date: task.date,
          time: task.time,
          notes: task.notes,
          isDone: isDone,
          repeatInterval: task.repeatInterval,
          weight: task.weight,
        );

        _updateDogHealth(task.dogName, healthStatus);
      } else {
        task.isDone = isDone;
      }

      setState(() {
        tasks.remove(task);
        tasks.add(updatedTask);
      });

      if (!isDone) {
        // Show SnackBar immediately after setting the state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task marked as incomplete')),
          );
        });
      }

      // Create next repeating task if applicable
      if (task.repeatInterval != null) {
        final nextDate = _calculateNextDate(task.date, task.repeatInterval!);

        final nextTask = ActivityTask(
          taskType: task.taskType,
          dogName: task.dogName,
          date: nextDate,
          time: task.time,
          notes: task.notes,
          isDone: false,
          repeatInterval: task.repeatInterval,
          weight: null,
        );

        setState(() {
          tasks.add(nextTask);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'New ${_getRepeatText(task.repeatInterval!)} task created'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Undo completion
      setState(() {
        task.isDone = isDone; // Update task status
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

    // Save updated tasks
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

  Future<String?> _showHealthStatusDialog(
      BuildContext context, String dogName) async {
    String? selectedStatus;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Health Status for $dogName'),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          hint: const Text('Select Health Status'),
          items: const [
            DropdownMenuItem(value: 'Healthy', child: Text('Healthy')),
            DropdownMenuItem(value: 'Sick', child: Text('Sick')),
            DropdownMenuItem(
                value: 'Under Observation', child: Text('Under Observation')),
          ],
          onChanged: (String? newValue) {
            selectedStatus = newValue;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedStatus),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  DateTime _calculateNextDate(DateTime date, String repeatInterval) {
    switch (repeatInterval) {
      case 'daily':
        return date.add(const Duration(days: 1));
      case 'weekly':
        return date.add(const Duration(days: 7));
      case 'monthly':
        if (date.month == 12) {
          return DateTime(date.year + 1, 1, date.day);
        } else {
          return DateTime(date.year, date.month + 1, date.day);
        }
      default:
        return date.add(const Duration(days: 1));
    }
  }

  Future<String?> _showWeightInputDialog(
      BuildContext context, String dogName) async {
    final weightController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Weight for $dogName'),
        content: TextField(
          controller: weightController,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'Enter current weight in kg',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (weightController.text.isNotEmpty) {
                Navigator.pop(context, weightController.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(String status) {
    List<ActivityTask> filteredTasks = [];
    final now = DateTime.now();

    // Filtering logic based on status
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

    // Filter by status
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

    return Column(
      children: [
        if (status == 'Done')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _clearAllDoneTasks,
              child: const Text('Clear All Done Tasks'),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _getIconForTaskType(task.taskType),
                  title: Text(task.taskType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dog: ${task.dogName}'),
                      Text(
                          'Date: ${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')} at ${task.time.format(context)}'),
                      if (task.notes.isNotEmpty) Text('Notes: ${task.notes}'),
                      if (task.taskType == 'Weigh' && task.weight != null)
                        Text('Weight: ${task.weight!.toStringAsFixed(1)} kg')
                    ],
                  ),
                  trailing: status == 'Done'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo, color: Colors.blue),
                              onPressed: () {
                                _updateTaskStatus(task, false);
                              },
                            ),
                            const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        )
                      : Checkbox(
                          value: task.isDone,
                          onChanged: (value) {
                            _updateTaskStatus(task, value ?? false);
                          },
                        ),
                  onTap: () => _showTaskDetails(context, task),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _clearAllDoneTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Done Tasks'),
        content:
            const Text('Are you sure you want to delete all completed tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tasks.removeWhere((task) => task.isDone);
              });
              ActivityManager.saveTasks(tasks).then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All done tasks cleared')),
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
                if (task.taskType == 'Weigh' && task.weight != null)
                  ListTile(
                    leading: const Icon(Icons.monitor_weight),
                    title:
                        Text('Weight: ${task.weight!.toStringAsFixed(1)} kg'),
                  ),
                if (task.taskType == 'Vet Visit' && task.isDone)
                  ListTile(
                    leading: const Icon(Icons.health_and_safety),
                    title: Text('Health Status: Updated'),
                  ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                      'Date: ${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}'),
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
                if (task.repeatInterval != null)
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: Text(
                        'Repeats: ${_getRepeatText(task.repeatInterval!)}'),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editTask(task); // Call the edit function
              },
              child: const Text('EDIT'),
            ),
            if (task.isDone)
              TextButton(
                onPressed: () {
                  _updateTaskStatus(task, false);
                  Navigator.pop(context);
                },
                child: const Text('MARK INCOMPLETE'),
              ),
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

  void _editTask(ActivityTask task) async {
    // Initialize variables with the current task values
    selectedDog = task.dogName;
    selectedTaskType = task.taskType;
    selectedDate = task.date;
    selectedTime = task.time;
    repeatInterval = task.repeatInterval;

    _dateController.text =
        "${task.date.day}/${task.date.month}/${task.date.year}";
    _timeController.text = "${task.time.hour}:${task.time.minute}";
    _notesController.text = task.notes;

    // Show the edit dialog
    final editedTask = await showDialog<ActivityTask>(
      context: context,
      builder: (BuildContext context) {
        return _editTaskDialog(task);
      },
    );

    // If the task was edited, update the list and save
    if (editedTask != null) {
      setState(() {
        int index = tasks.indexWhere((t) =>
            t.taskType == task.taskType &&
            t.dogName == task.dogName &&
            t.date == task.date &&
            t.time.hour == task.time.hour &&
            t.time.minute == task.time.minute);
        if (index != -1) {
          tasks[index] = editedTask;
        }
      });

      ActivityManager.saveTasks(tasks).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated')),
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

  Widget _editTaskDialog(ActivityTask task) {
    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text('Edit ${widget.title} Task'),
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
                _buildTaskTypeDropdown(widget.title, setStateDialog),
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
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setStateDialog(() {
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
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setStateDialog(() {
                        selectedTime = pickedTime;
                        _timeController.text =
                            "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: repeatInterval,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (String? value) {
                    setStateDialog(() {
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
              child: const Text('SAVE'),
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
                        DropdownMenuItem(
                            value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(
                            value: 'monthly', child: Text('Monthly')),
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

    // Initialize selectedTaskType if it's null and taskTypes is not empty
    if (selectedTaskType == null && taskTypes.isNotEmpty) {
      selectedTaskType = taskTypes.first;
    }

    return DropdownButtonFormField<String>(
      value: selectedTaskType,
      hint: const Text('Select Task Type'),
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
      validator: (value) {
        if (value == null) {
          return 'Please select a task type';
        }
        return null;
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
          t.time.minute == task.time.minute);
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
          t.time.minute == task.time.minute);
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
