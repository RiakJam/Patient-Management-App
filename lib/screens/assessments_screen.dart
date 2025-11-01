import 'package:flutter/material.dart';

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text('Patient Assessments'),
        backgroundColor: Colors.blue, // Blue app bar
        foregroundColor: Colors.white, // White icons/text
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Assessment Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAssessmentCard(
                    context,
                    'General Assessment',
                    Icons.assignment,
                    'Form A',
                    Colors.blue, // Blue color
                    '/general-assessment',
                  ),
                  _buildAssessmentCard(
                    context,
                    'Overweight Assessment',
                    Icons.monitor_weight,
                    'Form B',
                    Colors.blue, // Blue color
                    '/overweight-assessment',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    Color color,
    String route,
  ) {
    return Card(
      color: Colors.white, // White card background
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2), // Blue shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.blue[100]!, // Light blue border
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
              subtitle,
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
}