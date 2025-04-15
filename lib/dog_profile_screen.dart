import 'dart:io';
import 'package:dog_tracker/custom_navbar.dart';
import 'package:dog_tracker/edit_dog_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dog.dart';

class DogProfileScreen extends StatefulWidget {
  final Dog dog;
  final Function(Dog) onEdit;
  final Function(Dog) onDelete;

  const DogProfileScreen({
    super.key,
    required this.dog,
    required this.onEdit,
    required this.onDelete,
  });

  _DogProfileScreenState createState() => _DogProfileScreenState();
}

class _DogProfileScreenState extends State<DogProfileScreen> {
  late Dog currentDog;

  @override
  void initState() {
    super.initState();
    currentDog = widget.dog; // Set initial dog value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'edit',
            backgroundColor: const Color(0xFFFA9B63),
            onPressed: () async {
              final updatedDog = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDogScreen(
                    initialDog: currentDog,
                    onSave: (updatedDog) {
                      setState(() {
                        currentDog = updatedDog;
                      });
                    },
                  ),
                ),
              );
              if (updatedDog != null) {
                widget.onEdit(updatedDog);
              }
            },
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'delete',
            backgroundColor: Colors.red,
            onPressed: () {
              _showDeleteConfirmation(context);
            },
            child: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),

                  // go back to dog list screen
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFFFA9B63)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),

                      // Title
                      const Center(
                        child: Text(
                          'Pet Profile',
                          style: TextStyle(
                            color: Color(0xFFFA9B63),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.orange.shade100,
                  child: ClipOval(
                    child: _buildDogImage(currentDog),
                  ),
                ),
                const SizedBox(height: 16),

                // Dog's name
                Text(
                  currentDog.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE8E66),
                  ),
                ),
                const SizedBox(height: 24),

                // Dog's info 1st row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(Icons.cake, currentDog.birthDate),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.pets, currentDog.breed),
                    const SizedBox(width: 32),
                    _buildInfoItem(
                        Icons.monitor_weight, '${currentDog.weight} kg'),
                  ],
                ),
                const SizedBox(height: 20),

                // Dog's info 2nd row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(Icons.access_time, currentDog.age),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.favorite, currentDog.health),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.female, currentDog.gender),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  // Info with icons
  Widget _buildInfoItem(IconData icon, String value) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xFFFA9B63), size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dog'),
        content: const Text('Are you sure you want to delete this dog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(currentDog);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from profile
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// make the image depding on web/mobile
Widget _buildDogImage(Dog dog) {
  if (dog.imagePath.isEmpty) {
    return const Icon(
      Icons.pets,
      color: Colors.grey,
      size: 80,
    );
  }

  if (dog.imagePath.startsWith('web_image_') && dog.imageBytes != null) {
    // If the image is from the web and has bytes, show the image using memory
    return Image.memory(
      dog.imageBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        );
      },
    );
  }

  if (kIsWeb) {
    // If running on web and image isn't in memory format, fallback to icon
    // web
    return const Icon(
      Icons.image,
      color: Colors.grey,
      size: 50,
    );
  } else {
    // If running on mobile, load image from local file

    // mobile
    return Image.file(
      File(dog.imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        );
      },
    );
  }
}
