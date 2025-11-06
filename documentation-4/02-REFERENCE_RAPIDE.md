# Référence Ultra-Rapide

## 16 bouts de code dans l'ordre

### Bout 1 : app_main_screen.dart - Structure
```dart
// CRÉER lib/Views/app_main_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

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
      body: Center(child: Text("Page index: $selectedIndex")),
    );
  }
}
```

---

### Bout 2 : BottomNavigationBar
```dart
// REMPLACER méthode build() dans _AppMainScreenState
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
      items: [
        BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Iconsax.heart), label: "Favorite"),
        BottomNavigationBarItem(icon: Icon(Iconsax.calendar), label: "Meal Plan"),
        BottomNavigationBarItem(icon: Icon(Iconsax.setting), label: "Setting"),
      ],
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
    ),
    body: Center(child: Text("Page index: $selectedIndex")),
  );
}
```

---

### Bout 3 : MyAppHomeScreen
```dart
// AJOUTER en bas du fichier après _AppMainScreenState
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
              Text("Hello from HomeScreen"),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Bout 4 : Lier MyAppHomeScreen
```dart
// REMPLACER ligne body dans _AppMainScreenState
body: selectedIndex == 0
    ? const MyAppHomeScreen()
    : Center(child: Text("Page index: $selectedIndex")),
```

---

### Bout 5 : headerParts()
```dart
// AJOUTER méthode dans _MyAppHomeScreenState
Padding headerParts() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: [
        Text("What are you\ncooking today?",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1)),
        Spacer(),
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            fixedSize: Size(55, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          icon: Icon(Iconsax.notification),
        ),
      ],
    ),
  );
}
```

---

### Bout 6 : Utiliser headerParts
```dart
// REMPLACER children du Column dans build de MyAppHomeScreen
children: [
  headerParts(),
],
```

---

### Bout 7 : mySearchBar()
```dart
// AJOUTER méthode dans _MyAppHomeScreenState
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
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
        prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );
}
```

---

### Bout 8 : Utiliser mySearchBar
```dart
// MODIFIER children du Column
children: [
  headerParts(),
  SizedBox(height: 20),
  mySearchBar(),
],
```

---

### Bout 9 : BannerToExplore
```dart
// AJOUTER classe en bas du fichier
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
                Text("Cook the best\nrecipes at home",
                  style: TextStyle(height: 1.1, fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Explore", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF71B77A))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -20,
            child: Image.asset("assets/images/chef_PNG190.png", width: 180),
          ),
        ],
      ),
    );
  }
}
```

---

### Bout 10 : Utiliser Banner
```dart
// AJOUTER dans children du Column
mySearchBar(),
SizedBox(height: 20),
const BannerToExplore(),
```

---

### Bout 11 : Titre Categories
```dart
// AJOUTER dans children du Column
const BannerToExplore(),
const Padding(
  padding: EdgeInsets.symmetric(vertical: 20),
  child: Text("Categories",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
),
```

---

### Bout 12 : StreamBuilder Categories
```dart
// AJOUTER dans children du Column
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
```

---

### Bout 13 : categoryButtons()
```dart
// AJOUTER méthode dans _MyAppHomeScreenState
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
              child: Text(category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
            ),
          ),
        );
      }).toList(),
    ),
  );
}
```

---

### Bout 14 : Import view_all_items
```dart
// AJOUTER en haut du fichier (ligne 5)
import 'view_all_items.dart';
```

---

### Bout 15 : Row Quick & Easy
```dart
// AJOUTER dans children du Column
const SizedBox(height: 20),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text("Quick & Easy",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewAllItems(
              categoryTitle: "Quick & Easy",
              categoryName: null,
            ),
          ),
        );
      },
      child: const Text("View all",
        style: TextStyle(color: kprimaryColor, fontSize: 14, fontWeight: FontWeight.w600)),
    ),
  ],
),
const SizedBox(height: 15),
```

---

### Bout 16 : StreamBuilder Recettes
```dart
// AJOUTER dans children du Column (LE PLUS GROS BOUT)
Container(
  height: 400,
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
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: img.isNotEmpty
                              ? Image.network(img, width: double.infinity, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey[200],
                                  child: Center(child: Icon(Icons.restaurant, size: 50, color: Colors.grey[400]))),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3)],
                            ),
                            child: Icon(Iconsax.heart, size: 16, color: Colors.grey[600]),
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
                        Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Iconsax.clock, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(time.isNotEmpty ? "$time Min" : "- Min",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(width: 10),
                            Icon(Iconsax.flash_1, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text("$cal Cal", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
```

---

## Ordre exact

1. Bout 1 → Créer fichier
2. Bout 2 → REMPLACER build()
3. Bout 3 → AJOUTER classe en bas
4. Bout 4 → REMPLACER body
5. Bout 5 → AJOUTER méthode
6. Bout 6 → MODIFIER children
7. Bout 7 → AJOUTER méthode
8. Bout 8 → MODIFIER children
9. Bout 9 → AJOUTER classe en bas
10. Bout 10 → MODIFIER children
11. Bout 11 → MODIFIER children
12. Bout 12 → MODIFIER children
13. Bout 13 → AJOUTER méthode
14. Bout 14 → AJOUTER import en haut
15. Bout 15 → MODIFIER children
16. Bout 16 → MODIFIER children

---

## BONUS : FavoriteProvider (Code complet)

### Fichier : lib/Provider/favorite_provider.dart

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> get favorites => _favoriteIds;
  
  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId);
    }
    notifyListeners();
  }
  
  bool isFavorited(String productId) {
    return _favoriteIds.contains(productId);
  }
  
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({'isFavorite': true});
    } catch (e) {
      print(e.toString());
    }
  }
  
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }
  
  Future<void> loadFavorites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("userFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
```

### Modifier main.dart

```dart
import 'package:provider/provider.dart';
import 'Provider/favorite_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoriteProvider()..loadFavorites(),
      child: const MyApp(),
    ),
  );
}
```

---

**Référence ultra-rapide sans explications**  
*Pour ceux qui veulent juste le code*

