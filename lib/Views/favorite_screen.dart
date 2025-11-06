import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../Provider/favorite_provider.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoriteIds = favoriteProvider.favorites;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.heart,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start adding recipes to your favorites!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: favoriteIds.length,
                itemBuilder: (context, index) {
                  final recipeId = favoriteIds[index];
                  
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('details')
                        .doc(recipeId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final recipe = snapshot.data!;
                      final data = recipe.data() as Map<String, dynamic>?;
                      
                      if (data == null) {
                        return const SizedBox.shrink();
                      }

                      final img = (data['image'] ?? '').toString();
                      final name = (data['name'] ?? 'Sans nom').toString();
                      final time = (data['time'] ?? '').toString();
                      final cal = (data['cal'] ?? '0').toString();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: img.isNotEmpty
                                        ? Image.network(
                                            img,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Icon(
                                                Icons.restaurant,
                                                size: 50,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        favoriteProvider.toggleFavorite(recipe);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Iconsax.heart5,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.clock,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        time.isNotEmpty ? "$time Min" : "- Min",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Iconsax.flash_1,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$cal Cal",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

