import 'package:cached_network_image/cached_network_image.dart';
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
  final bool isFirstCard;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.firebaseStorageService,
    required this.mongoDBService,
    this.isFirstCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: firebaseStorageService.downloadRecipeImageURL(recipe.image),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(
                left: 16.0, right: 16.0, top: isFirstCard ? 8.0 : 0),
            child: SizedBox(
              height: 300,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        fit: BoxFit.cover,
                      ),
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
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                recipe.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
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
                                  return Container();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
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
          return const SizedBox(
            height: 300,
            child: Center(
              child: SpinKitFadingCircle(
                color: Color.fromARGB(255, 255, 71, 71),
                size: 50.0,
              ),
            ),
          );
        }
      },
    );
  }
}
