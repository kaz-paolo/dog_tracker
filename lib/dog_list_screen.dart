import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DogListScreen(),
    ),
  );
}

class DogListScreen extends StatefulWidget {
  const DogListScreen({super.key});

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // List of all dogs
  final List<DogCard> allDogs = const [
    DogCard(
      name: 'Kkuma',
      breed: 'Maltese',
      gender: 'F',
      imagePath: 'assets/images/kkuma.png',
    ),
    DogCard(
      name: 'Latte',
      breed: 'Norwich Terrier',
      gender: 'M',
      imagePath: 'assets/images/latte.png',
    ),
    DogCard(
      name: 'Choco',
      breed: 'Shitzu',
      gender: 'F',
      imagePath: 'assets/images/choco.png',
    ),
    DogCard(
      name: 'Sophia',
      breed: 'Shitzu',
      gender: 'F',
      imagePath: 'assets/images/sophia.png',
    ),
  ];

  // Filtered Dog list based on search
  List<DogCard> filteredDogs = [];

  @override
  void initState() {
    super.initState();
    filteredDogs = allDogs;
    _searchController.addListener(_filterDogs);
  }

  void _filterDogs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDogs = allDogs.where((dog) {
        return dog.name.toLowerCase().contains(query);
      }).toList();
    });
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        currentIndex: 1,
        onTap: (index) {},
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),

      // Main Screen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                // Title
                child: Text(
                  'My Dogs',
                  style: GoogleFonts.poppins(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFA9B63),
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
                  color: Color(0xFFFFDCAA),
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

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                  children: filteredDogs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DogCard extends StatelessWidget {
  final String name;
  final String breed;
  final String gender;
  final String imagePath;

  const DogCard({
    super.key,
    required this.name,
    required this.breed,
    required this.gender,
    required this.imagePath,
  });

// Dogs
  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              children: [
                // Dog Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
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
                        gender,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    breed,
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
}
