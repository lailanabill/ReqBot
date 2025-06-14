import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/theme_provider.dart';

class DarkModeToggle extends StatelessWidget {
  final bool showLabel;
  final MainAxisAlignment alignment;

  const DarkModeToggle({
    super.key,
    this.showLabel = true,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Icon(
                Icons.light_mode,
                color: !themeProvider.isDarkMode 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.dark_mode, color: Colors.white);
                  }
                  return const Icon(Icons.light_mode, color: Colors.orange);
                },
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.dark_mode,
                color: themeProvider.isDarkMode 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ],
        );
      },
    );
  }
}

// Alternative compact version for app bars or tight spaces
class CompactDarkModeToggle extends StatelessWidget {
  const CompactDarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () {
            themeProvider.toggleTheme();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              key: ValueKey(themeProvider.isDarkMode),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          tooltip: themeProvider.isDarkMode 
              ? 'Switch to Light Mode' 
              : 'Switch to Dark Mode',
        );
      },
    );
  }
} 