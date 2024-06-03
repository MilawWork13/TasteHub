import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taste_hub/components/favourite_button.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final FirebaseStorageService firebaseStorageService;
  final MongoDBService mongoDBService;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.firebaseStorageService,
    required this.mongoDBService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: firebaseStorageService.downloadURL(recipe.image),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          // If image URL is available, display the image
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 2.0), // Add vertical padding
            child: SizedBox(
              height: 300, // Adjust the height of the card as needed
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  // Clip the image with rounded corners
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(0, 0, 0, 0),
                              Color.fromARGB(151, 0, 0, 0)
                            ],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Text overlay
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder<Map<String, dynamic>?>(
                              future: mongoDBService
                                  .getCultureById(recipe.cultureId),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Map<String, dynamic>?>
                                      snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  final cultureData = snapshot.data!;
                                  return Text(
                                    '${cultureData['name']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                    ),
                                  );
                                } else {
                                  return Container(); // Return an empty container if culture data is not available yet
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      // Heart icon
                      Positioned(
                        top: 12,
                        right: -8,
                        child: InkWell(
                          onTap: () {
                            // Add your onPressed function here
                          },
                          child: const FavoriteButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Placeholder or loading animation while image is being fetched
          return const SizedBox(
            height: 300,
            child: Center(
              child: SpinKitFadingCircle(
                // Use any animation from flutter_spinkit package
                color: Color.fromARGB(
                    255, 255, 71, 71), // Customize the color if needed
                size: 50.0, // Adjust the size of the animation
              ),
            ),
          );
        }
      },
    );
  }
}
