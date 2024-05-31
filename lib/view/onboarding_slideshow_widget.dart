import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:taste_hub/components/custom_back_arrow.dart';
import 'package:taste_hub/components/on_boarding_slide.dart';

class OnboardingSlideshowWidget extends StatefulWidget {
  const OnboardingSlideshowWidget({super.key});

  @override
  State<OnboardingSlideshowWidget> createState() =>
      _OnboardingSlideshowWidgetState();
}

class _OnboardingSlideshowWidgetState extends State<OnboardingSlideshowWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomBackArrow(
        title: '',
        backButton: true,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final maxWidth = constraints.maxWidth;
          final paddingHorizontal = maxWidth * 0.1;
          final paddingVertical = maxHeight * 0.12;

          return Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // First Onboarding Slide
                  OnboardingSlide(
                    title: 'Create your own recipes',
                    imageUrl: 'lib/resources/img/Customers_Enjoy_Food.png',
                    description:
                        'Use our tools to add audios, photos and notes to your recipe',
                    paddingHorizontal: paddingHorizontal,
                    paddingVertical: paddingVertical,
                  ),
                  // Second Onboarding Slide
                  OnboardingSlide(
                    title: 'Learn cultural recipes from all around the globe',
                    imageUrl: 'lib/resources/img/Chef_Cooking.png',
                    description:
                        'Enjoy any recipes you find delicious, sort them by the culture, cost and time to prepare',
                    paddingHorizontal: paddingHorizontal,
                    paddingVertical: paddingVertical,
                  ),
                  // Third Onboarding Slide
                  OnboardingSlide(
                    title: 'Make it easier with AI',
                    imageUrl: 'lib/resources/img/Food1.png',
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
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
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
                    controller: _pageController,
                    count: 3,
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
