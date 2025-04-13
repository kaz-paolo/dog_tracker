import 'package:flutter/material.dart';
import 'dog_list_manager.dart';
import 'dog.dart';
import 'activity_manager.dart';
import 'custom_navbar.dart';

class ActivityTask {
  final String taskType;
  final String dogName;
  final DateTime date;
  final TimeOfDay time;
  final String notes;
  bool isDone;

  ActivityTask({
    required this.taskType,
    required this.dogName,
    required this.date,
    required this.time,
    this.notes = '',
    this.isDone = false,
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
  const ActivityDetailsScreen({super.key, required this.title});

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

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  //store tasks
  List<ActivityTask> tasks = [];

  // summary data
  Map<String, dynamic> summaryData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDogs();
    _loadTasks();
    _calculateSummaryData();
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
          _calculateSummaryData();
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

  void _calculateSummaryData() {
    if (dogs.isEmpty) return;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Initialize summary structure
      summaryData = {};
      for (var dog in dogs) {
        summaryData[dog.name] = {
          'totalFeedings': 0,
          'todayFeedings': 0,
          'lastFed': null,
          'totalWalks': 0,
          'walkMinutesToday': 0,
          'upcomingVetVisits': 0,
        };
      }

      // calculate statistics
      for (var task in tasks) {
        if (!summaryData.containsKey(task.dogName)) continue;

        final taskDate =
            DateTime(task.date.year, task.date.month, task.date.day);
        final isToday = taskDate.year == today.year &&
            taskDate.month == today.month &&
            taskDate.day == today.day;

        if (task.taskType == 'Feed') {
          summaryData[task.dogName]['totalFeedings']++;
          if (isToday) {
            summaryData[task.dogName]['todayFeedings']++;
          }

          final taskDateTime = DateTime(
            task.date.year,
            task.date.month,
            task.date.day,
            task.time.hour,
            task.time.minute,
          );

          final lastFed = summaryData[task.dogName]['lastFed'];
          if (lastFed == null || taskDateTime.isAfter(lastFed)) {
            summaryData[task.dogName]['lastFed'] = taskDateTime;
          }
        }

        // add walk statistics
        else if (task.taskType == 'Walk' || task.taskType == 'Exercise') {
          summaryData[task.dogName]['totalWalks']++;
          if (isToday) {
            // duration from notes
            try {
              final durationText = task.notes.split(' ').firstWhere(
                    (part) => RegExp(r'^\d+$').hasMatch(part),
                    orElse: () => '0',
                  );
              int duration = int.tryParse(durationText) ?? 0;
              summaryData[task.dogName]['walkMinutesToday'] += duration;
            } catch (_) {
              // If parsing fails, add default duration
              summaryData[task.dogName]['walkMinutesToday'] += 30;
            }
          }
        }

        //  vet visit statistics
        else if (task.taskType == 'Vet Visit') {
          if (!task.isDone && task.date.isAfter(now)) {
            summaryData[task.dogName]['upcomingVetVisits']++;
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error calculating summary data: $e');
      print('Stack trace: $stackTrace');
      summaryData = {};
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
      body: Column(
        children: [
          _buildSummarySection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('Upcoming'),
                _buildTaskList('Overdue'),
                _buildTaskList('Done'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      // bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSummarySection() {
    // display different summary
    if (dogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Add dogs to view activity summary'),
      );
    }

    if (widget.title == 'Food and Water') {
      return _buildFoodWaterSummary();
    } else if (widget.title == 'Exercise') {
      return _buildExerciseSummary();
    } else if (widget.title == 'Health') {
      return _buildHealthSummary();
    }

    return const SizedBox.shrink();
  }

  Widget _buildFoodWaterSummary() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feeding Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...dogs.map((dog) {
            final data = summaryData[dog.name];
            if (data == null) {
              return const SizedBox.shrink(); // skip
            }
            final lastFed = data['lastFed'] as DateTime?;
            final lastFedText = lastFed != null
                ? '${lastFed.day}/${lastFed.month} at ${lastFed.hour}:${lastFed.minute.toString().padLeft(2, '0')}'
                : 'Not recorded';

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(dog.name)),
                  Text(
                      '${data['todayFeedings']} meals today • Last fed: $lastFedText'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseSummary() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercise Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...dogs.map((dog) {
            final data = summaryData[dog.name];
            if (data == null) {
              return const SizedBox.shrink(); // skip
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(dog.name)),
                  Text(
                      'Total walks: ${data['totalWalks']} • Today: ${data['walkMinutesToday']} minutes'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.red.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...dogs.map((dog) {
            final data = summaryData[dog.name];
            if (data == null) {
              return const SizedBox.shrink(); // skip
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(dog.name)),
                  Text('Upcoming vet visits: ${data['upcomingVetVisits']}'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _updateTaskStatus(ActivityTask task, bool isDone) {
    setState(() {
      task.isDone = isDone;
    });
    ActivityManager.saveTasks(tasks).then((_) {
      debugPrint("Tasks saved successfully after status update");
      _calculateSummaryData();
    }).catchError((error) {
      debugPrint("Error saving tasks: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving task update: $error')),
      );
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
              ],
            ),
            trailing: Checkbox(
              value: task.isDone,
              onChanged: (value) {
                _updateTaskStatus(task, value ?? false);
              },
            ),
          ),
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
    _dateController.clear();
    _timeController.clear();
    _notesController.clear();
    _amountController.clear();
    _durationController.clear();
    _distanceController.clear();

    await _loadDogs();

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
    if (result != null) {
      setState(() {
        tasks.add(result);
        _calculateSummaryData();
      });
      try {
        await ActivityManager.saveTasks(tasks);
        debugPrint("New task saved successfully");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving new task: $e')),
        );
      }
    }
  }

  List<DropdownMenuItem<String>> _getTaskTypeItems() {
    if (widget.title == 'Food and Water') {
      return const [
        DropdownMenuItem(value: 'Feed', child: Text('Feed')),
        DropdownMenuItem(value: 'Water', child: Text('Water')),
        DropdownMenuItem(value: 'Buy Food', child: Text('Buy Food')),
      ];
    } else if (widget.title == 'Exercise') {
      return const [
        DropdownMenuItem(value: 'Walk', child: Text('Walk')),
        DropdownMenuItem(value: 'Exercise', child: Text('Exercise')),
        DropdownMenuItem(value: 'Play', child: Text('Play')),
      ];
    } else if (widget.title == 'Health') {
      return const [
        DropdownMenuItem(value: 'Vet Visit', child: Text('Vet Visit')),
        DropdownMenuItem(value: 'Medication', child: Text('Medication')),
        DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
        DropdownMenuItem(value: 'Weigh', child: Text('Weigh')),
      ];
    }

    return const [
      DropdownMenuItem(value: 'Feed', child: Text('Feed')),
      DropdownMenuItem(value: 'Water', child: Text('Water')),
      DropdownMenuItem(value: 'Exercise', child: Text('Exercise')),
      DropdownMenuItem(value: 'Vet Visit', child: Text('Vet Visit')),
    ];
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

  Widget _buildActivitySpecificFields(
      String? taskType, StateSetter setModalState) {
    if (taskType == null) return const SizedBox.shrink();

    if (['Feed', 'Water'].contains(taskType)) {
      return TextFormField(
        controller: _amountController,
        decoration: InputDecoration(
          labelText:
              taskType == 'Feed' ? 'Amount (cups/grams)' : 'Water Amount (ml)',
        ),
        keyboardType: TextInputType.number,
      );
    } else if (taskType == 'Walk' || taskType == 'Exercise') {
      return Column(
        children: [
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _distanceController,
            decoration:
                const InputDecoration(labelText: 'Distance (km, optional)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      );
    } else if (taskType == 'Weigh') {
      return TextFormField(
        controller: _amountController,
        decoration: const InputDecoration(labelText: 'Weight (kg)'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
    }

    return const SizedBox.shrink();
  }
}
