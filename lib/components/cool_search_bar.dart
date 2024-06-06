import 'package:flutter/material.dart';

class SearchBarNiceWidget extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarNiceWidget({
    super.key,
    required this.onSearch,
  });

  @override
  SearchBarNiceWidgetState createState() => SearchBarNiceWidgetState();
}

class SearchBarNiceWidgetState extends State<SearchBarNiceWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Color(0x33000000),
              offset: Offset(0, 1),
            )
          ],
          borderRadius: BorderRadius.circular(30), // Set to half of the height
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onSearch,
                  decoration: const InputDecoration(
                    labelText: 'Search recipes...',
                    labelStyle: TextStyle(
                      fontFamily: 'Inter',
                      letterSpacing: 0,
                      color: Colors.grey,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      letterSpacing: 0,
                      color: Colors.grey,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                  cursorColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Clear the search text and trigger search
                  widget.onSearch('');
                  _controller.clear(); // Clear the text field visually
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  child: const Icon(
                    Icons.clear,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
