import 'package:flutter/material.dart';

class EntityEditor extends StatelessWidget {
  final TextEditingController entityController;
  final bool isSystemEntity;
  final ValueChanged<bool?> onSystemEntityChanged;
  final VoidCallback onAddEntity;

  const EntityEditor({
    super.key,
    required this.entityController,
    required this.isSystemEntity,
    required this.onSystemEntityChanged,
    required this.onAddEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: entityController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Entity (e.g., User, Database)',
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: isSystemEntity,
              onChanged: onSystemEntityChanged,
              activeColor: Theme.of(context).colorScheme.primary,
              checkColor: Theme.of(context).colorScheme.onPrimary,
            ),
            Text(
              'External System (Rectangle)',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onAddEntity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Add Entity'),
            ),
          ],
        ),
      ],
    );
  }
}

class InteractionEditor extends StatelessWidget {
  final TextEditingController interactionController;
  final VoidCallback onAddInteraction;

  const InteractionEditor({
    super.key,
    required this.interactionController,
    required this.onAddInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Interactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: interactionController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Interaction (e.g., Customer --> System : "Request")',
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onAddInteraction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Add Interaction'),
        ),
      ],
    );
  }
}

class DiagramContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final String? imageUrl;
  final VoidCallback onRetry;

  const DiagramContent({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.imageUrl,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (imageUrl != null) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 700,
            height: 700,
            child: Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Image load error: $error');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 36,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load diagram',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          'No diagram available',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
  }
}