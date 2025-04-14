import 'package:dog_tracker/dog_list_screen.dart';
import 'package:dog_tracker/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Text Styles
  final TextStyle titleTextStyle = GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFFA9B63),
  );

  final TextStyle descTextStyle = GoogleFonts.poppins(
    fontSize: 20,
    color: const Color(0xFFFA9B63),
  );

// Content data
  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome Purparent!',
      'desc':
          'Your dog’s health and happiness in one paw-some app.\nTrack feeding, walks, water, and more — all in one place!',
      'image': 'assets/images/logo.png',
    },
    {
      'title': 'Never Miss a Woof Moment!',
      'desc':
          'Set reminders for meals, water breaks, and vet visits.\nWoofWatch keeps your routine in check so your pup stays happy!',
      'image': 'assets/images/logo.png',
    },
    {
      'title': 'Create Paw-some Profiles',
      'desc':
          'Add your dogs, log their health milestones,\nand keep a cute timeline of their journey.',
      'image': 'assets/images/logo.png',
    },
    {
      'title': 'Start Tracking with WoofWatch',
      'desc': '',
      'image': 'assets/images/name.png',
    },
  ];

  // Moves to the next onboarding page
  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

      // Nnavigates to DogListScreen if it's the last page.
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DogListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  // Skips all pages and navigates directly to dog list screen
  void _skip() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DogListScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // layout for each onboarding page
  Widget _buildPage(Map<String, String> data, bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // onboarding image
          if ((data['image'] ?? '').isNotEmpty)
            Image.asset(data['image']!, height: 250),
          const SizedBox(height: 20),

          // onboarding text
          Text(
            data['title'] ?? '',
            style: titleTextStyle,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),

          // onboarding desc
          Text(
            data['desc'] ?? '',
            style: descTextStyle,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),

          // onboarding last page
          if (isLastPage)
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFA9B63),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '+ Add Your First Dog',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            )
        ],
      ),
    );
  }

  // Dots for showing page
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // list of widgets/dots per onboarding page
      children: List.generate(onboardingData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,

          // highlight current page
          width: _currentPage == index ? 24 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFFFA9B63)
                : const Color(0xFFFA9B63).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return _buildPage(
                    onboardingData[index], index == onboardingData.length - 1);
              },
            ),
          ),
          _buildDots(),
          const SizedBox(height: 20),

          // if not last page, show skip and next buttons
          if (_currentPage != onboardingData.length - 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // First Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _skip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA9B63),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Oval shape
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white), // White text
                    ),
                  ),
                ),

                // Second Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: _nextPage,
                    style: TextButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFDCAA), // Background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Oval shape
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFA9B63), // Text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
