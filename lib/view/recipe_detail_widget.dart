import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';
import 'package:taste_hub/components/custom_arrowback.dart';
import 'package:taste_hub/components/favourite_button.dart';
import 'package:taste_hub/components/intruction_tile.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe; // Recipe data to display
  final FirebaseStorageService
      firebaseStorageService; // Service for Firebase storage operations
  final MongoDBService mongoDBService; // Service for MongoDB operations
  final bool isFavourite; // Indicates if the recipe is marked as a favorite

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.firebaseStorageService,
    required this.mongoDBService,
    required this.isFavourite,
  });

  @override
  RecipeDetailScreenState createState() => RecipeDetailScreenState();
}

class RecipeDetailScreenState extends State<RecipeDetailScreen> {
  User? user; // Firebase user object

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // Initialize Firebase user
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(), // Sliver app bar with recipe image and favorite button
            _buildSliverList(), // Sliver list containing recipe details
          ],
        ),
      ),
    );
  }

  // Builds the sliver app bar with recipe image and back button
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            _buildRecipeImage(), // Displays recipe image
            Align(
              alignment: Alignment.topLeft,
              child: CustomBackArrowButton(
                onBackButtonPressed: () => Navigator.of(context).pop(),
              ),
            ),
            _buildFavoriteButton(), // Favorite button to add/remove from favorites
          ],
        ),
      ),
    );
  }

  // Builds the recipe image widget with loading spinner
  FutureBuilder<String> _buildRecipeImage() {
    return FutureBuilder<String>(
      future: widget.firebaseStorageService
          .downloadRecipeImageURL(widget.recipe.image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return CachedNetworkImage(
            imageUrl: snapshot.data!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        } else {
          return SizedBox(
            height: 300,
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
          );
        }
      },
    );
  }

  // Builds the favorite button widget
  Align _buildFavoriteButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: FavoriteButton(
          isFavorite: widget.isFavourite,
          onFavoriteChanged: (isNowFavorite) {
            // Handles adding/removing recipe from user's favorites
            if (isNowFavorite) {
              widget.mongoDBService.addRecipeToFavorites(
                user?.email ?? '',
                widget.recipe.id
                    .toString()
                    .replaceAll('ObjectId("', '')
                    .replaceAll('")', ''),
              );
            } else {
              widget.mongoDBService.removeRecipeFromFavorites(
                user?.email ?? '',
                widget.recipe.id
                    .toString()
                    .replaceAll('ObjectId("', '')
                    .replaceAll('")', ''),
              );
            }
          },
        ),
      ),
    );
  }

  // Builds the sliver list containing recipe details
  SliverList _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeHeader(), // Recipe name, preparation time, and cost
                const SizedBox(height: 8),
                _buildCultureInfo(), // Recipe's cultural information
                const SizedBox(height: 16),
                _buildTabBar(), // Tab bar for switching between ingredients, instructions, and info
                _buildTabBarView(), // Tab bar view with ingredients, instructions, and info
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the header section with recipe name, preparation time, and cost
  Row _buildRecipeHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.recipe.preparationTime} min',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Cost: \$${widget.recipe.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Builds cultural information section of the recipe
  FutureBuilder<Map<String, dynamic>?> _buildCultureInfo() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.mongoDBService.getCultureById(widget.recipe.cultureId),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final cultureData = snapshot.data!;
          return Row(
            children: [
              const Icon(Icons.public, size: 20, color: Colors.grey),
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
          return Container(); // Placeholder while loading cultural information
        }
      },
    );
  }

  // Builds the tab bar for switching between ingredients, instructions, and info
  Widget _buildTabBar() {
    return const TabBar(
      labelColor: Colors.red,
      unselectedLabelColor: Colors.grey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.red, width: 4.0),
      ),
      tabs: [
        Tab(text: 'Ingredients'),
        Tab(text: 'Instructions'),
        Tab(text: 'Info'),
      ],
    );
  }

  // Builds the tab bar view with ingredients, instructions, and info sections
  Widget _buildTabBarView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: _calculateHeight(),
            child: TabBarView(
              children: [
                _buildIngredientsList(), // Ingredients list
                _buildInstructionsList(), // Instructions list
                _buildInfoSection(), // Info section with allergens, creator info, and creation date
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the list view of ingredients
  ListView _buildIngredientsList() {
    return ListView.builder(
      itemCount: widget.recipe.ingredients.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final ingredient = widget.recipe.ingredients[index];
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
    );
  }

  // Builds the list view of instructions
  ListView _buildInstructionsList() {
    return ListView.builder(
      itemCount: widget.recipe.instructions.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final instruction = widget.recipe.instructions[index];
        return InstructionTile(
          instruction: '${instruction.order}. ${instruction.step}',
          onChanged: (value) {},
        );
      },
    );
  }

  // Builds the info section with allergens, creator info, and creation date
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildAllergens(), // Allergens list
        const SizedBox(height: 20),
        _buildCreatorInfo(), // Creator information
        const SizedBox(height: 8),
        _buildCreationDate(), // Creation date of the
      ],
    );
  }

  // Builds the allergens section
  Column _buildAllergens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.recipe.allergens.join(", "),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Builds the creator information section
  Row _buildCreatorInfo() {
    return Row(
      children: [
        const Icon(
          Icons.person,
          color: Colors.purple,
        ),
        const SizedBox(width: 8),
        Text(
          'Creator: ${widget.recipe.creator}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Builds the creation date section
  Row _buildCreationDate() {
    return Row(
      children: [
        const Icon(
          Icons.date_range,
          color: Colors.teal,
        ),
        const SizedBox(width: 8),
        Text(
          'Creation Date: ${widget.recipe.creationDate}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Calculates the height of the tab bar view based on content
  double _calculateHeight() {
    double minHeight = 300;
    double height = ((widget.recipe.ingredients.length +
                widget.recipe.instructions.length) /
            2) *
        85;
    return height < minHeight ? minHeight : height;
  }
}
