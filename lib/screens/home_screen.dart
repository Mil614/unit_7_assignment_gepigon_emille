import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Fetch characters from API
  Future<List<dynamic>> fetchCharacters() async {
    final response =
        await http.get(Uri.parse('https://narutodb.xyz/api/character'));

    if (response.statusCode == 200) {
      // Decode the response body
      var jsonResponse = json.decode(response.body);

      // Print the raw response to see its structure
      print(jsonResponse);

      // Adjust based on the response structure
      if (jsonResponse is List) {
        return jsonResponse;
      } else if (jsonResponse is Map) {
        // Check if the response is a map, and it contains a 'characters' key
        if (jsonResponse.containsKey('characters')) {
          return jsonResponse['characters']; // Return the characters list
        } else {
          throw Exception(
              'Unexpected response structure: Missing "characters" key');
        }
      } else {
        throw Exception('Unexpected response structure');
      }
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Naruto Characters"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No characters found."));
          }

          final characters = snapshot.data!;

          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];

              // Checking if 'images' key is present and if the list has at least one element
              String imageUrl = '';
              if (character['images'] != null &&
                  character['images'].isNotEmpty) {
                imageUrl = character['images'][0]; // Safe access
              } else {
                imageUrl = 'https://via.placeholder.com/150'; // Fallback image
              }

              // Providing fallback for 'name' and 'about' keys in case they are null
              String name = character['name'] ?? 'Unknown Character';
              String description =
                  character['about'] ?? "A character from Naruto.";

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ExpandedTile(
                  theme: ExpandedTileThemeData(
                    contentBackgroundColor: Colors.white,
                    contentPadding: const EdgeInsets.all(10),
                  ),
                  controller: ExpandedTileController(),
                  title: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            12.0), // Apply rounded corners
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
