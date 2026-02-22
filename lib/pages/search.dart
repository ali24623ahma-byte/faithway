import 'package:flutter/material.dart';
import '../data/search_data.dart';
import '../models/search_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String query = "";

  @override
  Widget build(BuildContext context) {
    final List<SearchItem> items = searchItems();

    final results = query.isEmpty
        ? <SearchItem>[]
        : items.where((item) {
            final q = query.toLowerCase();
            return item.title.toLowerCase().contains(q) ||
                item.keywords.any((k) => k.toLowerCase().contains(q));
          }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        elevation: 0,
        title: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
              icon: Icon(Icons.search),
            ),
          ),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _controller.clear();
                setState(() => query = "");
              },
            ),
        ],
      ),

      body: Stack(
        children: [
          /// 🌙 Always visible mosque background
          Positioned.fill(
            child: Image.asset(
              'assets/mosque_background.png',
              fit: BoxFit.cover,
            ),
          ),

          /// light overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2), // soft dark overlay
            ),
          ),

          /// 🔍 Search results (only when typing)
          if (query.isNotEmpty)
            ListView.builder(
              padding: const EdgeInsets.only(top: 100),
              itemCount: results.length,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(results[i].title),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => results[i].page),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        query = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
