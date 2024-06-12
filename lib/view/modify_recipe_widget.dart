import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
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
    if (_isLoading) {
      return _buildLoadingScreen();
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
                          image: NetworkImage(_selectedImage!),
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
            _buildIngredientSection(),
            const SizedBox(height: 20),
            _buildInstructionSection(),
            const SizedBox(height: 20),
            _buildAllergenSection(),
            const SizedBox(height: 20),
            _buildCultureDropdown(),
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

  Widget _buildIngredientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ..._ingredientControllers.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, TextEditingController> controllerMap = entry.value;
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
    );
  }

  Widget _buildInstructionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ..._instructionControllers.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, TextEditingController> controllerMap = entry.value;
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
    );
  }

  Widget _buildAllergenSection() {
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
    );
  }

  Widget _buildCultureDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCultureName,
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
    );
  }

  Widget _buildLoadingScreen() {
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
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: GestureDetector(
                onTap: () {}, // Placeholder action
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const TextField(
                decoration: InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for Ingredients
            _buildShimmerList(3), // Adjust the number based on your UI
            const SizedBox(height: 20),
            // Placeholder for Instructions
            _buildShimmerList(3), // Adjust the number based on your UI
            const SizedBox(height: 20),
            // Placeholder for Allergens
            _buildShimmerList(3), // Adjust the number based on your UI
            const SizedBox(height: 20),
            // Placeholder for Dropdown
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Culture',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (value) {}, // Placeholder action
                items: List.generate(3, (index) {
                  return DropdownMenuItem<String>(
                    value: 'Item $index',
                    child: Text(
                      'Item $index',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for Preparation Time
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const TextField(
                decoration: InputDecoration(
                  labelText: 'Preparation Time (minutes)',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for Price
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const TextField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for Button
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ElevatedButton(
                onPressed: () {}, // Placeholder action
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text(
                  'Modify Recipe',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    height: 40,
                    color: Colors.grey[300],
                  ),
                ),
                // Add IconButton or other controls as needed
              ],
            ),
          ),
        );
      }),
    );
  }
}
