import 'package:flutter/material.dart';
import '../services/api_services.dart';

class JokeListScreen extends StatelessWidget {
  const JokeListScreen({super.key});

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
                return ListTile(
                  title: Text(joke['setup']),
                  subtitle: Text(joke['punchline']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
