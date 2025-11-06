# Guide : FavoriteProvider - Étape par Étape

## Arborescence des fichiers

```
lib/
├── main.dart                     ← ÉTAPE 0 (modifier)
├── Provider/
│   └── favorite_provider.dart    ← ÉTAPES 1-7 (créer)
└── Views/
    └── app_main_screen.dart      ← ÉTAPE 8 (utiliser)
```

---

## Plan de construction

```
ÉTAPE 0: Ajouter package provider
    ↓
ÉTAPE 1: Créer classe FavoriteProvider
    ↓
ÉTAPE 2: + Liste _favoriteIds
    ↓
ÉTAPE 3: + Getter favorites
    ↓
ÉTAPE 4: + Méthode toggleFavorite()
    ↓
ÉTAPE 5: + Méthode _addFavorite()
    ↓
ÉTAPE 6: + Méthode _removeFavorite()
    ↓
ÉTAPE 7: + Méthode loadFavorites()
    ↓
ÉTAPE 8: Connecter dans main.dart
    ↓
ÉTAPE 9: Utiliser dans app_main_screen.dart
    ↓
    ✅ TERMINÉ
```

---

## ÉTAPE 0 : Ajouter package provider

### OÙ : Fichier `pubspec.yaml`

**ACTION** : AJOUTER dans dependencies (sous cloud_firestore)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^4.9.1
  provider: ^6.0.5              ← AJOUTER cette ligne
```

**Puis dans le terminal** :
```bash
flutter pub get
```

**Ce que ça fait** : Installe le package Provider

---

## ÉTAPE 1 : Créer FavoriteProvider

### OÙ : Créer dossier et fichier `lib/Provider/favorite_provider.dart`

**ACTION** : Créer nouveau fichier et coller ce code

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProvider extends ChangeNotifier {
  // Le code viendra ici
}
```

**Ce que ça fait** : Crée la structure du Provider

---

## ÉTAPE 2 : Liste des favoris

### OÙ : Dans classe `FavoriteProvider`

**ACTION** : AJOUTER après la ligne `class FavoriteProvider extends ChangeNotifier {`

```dart
class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
```

**Ce que ça fait** : Crée liste privée pour stocker les IDs favoris

---

## ÉTAPE 3 : Getter favorites

### OÙ : Dans classe `FavoriteProvider`, après `_firestore`

**ACTION** : AJOUTER cette ligne

```dart
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> get favorites => _favoriteIds;
```

**Ce que ça fait** : Permet de lire la liste des favoris

---

## ÉTAPE 4 : toggleFavorite()

### OÙ : Dans classe `FavoriteProvider`, après le getter

**ACTION** : AJOUTER cette méthode

```dart
  // Toggle favorites state
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
```

**Ce que ça fait** : Ajoute/retire un favori et notifie les listeners

---

## ÉTAPE 5 : _addFavorite()

### OÙ : Dans classe `FavoriteProvider`, après `toggleFavorite()`

**ACTION** : AJOUTER cette méthode

```dart
  // Add to favorites in Firestore
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite': true,
      });
    } catch (e) {
      print(e.toString());
    }
  }
```

**Ce que ça fait** : Ajoute favori dans Firestore

---

## ÉTAPE 6 : _removeFavorite()

### OÙ : Dans classe `FavoriteProvider`, après `_addFavorite()`

**ACTION** : AJOUTER cette méthode

```dart
  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }
```

**Ce que ça fait** : Supprime favori de Firestore

---

## ÉTAPE 7 : loadFavorites()

### OÙ : Dans classe `FavoriteProvider`, après `_removeFavorite()`

**ACTION** : AJOUTER cette méthode

```dart
  // Load favorites from Firestore
  Future<void> loadFavorites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("userFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
```

**Ce que ça fait** : Charge tous les favoris depuis Firestore au démarrage

---

## ÉTAPE 8 : Connecter Provider dans main.dart

### OÙ : Fichier `lib/main.dart`

**ACTION** : AJOUTER import en haut

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_rec_oct_2025_v3/firebase_options.dart';
import 'package:provider/provider.dart';          ← AJOUTER
import 'Provider/favorite_provider.dart';         ← AJOUTER
import 'Views/app_main_screen.dart';
```

### Bout de code : Wrapper avec Provider

**ACTION** : REMPLACER `runApp(const MyApp());` par

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoriteProvider()..loadFavorites(),
      child: const MyApp(),
    ),
  );
}
```

**Ce que ça fait** : Rend FavoriteProvider disponible partout dans l'app

---

## ÉTAPE 9 : Utiliser dans app_main_screen.dart

### OÙ : Fichier `lib/Views/app_main_screen.dart`

**ACTION** : AJOUTER import en haut

```dart
import 'package:provider/provider.dart';
import '../Provider/favorite_provider.dart';
```

### Utilisation dans le GridView

**OÙ** : Dans le StreamBuilder des recettes, dans le bouton coeur (ligne ~210)

**ACTION** : REMPLACER le Container du coeur par

```dart
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
```

**Ce que ça fait** : Icône coeur cliquable qui sauvegarde dans Firestore

---

## CODE COMPLET : favorite_provider.dart

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> get favorites => _favoriteIds;
  
  // Toggle favorites state
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
  
  // Check if a product is favorited
  bool isFavorited(String productId) {
    return _favoriteIds.contains(productId);
  }
  
  // Add to favorites in Firestore
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite': true,
      });
    } catch (e) {
      print(e.toString());
    }
  }
  
  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }
  
  // Load favorites from Firestore
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

---

## Checklist finale

- [ ] Package provider ajouté dans pubspec.yaml
- [ ] flutter pub get exécuté
- [ ] Dossier Provider créé
- [ ] Fichier favorite_provider.dart créé
- [ ] FavoriteProvider avec toutes les méthodes
- [ ] main.dart wrapper avec ChangeNotifierProvider
- [ ] Import provider dans app_main_screen.dart
- [ ] Consumer dans le bouton coeur
- [ ] Aucune erreur de compilation
- [ ] Clic sur coeur ajoute/retire des favoris

---

## Comment tester

1. Lancez l'app
2. Cliquez sur un coeur
3. Le coeur devient rouge (favori)
4. Vérifiez dans Firebase Console → collection "userFavorite"
5. Cliquez à nouveau → coeur redevient gris
6. Document supprimé de Firestore

---

## Résumé : Ce que fait FavoriteProvider

```
                FavoriteProvider
                       |
        ┌──────────────┼──────────────┐
        |              |              |
   Liste locale   Firestore    Notifier UI
   _favoriteIds   (userFavorite)    
        |              |              |
        └──────────────┴──────────────┘
                       |
              toggleFavorite()
                  ↓ ↑
            add / remove
```

**Flux** :
1. User clique coeur
2. `toggleFavorite()` appelé
3. Si pas favori → `_addFavorite()` → Firestore
4. Si favori → `_removeFavorite()` → Firestore
5. `notifyListeners()` → UI se met à jour

---

**Guide créé pour ajouter système de favoris avec Provider**  
*9 étapes simples, copier-coller, fonctionne*

