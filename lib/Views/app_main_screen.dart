import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../Provider/favorite_provider.dart';
import 'view_all_items.dart';
import 'favorite_screen.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({Key? key}) : super(key: key);

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          color: kprimaryColor,
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.setting5 : Iconsax.setting,
            ),
            label: "Setting",
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      body: selectedIndex == 0
          ? const MyAppHomeScreen()
          : selectedIndex == 1
              ? const FavoriteScreen()
              : Center(child: Text("Page index: $selectedIndex")),
    );
  }
}

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String selectedCategory = "All";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerParts(),
              SizedBox(height: 20),
              mySearchBar(),
              SizedBox(height: 20),
              // for banner
              const BannerToExplore(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Categories buttons from Firestore
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<String> categories = ["All"];
                    for (var doc in snapshot.data!.docs) {
                      categories.add(doc['name']);
                    }
                    return categoryButtons(categories);
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 20),
              // Titre "Quick & Easy" avec bouton "View all"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Quick & Easy",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Bouton "View all" qui navigue vers la page complète
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewAllItems(
                            categoryTitle: "Quick & Easy",
                            categoryName: null, // null = toutes les recettes
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(
                        color: kprimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Recipes from Firestore (limité à 4 items pour l'aperçu)
              Container(
                height: 400, // Hauteur fixe pour éviter les contraintes infinies
                child: StreamBuilder<QuerySnapshot>(
                  stream: selectedCategory == "All" 
                      ? _firestore.collection('details').limit(4).snapshots()
                      : _firestore.collection('details')
                          .where('category', isEqualTo: selectedCategory)
                          .limit(4)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final recipe = snapshot.data!.docs[index];
                          final img = (recipe['image'] ?? '').toString();
                          final name = (recipe['name'] ?? 'Sans nom').toString();
                          final time = (recipe['time'] ?? '').toString();
                          final cal = (recipe['cal'] ?? '0').toString();

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
                                        child: Consumer<FavoriteProvider>(
                                          builder: (context, favoriteProvider, child) {
                                            final isFavorite = favoriteProvider.favorites.contains(recipe.id);
                                            
                                            return GestureDetector(
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
                                                child: Icon(
                                                  isFavorite ? Iconsax.heart5 : Iconsax.heart,
                                                  size: 16,
                                                  color: isFavorite ? Colors.red : Colors.grey[600],
                                                ),
                                              ),
                                            );
                                          },
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
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding headerParts() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text(
            "What are you\ncooking today?",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              fixedSize: Size(55, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: Icon(Iconsax.notification),
          ),
        ],
      ),
    );
  }

  Container mySearchBar() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search any recipes",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget categoryButtons(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          bool isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kprimaryColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: Color(0xFF71B77A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cook the best\nrecipes at home",
                  style: TextStyle(
                    height: 1.1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF71B77A),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -20,
            child: Image.asset(
              "assets/images/chef_PNG190.png",
              width: 180,
            ),
          ),
        ],
      ),
    );
  }
}
