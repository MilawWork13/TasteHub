import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taste_hub/components/custom_arrowback.dart';
import 'package:taste_hub/components/favourite_button.dart';
import 'package:taste_hub/components/intruction_tile.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final FirebaseStorageService firebaseStorageService;
  final MongoDBService mongoDBService;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.firebaseStorageService,
    required this.mongoDBService,
  });

  @override
  RecipeDetailScreenState createState() => RecipeDetailScreenState();
}

class RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    FutureBuilder<String>(
                      future: widget.firebaseStorageService
                          .downloadURL(widget.recipe.image),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data!),
                                fit: BoxFit.cover,
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
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomBackArrowButton(
                        onBackButtonPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: FavoriteButton(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and additional information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Recipe name
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                widget.recipe.name,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            // Preparation time and cost
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.recipe.preparationTime} min',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Cost: \$${widget.recipe.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<Map<String, dynamic>?>(
                          future: widget.mongoDBService
                              .getCultureById(widget.recipe.cultureId),
                          builder: (BuildContext context,
                              AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              final cultureData = snapshot.data!;
                              return Row(
                                children: [
                                  const Icon(Icons.public,
                                      size: 20, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${cultureData['name']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(); // Return an empty container if culture data is not available yet
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Tab Bar
                        const TabBar(
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Ingredients'),
                            Tab(text: 'Instructions'),
                            Tab(text: 'Info'),
                          ],
                        ),
                        // Tab Bar View
                        SingleChildScrollView(
                          child: SizedBox(
                            height: calculateHeight(),
                            child: TabBarView(
                              children: [
                                // Ingredients Tab
                                ListView.builder(
                                  itemCount: widget.recipe.ingredients.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final ingredient =
                                        widget.recipe.ingredients[index];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.add_outlined,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                        '${ingredient.name}: ${ingredient.quantity}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                                // Instructions Tab
                                ListView.builder(
                                  itemCount: widget.recipe.instructions.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final instruction =
                                        widget.recipe.instructions[index];
                                    return InstructionTile(
                                      instruction:
                                          '${instruction.order}. ${instruction.step}',
                                      onChanged: (value) {
                                        // Handle checkbox value change if needed
                                      },
                                    );
                                  },
                                ),
                                // Info Tab
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Allergens:',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  widget.recipe.allergens
                                                      .join(", "),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                color: Colors.purple,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Creator: ${widget.recipe.creator}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.date_range,
                                                color: Colors.teal,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Creation Date: ${widget.recipe.creationDate}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateHeight() {
    return ((widget.recipe.ingredients.length +
                widget.recipe.instructions.length) /
            2) *
        85;
  }
}
