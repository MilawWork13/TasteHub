import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'dart:io';

import 'package:taste_hub/controller/suggested_page_controller.dart';

class RecipeCreationScreen extends StatefulWidget {
  @override
  RecipeCreationScreenState createState() => RecipeCreationScreenState();
}

class RecipeCreationScreenState extends State<RecipeCreationScreen> {
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService();
  final SuggestedPageController _controller = SuggestedPageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _prepTimeController =
      TextEditingController(); // Controller for preparation time
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<Map<String, TextEditingController>> _instructionControllers = [];
  final List<TextEditingController> _allergenControllers = [];
  String? _selectedImage;
  String? _selectedCulture;
  File? _imagePath;
  final List<String> _cultures = [
    "Japanese Cuisine",
    "Indian Cuisine",
    "Italian Cuisine",
    "Russian Cuisine",
    "Spanish Cuisine"
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _controller.initialize();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _controller.fetchFavoriteRecipes(user.email!);
      await _controller.fetchRecipesCreatedByUser(user.email!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Generate a random string of 6 characters
      String randomString = generateRandomString(6);

      // Combine recipe name and random string to create the image name
      String imageName = '${_nameController.text}_$randomString';

      _imagePath = File(pickedFile.path);

      setState(() {
        _selectedImage = imageName;
      });

      // Upload the image using the generated image name
      await _firebaseStorageService.uploadImage(_imagePath!, imageName);
    }
  }

  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add({
        'step': TextEditingController(),
        'order': TextEditingController(),
      });
    });
  }

  void _addAllergen() {
    setState(() {
      _allergenControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers.removeAt(index);
    });
  }

  void _removeAllergen(int index) {
    setState(() {
      _allergenControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 16, 16),
          child: Text(
            'Create New Recipe',
            style: TextStyle(
              fontSize: 26,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                  image: _imagePath != null
                      ? DecorationImage(
                          image: FileImage(_imagePath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Center(child: Text('Tap to select image'))
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.red,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ..._ingredientControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, TextEditingController> controllers = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers['name'],
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: controllers['quantity'],
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.red,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _removeIngredient(index),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add, color: Colors.red),
                    label: const Text(
                      'Add Ingredient',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ..._instructionControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, TextEditingController> controllers = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers['step'],
                            decoration: const InputDecoration(
                              labelText: 'Step',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: controllers['order'],
                            decoration: const InputDecoration(
                              labelText: 'Order',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.red,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _removeInstruction(index),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addInstruction,
                    icon: const Icon(Icons.add, color: Colors.red),
                    label: const Text(
                      'Add Instruction',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Allergens',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ..._allergenControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Allergen',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.red,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _removeAllergen(index),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addAllergen,
                    icon: const Icon(Icons.add, color: Colors.red),
                    label: const Text(
                      'Add Allergen',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCulture,
              onChanged: (value) {
                setState(() {
                  _selectedCulture = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Culture',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              items: _cultures.map((culture) {
                return DropdownMenuItem(
                  value: culture,
                  child: Text(
                    culture,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              dropdownColor: Colors.grey[200],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _prepTimeController,
              decoration: const InputDecoration(
                labelText: 'Preparation Time (minutes)',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.red,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.red,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _controller.createRecipe(
                  context,
                  _nameController,
                  _priceController,
                  _prepTimeController,
                  _ingredientControllers,
                  _instructionControllers,
                  _allergenControllers,
                  _selectedImage,
                  _selectedCulture,
                );
                await _controller.fetchRecipesCreatedByUser(user?.email ?? '');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: const Text(
                'Create Recipe',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
