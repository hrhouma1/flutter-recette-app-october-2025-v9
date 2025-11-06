# Guide : Page des Favoris - Étape par Étape

## Arborescence des fichiers

```
lib/
├── Provider/
│   └── favorite_provider.dart    (déjà créé - Guide 03)
└── Views/
    ├── app_main_screen.dart      ← ÉTAPE 2 (modifier)
    └── favorite_screen.dart      ← ÉTAPE 1 (créer)
```

---

## Plan de construction

```
ÉTAPE 1: Créer favorite_screen.dart
    ↓
ÉTAPE 2: Importer dans app_main_screen.dart
    ↓
ÉTAPE 3: Lier à l'onglet Favorite (index 1)
    ↓
    ✅ PAGE FAVORIS FONCTIONNELLE
```

---

## ÉTAPE 1 : Créer la page Favoris

### OÙ : Créer fichier `lib/Views/favorite_screen.dart`

**ACTION** : Créer nouveau fichier et coller tout ce code

### Interface si VIDE
```
┌────────────────────────┐
│ My Favorites           │
│                        │
│        💜              │
│                        │
│  No favorites yet      │
│                        │
│ Start adding recipes!  │
│                        │
└────────────────────────┘
```

### Interface si FAVORIS
```
┌────────────────────────┐
│ My Favorites           │
│                        │
│ ┌──────┐  ┌──────┐    │
│ │  🍕  │  │  🍔  │    │
│ │  ❤️  │  │  ❤️  │    │
│ │Pizza │  │Burger│    │
│ └──────┘  └──────┘    │
│ ┌──────┐  ┌──────┐    │
│ │  🍝  │  │  🥗  │    │
│ └──────┘  └──────┘    │
└────────────────────────┘
```

### Bout de code 1 : Page complète favorite_screen.dart

```dart
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
```

**Ce que ça fait** : Page qui affiche tous les favoris en grille

---

## ÉTAPE 2 : Importer favorite_screen

### OÙ : Fichier `lib/Views/app_main_screen.dart`

**ACTION** : AJOUTER en haut après les autres imports

```dart
import 'view_all_items.dart';
import 'favorite_screen.dart';      ← AJOUTER cette ligne
```

**Ce que ça fait** : Permet d'utiliser FavoriteScreen

---

## ÉTAPE 3 : Lier à l'onglet Favorite

### OÙ : Fichier `lib/Views/app_main_screen.dart`, classe `_AppMainScreenState`

**ACTION** : Chercher la ligne `body:` dans le Scaffold et REMPLACER par

```dart
      body: selectedIndex == 0
          ? const MyAppHomeScreen()
          : selectedIndex == 1
              ? const FavoriteScreen()
              : Center(child: Text("Page index: $selectedIndex")),
```

**Ce que ça fait** : Affiche FavoriteScreen quand onglet Favorite cliqué

---

## Récapitulatif visuel

```
selectedIndex = 0  →  MyAppHomeScreen (recettes)
selectedIndex = 1  →  FavoriteScreen (favoris)     ← NOUVEAU
selectedIndex = 2  →  Page placeholder
selectedIndex = 3  →  Page placeholder
```

---

## Comment tester

```
1. Sur page Home
      ↓
2. Cliquez ❤️ gris sur recette
      ↓
3. ❤️ devient rouge
      ↓
4. Cliquez onglet Favorite
      ↓
5. Vous voyez la recette !
      ↓
6. Cliquez ❤️ rouge dans Favoris
      ↓
7. Recette disparaît instantanément
```

---

## Checklist

- [ ] favorite_screen.dart créé
- [ ] Import dans app_main_screen.dart
- [ ] body modifié avec condition selectedIndex == 1
- [ ] Hot reload fait
- [ ] Onglet Favorite affiche la page
- [ ] Page vide montre message
- [ ] Ajout de favori fonctionne
- [ ] Retrait de favori fonctionne

---

## Progression complète des guides

```
GUIDE 01 (60 min)
   → App de base
   
GUIDE 03 (30 min)
   → FavoriteProvider
   → Coeurs cliquables
   
GUIDE 04 (15 min)
   → Page Favoris        ← VOUS ÊTES ICI
   → Onglet fonctionnel
   
   ✅ APP COMPLÈTE
```

---

## Résumé des 4 guides

| Guide | Quoi | Durée | Fichiers créés |
|-------|------|-------|----------------|
| **01** | App de base | 60 min | app_main_screen.dart |
| **02** | Référence rapide | 30 min | (tous les codes) |
| **03** | Provider favoris | 30 min | favorite_provider.dart |
| **04** | Page favoris | 15 min | favorite_screen.dart |

**Total** : ~2h pour app complète

---

**Guide créé pour ajouter la page des favoris**  
*3 étapes simples, copier-coller, fonctionne*


