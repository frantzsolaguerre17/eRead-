import 'package:flutter/material.dart';
import 'package:memo_livre/views/favorite_vocabulary_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/book_controller.dart';
import '../controllers/vocabulary_controller.dart';
import '../views/book_screen.dart';
import 'about_page.dart';
import 'favorites_book_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String displayName = 'Utilisateur';
  late final VocabularyController vocabularyController = VocabularyController();

  @override
  void initState() {
    super.initState();
    _loadDisplayName();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _loadDisplayName() {
    final user = supabase.auth.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.userMetadata?['full_name'] ?? 'Utilisateur';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Provider.of<BookController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.deepPurple.shade700,
              expandedHeight: 190,
              floating: false,
              pinned: true,
              elevation: 2,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: "app_logo",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/images/default_image.png",
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "eRead",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      "assets/images/default_image.png",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour, $displayName 👋",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Prêt à lire quelque chose d'inspirant aujourd’hui ?",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ Compteur Livres lus avec FutureBuilder
                        FutureBuilder<int>(
                          future: bookController.getReadBooksCount(),
                          builder: (context, snapshot) {
                            String value = "0";
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              value = "...";
                            } else if (snapshot.hasData) {
                              value = snapshot.data.toString();
                            }
                            return _buildStatCard(
                              "Livres lus",
                              value,
                              Icons.menu_book_rounded,
                              Colors.deepPurple,
                            );
                          },
                        ),
                        // Statique pour Favoris (tu peux remplacer par un futur si besoin)
                        /*_buildStatCard(
                          "Favoris",
                          "0",
                          Icons.favorite,
                          Colors.redAccent,
                        ),*/
                        // Compteur Mots appris
                        FutureBuilder<int>(
                          future: vocabularyController.getLearnedWordsCount(),
                          builder: (context, snapshot) {
                            String value = "0";
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              value = "...";
                            } else if (snapshot.hasData) {
                              value = snapshot.data.toString();
                            }
                            return _buildStatCard(
                              "Mots appris",
                              value,
                              Icons.text_fields,
                              Colors.amber,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Accès rapide",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          icon: Icons.menu_book_sharp,
                          label: "Livres",
                          color: Colors.deepPurple,
                          onTap: () => Navigator.of(context).push(_createRoute()),
                        ),
                        _buildQuickAction(
                          icon: Icons.favorite_border,
                          label: "Favoris Livres",
                          color: Colors.deepPurple.shade300,
                          onTap: () =>
                              Navigator.of(context).push(_createRouteFavoritePage()),
                        ),
                        _buildQuickAction(
                          icon: Icons.star_border,
                          label: "Favoris mots",
                          color: Colors.deepPurple.shade200,
                          onTap: () =>
                              Navigator.of(context).push(_createFavorisMotsPage()),
                        ),
                        _buildQuickAction(
                          icon: Icons.ad_units,
                          label: "eRead",
                          color: Colors.deepPurple.shade200,
                          onTap: () =>
                              Navigator.of(context).push(_createRouteAboutPage()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const BookListPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Route _createRouteFavoritePage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const FavoriteBooksPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Route _createRouteAboutPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const AboutPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Route _createFavorisMotsPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const FavoriteVocabularyScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
