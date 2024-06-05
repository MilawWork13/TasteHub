import 'package:flutter/material.dart';
import 'package:taste_hub/components/cool_search_bar.dart';
import 'package:taste_hub/components/culture_card.dart';
import 'package:taste_hub/components/recipe_card.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/suggested_page_controller.dart';
import 'package:taste_hub/model/Culture.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/view/recipe_detail_widget.dart';

class SuggestedPage extends StatefulWidget {
  const SuggestedPage({super.key});

  @override
  SuggestedPageState createState() => SuggestedPageState();
}

class SuggestedPageState extends State<SuggestedPage> {
  final SuggestedPageController _controller = SuggestedPageController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refreshPage();
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 48, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested recipes',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 44,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Try new meals everyday! Best options based on your preference.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SearchBarNiceWidget(
                  onSearch: (query) {
                    _controller.searchRecipes(query);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 95,
                child: ValueListenableBuilder<List<Culture>>(
                  valueListenable: _controller.cultures,
                  builder: (context, cultures, _) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cultures.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            String cultureId = cultures[index].id.toString();
                            cultureId = cultureId
                                .replaceAll('ObjectId("', '')
                                .replaceAll('")', '');
                            await _controller.showRecipesByCulture(cultureId);
                          },
                          child: CultureCard(
                            culture: cultures[index],
                            firebaseStorageService: FirebaseStorageService(),
                            mongoDBService: _controller.mongoDBService,
                            isFirstCard: index == 0,
                            isLastCard: index == cultures.length - 1,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isSearching,
              builder: (context, isSearching, _) {
                return ValueListenableBuilder<List<Recipe>>(
                  valueListenable: isSearching
                      ? _controller.searchedRecipes
                      : _controller.suggestedRecipes,
                  builder: (context, recipesToDisplay, _) {
                    if (recipesToDisplay.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 120),
                            child: Text(
                              'No recipes were found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    recipe: recipesToDisplay[index],
                                    firebaseStorageService:
                                        FirebaseStorageService(),
                                    mongoDBService: _controller.mongoDBService,
                                  ),
                                ),
                              );
                            },
                            child: RecipeCard(
                              recipe: recipesToDisplay[index],
                              firebaseStorageService: FirebaseStorageService(),
                              mongoDBService: _controller.mongoDBService,
                              isFirstCard: index == 0,
                            ),
                          );
                        },
                        childCount: recipesToDisplay.length,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
