import 'dart:math';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/recipe_controller.dart';
import 'package:taste_hub/model/Culture.dart';

class RecipeCreationScreen extends StatefulWidget {
  const RecipeCreationScreen({super.key});

  @override
  RecipeCreationScreenState createState() => RecipeCreationScreenState();
}

class RecipeCreationScreenState extends State<RecipeCreationScreen> {
  // Instance of Firebase storage service
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService();

  // Controllers for the recipe creation screen
  final RecipeController _controller = RecipeController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<Map<String, TextEditingController>> _instructionControllers = [];
  final List<TextEditingController> _allergenControllers = [];
  String? _selectedImage; // Selected image name
  String? _selectedCulture; // Selected culture name
  File? _imagePath; // File object for selected image
  List<Culture> _cultures = []; // List of available cultures
  late User? _user; // Current logged-in user

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _controller.initialize();
    _cultures = _controller.cultures.value;
    if (_user != null) {
      await _controller.fetchFavoriteRecipes(_user!.email!);
      await _controller.fetchRecipesCreatedByUser(_user!.email!);
    }
    setState(() {}); // Update UI
  }

  Future<void> refreshData(String email) async {
    await _controller.fetchRecipesCreatedByUser(email);
    setState(() {}); // Ensure UI reflects the changes
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String randomString = _generateRandomString(6);
      String imageName = '${_nameController.text}_$randomString';
      _imagePath = File(pickedFile.path);

      setState(() {
        _selectedImage = imageName;
      });

      await _firebaseStorageService.uploadImage(_imagePath!, imageName);
    }
  }

  // Method to generate a random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Method to add an ingredient text field
  void _addIngredient() {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  // Method to add an instruction text field
  void _addInstruction() {
    setState(() {
      _instructionControllers.add({
        'step': TextEditingController(),
        'order': TextEditingController(),
      });
    });
  }

  // Method to add an allergen text field
  void _addAllergen() {
    setState(() {
      _allergenControllers.add(TextEditingController());
    });
  }

  // Method to remove an ingredient text field
  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
    });
  }

  // Method to remove an instruction text field
  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers.removeAt(index);
    });
  }

  // Method to remove an allergen text field
  void _removeAllergen(int index) {
    setState(() {
      _allergenControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            _buildImagePicker(), // Image picker UI
            const SizedBox(height: 20),
            _buildTextField(
                controller: _nameController,
                label: 'Recipe Name'), // Recipe name text field
            const SizedBox(height: 20),
            _buildIngredientsSection(), // Ingredients section UI
            const SizedBox(height: 20),
            _buildInstructionsSection(), // Instructions section UI
            const SizedBox(height: 20),
            _buildAllergensSection(), // Allergens section UI
            const SizedBox(height: 20),
            _buildCultureDropdown(), // Culture dropdown UI
            const SizedBox(height: 20),
            _buildTextField(
              controller: _prepTimeController,
              label: 'Preparation Time (minutes)',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ), // Preparation time text field
            const SizedBox(height: 20),
            _buildTextField(
              controller: _priceController,
              label: 'Price',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ), // Price text field
            const SizedBox(height: 20),
            _buildCreateButton(), // Create recipe button
          ],
        ),
      ),
    );
  }

  // Method to build the image picker widget
  Widget _buildImagePicker() {
    return GestureDetector(
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
    );
  }

  // Method to build the text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.red,
    );
  }

  // Method to build the ingredients section
  Widget _buildIngredientsSection() {
    return Column(
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
                  child: _buildTextField(
                    controller: controllers['name']!,
                    label: 'Name',
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: _buildTextField(
                    controller: controllers['quantity']!,
                    label: 'Quantity',
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
    );
  }

  // Method to build the instructions section
  Widget _buildInstructionsSection() {
    return Column(
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
                  child: _buildTextField(
                    controller: controllers['step']!,
                    label: 'Step',
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 60,
                  child: _buildTextField(
                    controller: controllers['order']!,
                    label: 'Order',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
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
    );
  }

  // Method to build the allergens section
  Widget _buildAllergensSection() {
    return Column(
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
                  child: _buildTextField(
                    controller: controller,
                    label: 'Allergen',
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
    );
  }

  // Method to build the culture dropdown
  Widget _buildCultureDropdown() {
    return DropdownButtonFormField<String>(
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
        return DropdownMenuItem<String>(
          value: culture.name,
          child: Text(
            culture.name,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      dropdownColor: Colors.grey[200],
    );
  }

  // Method to build the create recipe button
  Widget _buildCreateButton() {
    User? user = FirebaseAuth.instance.currentUser;
    return ElevatedButton(
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
        await refreshData(user?.email ?? '');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
      ),
      child: const Text(
        'Create Recipe',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
