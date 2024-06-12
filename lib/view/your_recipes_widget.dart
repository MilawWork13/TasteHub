import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/components/cool_search_bar.dart';
import 'package:taste_hub/components/created_recipe_card.dart';
import 'package:taste_hub/components/recipe_card.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/recipe_controller.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/view/create_your_recipe_widget.dart';
import 'package:taste_hub/view/recipe_detail_widget.dart';

class FavoriteRecipesPage extends StatefulWidget {
  const FavoriteRecipesPage({super.key});

  @override
  FavoriteRecipesPageState createState() => FavoriteRecipesPageState();
}

class FavoriteRecipesPageState extends State<FavoriteRecipesPage> {
  final RecipeController _controller = RecipeController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // Method to initialize the page with required data
  Future<void> _initializePage() async {
    await _controller.initialize();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _controller.fetchFavoriteRecipes(user.email!);
      await _controller.fetchRecipesCreatedByUser(user.email!);
    }
  }

  // Method to refresh data displayed on the page
  Future<void> _refreshData(String email) async {
    await _controller.fetchFavoriteRecipes(email);
    await _controller.fetchRecipesCreatedByUser(email);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              'Your Recipes',
              style: TextStyle(
                fontSize: 32,
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section for the introductory text
            const Padding(
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Here are gathered your favorite and created recipes, let the creation begin!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            // TabBar for switching between 'Your Favourites' and 'Created by You'
            const TabBar(
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.red, width: 3),
              ),
              tabs: [
                Tab(text: 'Your Favourites'),
                Tab(text: 'Created by You'),
              ],
            ),
            // Expanded section to display content based on selected tab
            Expanded(
              child: TabBarView(
                children: [
                  _buildFavoritesTab(), // Tab view for 'Your Favourites'
                  _buildCreatedByYouTab(), // Tab view for 'Created by You'
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for displaying 'Your Favourites' tab content
  Widget _buildFavoritesTab() {
    User? user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        // Search bar widget for searching favourite recipes
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: SearchBarNiceWidget(
            onSearch: (query) {
              _controller.searchFavouriteRecipes(query);
            },
          ),
        ),
        // Expanded section for displaying the list of favourite recipes
        Expanded(
          child: RefreshIndicator(
            key: GlobalKey<RefreshIndicatorState>(),
            onRefresh: () => _refreshData(user?.email ?? ''),
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isSearching,
              builder: (context, isSearching, _) {
                return ValueListenableBuilder<List<Recipe>>(
                  valueListenable: isSearching
                      ? _controller.searchedFavouriteRecipes
                      : _controller.favouriteRecipes,
                  builder: (context, recipes, _) {
                    if (recipes.isEmpty) {
                      // Display message when no favourite recipes are found
                      return ListView(
                        children: const [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 200),
                              child: Text(
                                'No favorite recipes found. Try refreshing!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Display list of favourite recipes
                      return ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          bool isFavourite = _controller.favouriteRecipes.value
                              .contains(recipes[index]);
                          return GestureDetector(
                            onTap: () {
                              // Navigate to recipe detail screen when tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    recipe: recipes[index],
                                    firebaseStorageService:
                                        FirebaseStorageService(),
                                    mongoDBService: _controller.mongoDBService,
                                    isFavourite: isFavourite,
                                  ),
                                ),
                              );
                            },
                            child: RecipeCard(
                              recipe: recipes[index],
                              firebaseStorageService: FirebaseStorageService(),
                              mongoDBService: _controller.mongoDBService,
                              isFirstCard: index == 0,
                              isFavourite: isFavourite,
                              onFavoriteChanged: () =>
                                  _refreshData(user?.email ?? ''),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget for displaying 'Created by You' tab content
  Widget _buildCreatedByYouTab() {
    User? user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        // Search bar widget for searching recipes created by user
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: SearchBarNiceWidget(
            onSearch: (query) {
              _controller.searchCreatedRecipes(query, user?.email ?? '');
            },
          ),
        ),
        // Expanded section for displaying the list of recipes created by user
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                key: GlobalKey<RefreshIndicatorState>(),
                onRefresh: () => _refreshData(user?.email ?? ''),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _controller.isSearching,
                  builder: (context, isSearching, _) {
                    return ValueListenableBuilder<List<Recipe>>(
                      valueListenable: isSearching
                          ? _controller.searchedCreatedByUserRecipes
                          : _controller.createdByUserRecipes,
                      builder: (context, recipes, _) {
                        if (recipes.isEmpty) {
                          // Display message when no recipes created by user are found
                          return ListView(
                            children: const [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 200),
                                  child: Text(
                                    'No recipes created by you found. Try refreshing!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Display list of recipes created by user
                          return ListView.builder(
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              bool isFavourite = _controller
                                  .favouriteRecipes.value
                                  .contains(recipes[index]);
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to recipe detail screen when tapped
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(
                                        recipe: recipes[index],
                                        firebaseStorageService:
                                            FirebaseStorageService(),
                                        mongoDBService:
                                            _controller.mongoDBService,
                                        isFavourite: isFavourite,
                                      ),
                                    ),
                                  );
                                },
                                child: CreatedRecipeCard(
                                  recipe: recipes[index],
                                  firebaseStorageService:
                                      FirebaseStorageService(),
                                  mongoDBService: _controller.mongoDBService,
                                  isFirstCard: index == 0,
                                  onRecipeDeleted: () =>
                                      _refreshData(user?.email ?? ''),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              // Positioned button for creating a new recipe
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to screen for creating a new recipe
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipeCreationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(167, 244, 67, 54),
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Create new recipe',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
