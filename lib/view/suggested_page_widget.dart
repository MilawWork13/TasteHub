import 'package:flutter/material.dart';
import 'package:taste_hub/components/cool_search_bar.dart';
import 'package:taste_hub/components/recipe_card.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/suggested_page_controller.dart';
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
    setState(() {}); // Refresh the UI after initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refreshPage();
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 40, 16, 16),
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
                    setState(() {
                      _controller.searchRecipes(query);
                    });
                  },
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isSearching,
              builder: (context, isSearching, _) {
                final recipesToDisplay = isSearching
                    ? _controller.searchedRecipes
                    : _controller.suggestedRecipes;

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
                        ),
                      );
                    },
                    childCount: recipesToDisplay.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
