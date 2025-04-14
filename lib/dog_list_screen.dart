import 'dart:io';
import 'package:dog_tracker/custom_navbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dog.dart';
import 'dog_list_manager.dart';
import 'add_dog_screen.dart';
import 'dog_profile_screen.dart';

class DogListScreen extends StatefulWidget {
  const DogListScreen({super.key});

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  final TextEditingController _searchController =
      TextEditingController(); // COntrols input from search
  List<Dog> allDogs = [];
  List<Dog> filteredDogs = [];

  @override
  void initState() {
    super.initState();
    _loadDogs();
    _searchController.addListener(_filterDogs); // filter typed
  }

  // Load dog data
  Future<void> _loadDogs() async {
    final loadedDogs = await DogListManager.loadDogList(); //fetch dogs
    setState(() {
      allDogs = loadedDogs;
      filteredDogs = List.from(allDogs);
    });
  }

  // Save dog data to local storage
  Future<void> _saveDogs() async {
    await DogListManager.saveDogList(allDogs);
  }

  // Search filtering
  void _filterDogs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDogs = allDogs
          .where((dog) => dog.name.toLowerCase().contains(query))
          .toList(); // filters alldogs by checking if it contains the search query
    });
  }

  // Open add dog screen
  Future<void> _goToAddDogScreen() async {
    final newDog = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDogScreen()),
    );

    if (newDog != null && newDog is Dog) {
      // if user adds a new dog
      setState(() {
        allDogs.add(newDog);
        _filterDogs();
      });
      await _saveDogs();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nav Bar
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),

      // Main Screen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                // Title and search bar
                child: Text(
                  'My Dogs',
                  style: GoogleFonts.poppins(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFA9B63),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDCAA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Dog Name',
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(bottom: 3),
                        ),
                      ),
                    ),
                    const Icon(Icons.search, color: Color(0xFFFA9B63)),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Grid view of dogs
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,

                  // Go to Dog's Profile when tapped
                  children: filteredDogs.map((dog) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DogProfileScreen(dog: dog),
                          ),
                        );
                      },
                      child: DogCard(dog: dog),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // Add dog button
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddDogScreen,
        backgroundColor: const Color(0xFFFFDCAA),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Display dog info
class DogCard extends StatelessWidget {
  final Dog dog;

  const DogCard({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    // Rounded card container
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: const Color(0xFFFFDCAA),
                child: _buildDogImage(dog),
              ),
            ),
          ),

          // Dog's info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dog.name,
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFBE8E66),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDCAA),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Text(
                        dog.gender,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dog.breed,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // make the image depending on web/mobile
  Widget _buildDogImage(Dog dog) {
    if (dog.imagePath.isEmpty) {
      return const Icon(
        // default icon if no image
        Icons.pets,
        color: Colors.grey,
        size: 50,
      );
    }

    // show image from bytes if web image
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
      // On web: show a placeholder icon since local file access isn't supported
      // web
      return const Icon(
        Icons.image,
        color: Colors.grey,
        size: 50,
      );
    } else {
      // On mobile: load image from local file system
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
}
