import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final Function(List<String>, String, String) onApplyFilters;

  const FilterModal({super.key, required this.onApplyFilters});

  @override
  FilterModalState createState() => FilterModalState();
}

class FilterModalState extends State<FilterModal> {
  List<String> selectedAllergens = [];
  String selectedPrice = '';
  String selectedTime = '';
  bool buttonSelected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'FILTERS:',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded),
                    Text(
                      ' Allergens:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  children: [
                    'Peanuts',
                    'Tree nuts',
                    'Milk',
                    'Eggs',
                    'Wheat',
                    'Soy',
                    'Fish',
                    'Shellfish',
                    'Sesame',
                    'Gluten',
                    'Sulfites',
                    'Mustard',
                  ].map((String allergen) {
                    return ChoiceChip(
                      label: Text(allergen),
                      selected: selectedAllergens.contains(allergen),
                      onSelected: (bool selected) {
                        setState(() {
                          selected
                              ? selectedAllergens.add(allergen)
                              : selectedAllergens.remove(allergen);
                        });
                      },
                      selectedColor: buttonSelected ? Colors.red : null,
                      labelStyle: TextStyle(
                        color: buttonSelected ? Colors.white : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.attach_money_rounded),
                    Text(
                      ' Price:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  children: <String>['0 - 10\$', '10 - 15\$', '15 - 20\$']
                      .map((String price) {
                    return ChoiceChip(
                      label: Text(price),
                      selected: selectedPrice == price,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedPrice = selected ? price : '';
                        });
                      },
                      selectedColor: buttonSelected ? Colors.red : null,
                      labelStyle: TextStyle(
                        color: buttonSelected ? Colors.white : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer),
                    Text(
                      ' Preparation time:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: <String>['< 10 min', '< 15 min', '< 20 min']
                      .map((String time) {
                    return ChoiceChip(
                      label: Text(time),
                      selected: selectedTime == time,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedTime = selected ? time : '';
                        });
                      },
                      selectedColor: buttonSelected ? Colors.red : null,
                      labelStyle: TextStyle(
                        color: buttonSelected ? Colors.white : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  buttonSelected = true;
                });
                await widget.onApplyFilters(
                    selectedAllergens, selectedPrice, selectedTime);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                'Apply filters',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
