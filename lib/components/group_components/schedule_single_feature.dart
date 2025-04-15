import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SoloScheduleScreen extends StatelessWidget {
  const SoloScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F12),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00C2FF)),
                  const SizedBox(width: 8),
                  Text(
                    'Schedule Complete',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00C2FF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Weekend Adventure',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'April 14, 2025',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildInfoTile(
                    icon: Icons.access_time,
                    title: 'All-day schedule',
                    trailing: '5 Activities',
                  ),
                  _buildInfoTile(
                    icon: Icons.directions_walk,
                    title: 'Transportation',
                    trailing: 'Walking, Rideshare',
                  ),
                  _buildInfoTile(
                    icon: Icons.wallet,
                    title: 'Budget',
                    trailing: '\$120',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Schedule Summary',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEventCard(
                    icon: '🍽️',
                    time: '9:00 AM',
                    title: 'Breakfast at  Cafe',
                    subtitle: 'Trendy breakfast spot for pastries & coffee.',
                  ),
                  _buildEventCard(
                    icon: '🌿',
                    time: '11:30 AM',
                    title: 'City Botanical Gardens',
                    subtitle: 'Explore rare flora and beautiful walking paths.',
                  ),
                  _buildEventCard(
                    icon: '🎨',
                    time: '2:00 PM',
                    title: 'Modern Art Museum',
                    subtitle:
                        'Digital installations and future vision exhibits.',
                  ),
                  _buildEventCard(
                    icon: '🌅',
                    time: '5:30 PM',
                    title: 'Sunset Beach Walk',
                    subtitle: 'Coastal trail with skyline views.',
                  ),
                  _buildEventCard(
                    icon: '🦞',
                    time: '7:30 PM',
                    title: 'Horizon Restaurant',
                    subtitle: 'Seafood & cocktails on rooftop.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Home',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00C2FF)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          Text(trailing, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String icon,
    required String time,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF00C2FF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
