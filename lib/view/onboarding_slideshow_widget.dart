import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:taste_hub/components/custom_appbar.dart';
import 'package:taste_hub/components/on_boarding_slide.dart';

class OnboardingSlideshowWidget extends StatefulWidget {
  const OnboardingSlideshowWidget({super.key});

  @override
  State<OnboardingSlideshowWidget> createState() =>
      _OnboardingSlideshowWidgetState();
}

class _OnboardingSlideshowWidgetState extends State<OnboardingSlideshowWidget> {
  // Page controller for managing slide pages
  final PageController _pageController = PageController();

  // Current page index of the slideshow
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing on keyboard appearance
      appBar: CustomBackArrow(
        // Custom app bar with back button
        title: '', // Empty title
        backButton: true,
        onBackButtonPressed: () {
          Navigator.pop(context); // Navigate back when back button is pressed
        },
      ),
      body: LayoutBuilder(
        // Builds the layout based on constraints
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final maxWidth = constraints.maxWidth;
          final paddingHorizontal = maxWidth * 0.1; // Horizontal padding
          final paddingVertical = maxHeight * 0.12; // Vertical padding

          return Stack(
            children: [
              PageView(
                controller: _pageController, // Manages pages and scrolling
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page; // Update current page index
                  });
                },
                children: [
                  // First Onboarding Slide
                  OnboardingSlide(
                    title: 'Create your own recipes',
                    imageUrl: 'assets/Customers_Enjoy_Food.png',
                    description:
                        'Use our tools to add audios, photos and notes to your recipe',
                    paddingHorizontal: paddingHorizontal,
                    paddingVertical: paddingVertical,
                  ),
                  // Second Onboarding Slide
                  OnboardingSlide(
                    title: 'Learn cultural recipes from all around the globe',
                    imageUrl: 'assets/Chef_Cooking.png',
                    description:
                        'Enjoy any recipes you find delicious, sort them by the culture, cost and time to prepare',
                    paddingHorizontal: paddingHorizontal,
                    paddingVertical: paddingVertical,
                  ),
                  // Third Onboarding Slide
                  OnboardingSlide(
                    title: 'Make it easier with AI',
                    imageUrl: 'assets/Food1.png',
                    description:
                        'Our AI Assistant "Tasteful" will always answer to any of your culinary questions',
                    paddingHorizontal: paddingHorizontal,
                    paddingVertical: paddingVertical,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        // Move to the next slide
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        // Navigate to sign-in screen after onboarding
                        Navigator.of(context).pushNamed('/sign_in');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 228, 15, 0),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage < 2 ? 'Continue' : 'Finish Onboarding',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 150),
                  child: smooth_page_indicator.SmoothPageIndicator(
                    controller:
                        _pageController, // Indicator linked to page controller
                    count: 3, // Total number of slides
                    effect: const smooth_page_indicator.ExpandingDotsEffect(
                      activeDotColor: Color.fromARGB(255, 0, 0, 0),
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
