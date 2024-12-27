import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteJokes;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteJokes,
    required this.onToggleFavorite,
  });

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: widget.favoriteJokes.isEmpty
          ? const Center(
              child: Text(
                'You have no favorite jokes yet.',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              itemCount: widget.favoriteJokes.length,
              itemBuilder: (context, index) {
                final joke = widget.favoriteJokes[index];
                return ListTile(
                  title: Text(joke['setup']),
                  subtitle: Text(joke['punchline']),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      widget.onToggleFavorite(joke);
                    },
                  ),
                );
              },
            ),
    );
  }
}
