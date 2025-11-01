import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue app bar
        foregroundColor: Colors.white, // White icons/text
        title: const Text('Patient Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              'Register Patient',
              Icons.person_add,
              '/registration',
            ),
            _buildMenuCard(
              context,
              'Record Vitals',
              Icons.monitor_heart,
              '/vitals',
            ),
            _buildMenuCard(
              context,
              'Patient Listing',
              Icons.list_alt,
              '/patient-listing',
            ),
            _buildMenuCard(
              context,
              'Assessments',
              Icons.assignment,
              '/assessments',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      color: Colors.white, // White card background
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2), // Blue shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.blue[100]!, // Blue border
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Light blue icon background
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.blue, // Blue icon
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSubtitle(route),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6), // Semi-transparent black
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getSubtitle(String route) {
  switch (route) {
    case '/registration':
      return 'Add new patients';
    case '/vitals':
      return 'Record height & weight';
    case '/patient-listing':
      return 'View all patients';
    case '/assessments': // Add this case
      return 'Patient assessments';
    default:
      return 'Patient assessments';
  }
}

  void _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}