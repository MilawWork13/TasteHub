import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taste_hub/controller/modify_recipe_controller.dart';
import 'package:taste_hub/model/Recipe.dart';

class ModifyRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  final ModifyRecipeController controller;

  const ModifyRecipeScreen({
    super.key,
    required this.recipe,
    required this.controller,
  });

  @override
  ModifyRecipeScreenState createState() => ModifyRecipeScreenState();
}

class ModifyRecipeScreenState extends State<ModifyRecipeScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _ingredientControllers = <Map<String, TextEditingController>>[];
  final _instructionControllers = <Map<String, TextEditingController>>[];
  final _allergenControllers = <TextEditingController>[];
  String? _selectedImage;
  String? _selectedImageName;
  String? _selectedCultureName;
  File? _imagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
    _loadRecipeData();
  }

  Future<void> _initializePage() async {
    await widget.controller.initializePage();
    setState(() {
      _isLoading = false;
    });
  }

  // Load the recipe data into the text fields
  void _loadRecipeData() async {
    _nameController.text = widget.recipe.name;
    _priceController.text = widget.recipe.price.toString();
    _prepTimeController.text = widget.recipe.preparationTime.toString();

    var cultureData = await widget.controller.mongoDBService
        .getCultureById(widget.recipe.cultureId);
    _selectedCultureName =
        (cultureData != null ? cultureData['name'] as String? : null);

    _selectedImageName = widget.recipe.image;
    _selectedImage = await widget.controller.loadImage();

    for (var ingredient in widget.recipe.ingredients) {
      _ingredientControllers.add({
        'name': TextEditingController(text: ingredient.name),
        'quantity': TextEditingController(text: ingredient.quantity),
      });
    }
    for (var instruction in widget.recipe.instructions) {
      _instructionControllers.add({
        'step': TextEditingController(text: instruction.step),
        'order': TextEditingController(text: instruction.order.toString()),
      });
    }
    for (var allergen in widget.recipe.allergens) {
      _allergenControllers.add(TextEditingController(text: allergen));
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    await widget.controller.pickImage(_nameController, (File? path) {
      setState(() {
        _imagePath = path;
      });
    }, (String? name) {
      setState(() {
        _selectedImageName = name;
      });
    });
  }

  // Modify the recipe
  void _modifyRecipe() async {
    await widget.controller.modifyRecipe(
      context,
      _nameController,
      _priceController,
      _prepTimeController,
      _ingredientControllers,
      _instructionControllers,
      _allergenControllers,
      _selectedCultureName,
      _selectedImageName,
    );
  }

  // Add an ingredient
  void _addIngredient() {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  // Add an instruction
  void _addInstruction() {
    setState(() {
      _instructionControllers.add({
        'step': TextEditingController(),
        'order': TextEditingController(),
      });
    });
  }

  // Add an allergen
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

  // Remove an instruction
  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers.removeAt(index);
    });
  }

  // Remove an allergen
  void _removeAllergen(int index) {
    setState(() {
      _allergenControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Show a loading indicator
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 16, 16),
          child: Text(
            'Modify Recipe',
            style: TextStyle(fontSize: 26),
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
                      : _selectedImage != null
                          ? DecorationImage(
                              image: NetworkImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _imagePath == null && _selectedImage == null
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
                  Map<String, TextEditingController> controllerMap =
                      entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllerMap['name'],
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
                            controller: controllerMap['quantity'],
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
                  Map<String, TextEditingController> controllerMap =
                      entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllerMap['step'],
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
                            controller: controllerMap['order'],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
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
              value: _selectedCultureName, // Set the initial value here
              onChanged: (value) {
                setState(() {
                  _selectedCultureName = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Culture',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              items: widget.controller.cultures.map((culture) {
                return DropdownMenuItem<String>(
                  value: culture.name,
                  child: Text(
                    culture.name,
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.red,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
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
              onPressed: _modifyRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: const Text(
                'Modify Recipe',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
