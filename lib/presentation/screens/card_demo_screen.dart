import 'package:flutter/material.dart';
import 'package:trackie/presentation/widgets/glass_card.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';

/// A demo screen to showcase the GlassCard component.
class CardDemoScreen extends StatelessWidget {
  const CardDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Glass Cards'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic example card
            GlassCard(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Glass Card',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is a semi-transparent card with a frosted glass effect. '
                    'It works well on top of the gradient background.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card with higher opacity
            GlassCard(
              opacity: 0.25, // More opaque
              borderWidth: 2.0,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, size: 36),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                              'This card has higher opacity and thicker border'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card with elevation
            GlassCard(
              elevation: 8.0,
              opacity: 0.2,
              borderRadius: 16.0,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card tapped!')),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Icon(Icons.touch_app, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'Tap Me!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('This card has elevation and is tappable'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card with list items
            GlassCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  GlassListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: const Text('User Profile'),
                    subtitle: const Text('View and edit your profile'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.white24),
                  GlassListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                      child: Icon(Icons.settings),
                    ),
                    title: const Text('Settings'),
                    subtitle: const Text('Adjust app preferences'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.white24),
                  GlassListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                      child: Icon(Icons.help_outline),
                    ),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get assistance with app features'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card with different color
            GlassCard(
              color: Colors.black,
              opacity: 0.1,
              borderColor: Colors.white.withOpacity(0.2),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Glass Card',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This card uses a darker base color for a different look. '
                    'You can customize the opacity, color, and border.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
