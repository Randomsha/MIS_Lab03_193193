import 'package:flutter/material.dart';
import '../services/api_services.dart';

class JokeListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteJokes;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const JokeListScreen({
    super.key,
    required this.favoriteJokes,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final jokeType = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('$jokeType Jokes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchJokesByType(jokeType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jokes = snapshot.data!;
            return ListView.builder(
              itemCount: jokes.length,
              itemBuilder: (context, index) {
                final joke = jokes[index];
                final isFavorite =
                    favoriteJokes.any((fav) => fav['id'] == joke['id']);

                return ListTile(
                  title: Text(joke['setup']),
                  subtitle: Text(joke['punchline']),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      onToggleFavorite(joke);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
