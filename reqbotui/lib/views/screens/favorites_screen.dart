import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/favorites_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/dark_mode_toggle.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favoriteProjects = favoritesProvider.favoriteProjects.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, 
            color: Theme.of(context).colorScheme.onSurface, 
            size: 20
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Favorite Projects',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined, 
              color: Theme.of(context).colorScheme.onSurface
            ),
            onPressed: () {},
          ),
          const CompactDarkModeToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Your saved projects',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${favoriteProjects.length} projects',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: favoriteProjects.isEmpty
                    ? const NoFavoritesMessage()
                    : ListView.separated(
                        itemCount: favoriteProjects.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final projectName = favoriteProjects[index];
                          return FavoriteProjectCard(
                            projectName: projectName,
                            onDelete: () => favoritesProvider.toggleFavorite(projectName),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteProjectCard extends StatelessWidget {
  final String projectName;
  final VoidCallback onDelete;

  const FavoriteProjectCard({
    Key? key,
    required this.projectName,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to project details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.folder_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                       Text(
                        'Tap to view details',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 22,
                  ),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: () {
                    // Navigate to project details
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoFavoritesMessage extends StatelessWidget {
  const NoFavoritesMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
             Text(
              'No Favorites Yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
             Text(
              'Projects you mark as favorites will appear here for quick access',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back to browse projects
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:  Text(
                'Browse Projects',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}