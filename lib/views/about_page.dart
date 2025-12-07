import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "À propos & Guide",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ Introduction
            Text(
              "Bienvenue sur eRead 📚",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Cette application vous permet de lire, apprendre et enrichir vos connaissances grâce à une bibliothèque numérique moderne et intuitive.",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),

            const SizedBox(height: 25),

            // ⭐ Section 1
            _buildSectionTitle("📘 1. Lire des livres"),
            _buildCard(
              "Accédez à une large sélection de livres catégorisés. "
                  "Vous pouvez filtrer, rechercher et ouvrir n’importe quel livre. "
                  "Les fichiers PDF s’ouvrent directement dans le lecteur intégré.",
            ),

            const SizedBox(height: 20),

            // ⭐ Section 2
            _buildSectionTitle("❤️ 2. Ajouter aux favoris"),
            _buildCard(
              "Vous pouvez marquer un livre comme favori en appuyant sur l'icône ❤️. "
                  "Vos livres favoris apparaissent ensuite dans une section dédiée.",
            ),

            const SizedBox(height: 20),

            // ⭐ Section 3
            _buildSectionTitle("📖 3. Suivre les mots appris"),
            _buildCard(
              "Chaque fois que vous apprenez un nouveau mot lors de votre lecture, "
                  "vous pouvez l’enregistrer dans la section Vocabulaire. "
                  "Ajoutez la définition et un exemple pour mieux mémoriser.",
            ),

            const SizedBox(height: 20),

            // ⭐ Section 4
            _buildSectionTitle("📚 4. Ajouter vos propres livres"),
            _buildCard(
              "Si vous souhaitez enrichir votre bibliothèque, vous pouvez ajouter vos propres fichiers PDF "
                  "avec une image de couverture, le titre, l’auteur et la catégorie.",
            ),

            const SizedBox(height: 20),

            // ⭐ Section 5
            _buildSectionTitle("👤 5. Profil utilisateur"),
            _buildCard(
              "Votre profil contient votre nom et vos statistiques personnelles : "
                  "livres ajoutés, favoris, mots appris…",
            ),

            const SizedBox(height: 30),

            // ⭐ Footnote
            Center(
              child: Text(
                "Merci d’utiliser eRead ❤️",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple.shade400,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔧 Widgets réutilisables
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple.shade600,
      ),
    );
  }

  Widget _buildCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4),
      ),
    );
  }
}
