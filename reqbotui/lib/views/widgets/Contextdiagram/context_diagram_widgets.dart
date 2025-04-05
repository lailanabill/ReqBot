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
        const Text(
          'Entities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: entityController,
          decoration: const InputDecoration(labelText: 'Entity (e.g., User, Database)'),
        ),
        Row(
          children: [
            Checkbox(
              value: isSystemEntity,
              onChanged: onSystemEntityChanged,
            ),
            const Text('External System (Rectangle)'),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: onAddEntity, child: const Text('Add Entity')),
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
        const Text(
          'Interactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: interactionController,
          decoration: const InputDecoration(
            labelText: 'Interaction (e.g., Customer --> System : "Request")',
          ),
        ),
        ElevatedButton(
          onPressed: onAddInteraction,
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
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    } else if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 700,
          height: 700,
          child: Image.network(
            imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              print('Image load error: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Failed to load diagram', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const Center(child: Text('No diagram available'));
    }
  }
}