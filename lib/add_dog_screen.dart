import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dog.dart';

class AddDogScreen extends StatefulWidget {
  const AddDogScreen({super.key});

  @override
  State<AddDogScreen> createState() => _AddDogScreenState();
}

class _AddDogScreenState extends State<AddDogScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final birthDateController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedHealth;

  Uint8List? _imageBytes;
  String? _imagePath;

  final List<String> genders = ['Male', 'Female'];
  final List<String> healthStatuses = ['Healthy', 'Sick', 'In Treatment'];

  @override
  void initState() {
    super.initState();

    weightController.addListener(() {
      final raw = weightController.text.replaceAll(RegExp(r'\D'), '');
      if (raw.isNotEmpty && !weightController.text.contains('kg')) {
        weightController.value = TextEditingValue(
          text: '$raw kg',
          selection: TextSelection.collapsed(offset: '$raw kg'.length),
        );
      }
    });

    ageController.addListener(() {
      final raw = ageController.text.replaceAll(RegExp(r'\D'), '');
      if (raw.isNotEmpty &&
          !(ageController.text.contains('yr') ||
              ageController.text.contains('yrs'))) {
        final suffix = raw == '1' ? 'yr' : 'yrs';
        ageController.value = TextEditingValue(
          text: '$raw $suffix',
          selection: TextSelection.collapsed(offset: '$raw $suffix'.length),
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
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      
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
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      birthDateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

void _submitDog() {
  if (_formKey.currentState!.validate()) {
    // Check if either imagePath or imageBytes is set
    if (_imagePath != null) {
      final rawWeight = weightController.text.replaceAll(RegExp(r'\D'), '');
      final rawAge = ageController.text.replaceAll(RegExp(r'\D'), '');
      final ageSuffix = rawAge == '1' ? 'yr' : 'yrs';

      final newDog = Dog(
        name: nameController.text,
        breed: breedController.text,
        gender: _selectedGender ?? '',
        imagePath: _imagePath!,
        imageBytes: _imageBytes, // Include the image bytes
        birthDate: birthDateController.text,
        weight: '$rawWeight kg',
        age: '$rawAge $ageSuffix',
        health: _selectedHealth ?? '',
      );

      Navigator.pop(context, newDog);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image.')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Dog"),
        backgroundColor: const Color(0xFFFA9B63),
        foregroundColor: Colors.white,
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

                  )),
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
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
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
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.replaceAll(RegExp(r'\D'), '').isEmpty
                        ? 'Required'
                        : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedHealth,
                decoration: const InputDecoration(labelText: 'Health Status'),
                items: healthStatuses
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHealth = value;
                  });
                },
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
                child: const Text("Add Dog"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
