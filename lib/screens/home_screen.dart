import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteJokes;

  const HomeScreen({super.key, required this.favoriteJokes});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke Types'),
        actions: [
          // Existing Random Joke Button
          IconButton(
            icon: const Icon(Icons.lightbulb),
            tooltip: 'Random Joke of the Day',
            onPressed: () {
              Navigator.pushNamed(context, '/random-joke');
            },
          ),
          // New Favorites Button
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorites',
            onPressed: () {
              // Navigate to the Favorites Screen
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: ApiService.fetchJokeTypes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jokeTypes = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 3,
                ),
                itemCount: jokeTypes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/joke-list',
                        arguments: jokeTypes[index],
                      );
                    },
                    child: Card(
                      elevation: 4,
                      child: Center(
                        child: Text(
                          jokeTypes[index],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
