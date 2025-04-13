import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dog.dart';

class DogProfileScreen extends StatelessWidget {
  final Dog dog;

  const DogProfileScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      const Text(
                        'Pet Profile',
                        style: TextStyle(
                          color: Color(0xFFFA9B63),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.orange.shade100,
                  child: ClipOval(
                    child: _buildDogImage(dog),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  dog.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE8E66),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(Icons.cake, dog.birthDate),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.pets, dog.breed),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.monitor_weight, dog.weight),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(Icons.access_time, dog.age),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.favorite, dog.health),
                    const SizedBox(width: 32),
                    _buildInfoItem(Icons.female, dog.gender),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        currentIndex: 1,
        onTap: (index) {
          // logic later
        },
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Dogs'),
          BottomNavigationBarItem(
              icon: Icon(Icons.article), label: 'Activities'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Icon(icon, color: Color(0xFFFA9B63), size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 14),
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
    // web
    return const Icon(
      Icons.image,
      color: Colors.grey,
      size: 50,
    );
  } else {
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
