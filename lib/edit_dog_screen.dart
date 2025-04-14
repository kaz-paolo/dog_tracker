import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dog.dart';

class EditDogScreen extends StatefulWidget {
  final Dog initialDog;
  final Function(Dog) onSave;

  const EditDogScreen({
    super.key,
    required this.initialDog,
    required this.onSave,
  });

  @override
  State<EditDogScreen> createState() => _EditDogScreenState();
}

class _EditDogScreenState extends State<EditDogScreen> {
  final _formKey = GlobalKey<FormState>();

  String _calculateAge(String birthDate) {
    final birthDateTime = DateTime.parse(birthDate);
    final currentDate = DateTime.now();
    final ageInDays = currentDate.difference(birthDateTime).inDays;
    final ageInYears = (ageInDays / 365).floor();
    return '$ageInYears ${ageInYears == 1 ? 'yr' : 'yrs'}';
  }

  late TextEditingController nameController;
  late TextEditingController breedController;
  late TextEditingController birthDateController;
  late TextEditingController weightController;
  late TextEditingController ageController;

  String? _selectedGender;
  String? _selectedHealth;

  Uint8List? _imageBytes;
  String? _imagePath;

  final List<String> genders = ['Male', 'Female'];
  final List<String> healthStatuses = ['Healthy', 'Sick', 'In Treatment'];

  @override
  void initState() {
    super.initState();
    final dog = widget.initialDog;

    nameController = TextEditingController(text: dog.name);
    breedController = TextEditingController(text: dog.breed);
    birthDateController = TextEditingController(text: dog.birthDate);
    weightController = TextEditingController(text: dog.weight);
    ageController = TextEditingController(text: _calculateAge(dog.birthDate));
    _selectedGender = dog.gender;
    _selectedHealth = dog.health;
    _imageBytes = dog.imageBytes;
    _imagePath = dog.imagePath;

    weightController.addListener(() {
      final raw = weightController.text.replaceAll(RegExp(r'\D'), '');
      if (raw.isNotEmpty && !weightController.text.contains('kg')) {
        weightController.value = TextEditingValue(
          text: '$raw kg',
          selection: TextSelection.collapsed(offset: '$raw kg'.length),
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final fileName =
            DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

        setState(() {
          _imageBytes = bytes;
          _imagePath = kIsWeb ? 'web_image_$fileName' : pickedFile.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFA9B63),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Update the birthdate text field
      birthDateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      // Update the age based on the selected birthdate
      setState(() {
        ageController.text = _calculateAge(birthDateController.text);
      });
    }
  }

  void _submitDog() {
    if (_formKey.currentState!.validate()) {
      final rawWeight = weightController.text.replaceAll(RegExp(r'\D'), '');
      final rawAge = ageController.text.replaceAll(RegExp(r'\D'), '');
      final ageSuffix = rawAge == '1' ? 'yr' : 'yrs';

      final updatedDog = widget.initialDog.copyWith(
        name: nameController.text,
        breed: breedController.text,
        gender: _selectedGender,
        imagePath: _imagePath ?? widget.initialDog.imagePath,
        imageBytes: _imageBytes ?? widget.initialDog.imageBytes,
        birthDate: birthDateController.text,
        weight: '$rawWeight kg',
        age: '$rawAge $ageSuffix',
        health: _selectedHealth,
      );

      widget.onSave(updatedDog);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Dog"),
        backgroundColor: const Color(0xFFFA9B63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitDog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFFFDCAA),
                  child: ClipOval(
                    child: _imageBytes != null
                        ? Image.memory(
                            _imageBytes!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : (_imagePath != null
                            ? Image.file(
                                File(_imagePath!),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Color(0xFFFA9B63),
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              TextFormField(
                controller: birthDateController,
                readOnly: true,
                onTap: _pickBirthDate,
                decoration: const InputDecoration(labelText: 'Birth Date'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.replaceAll(RegExp(r'\D'), '').isEmpty
                        ? 'Required'
                        : null,
              ),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age (years)'),
                readOnly: true, // Make it read-only
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedHealth,
                decoration: const InputDecoration(labelText: 'Health Status'),
                items: healthStatuses
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedHealth = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA9B63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitDog,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
