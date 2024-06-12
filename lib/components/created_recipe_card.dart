import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taste_hub/components/delete_recipe_button.dart';
import 'package:taste_hub/components/modify_recipe_button.dart';
import 'package:taste_hub/controller/modify_recipe_controller.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/view/modify_recipe_widget.dart';

class CreatedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final FirebaseStorageService firebaseStorageService;
  final MongoDBService mongoDBService;
  final bool isFirstCard;
  final Function onRecipeDeleted;

  const CreatedRecipeCard({
    super.key,
    required this.recipe,
    required this.firebaseStorageService,
    required this.mongoDBService,
    this.isFirstCard = false,
    required this.onRecipeDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final ModifyRecipeController modiftyRecipeController =
        ModifyRecipeController(
      recipe: recipe,
      firebaseStorageService: firebaseStorageService,
      mongoDBService: mongoDBService,
    );
    User? user = FirebaseAuth.instance.currentUser;
    return FutureBuilder<String>(
      future: firebaseStorageService.downloadRecipeImageURL(recipe.image),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: isFirstCard ? 8.0 : 0,
            ),
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
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ModifyRecipeButton(
                            onModify: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifyRecipeScreen(
                                    recipe: recipe,
                                    controller: modiftyRecipeController,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: -8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DeleteRecipeButton(
                              onDelete: () async {
                                await mongoDBService.deleteRecipe(
                                  context,
                                  user?.email ?? '',
                                  recipe.id
                                      .toString()
                                      .replaceAll('ObjectId("', '')
                                      .replaceAll('")', ''),
                                  recipe.image,
                                );
                                onRecipeDeleted();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: isFirstCard ? 8.0 : 0,
            ),
            child: SizedBox(
              height: 300,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
