import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisaRecommendationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> visaTypes = [
    {
      'type': 'Tourist Visa',
      'eligibility':
          'For tourism purposes only. Applicant must have a valid passport and sufficient funds.',
      'documents': [
        'Passport',
        'Proof of funds',
        'Travel itinerary',
        'Hotel reservation',
      ],
      'processingTime': '2-4 weeks',
      'fees': '\$100',
      'validity': 'Up to 6 months',
    },
    {
      'type': 'Student Visa',
      'eligibility':
          'For students accepted into a recognized educational institution. Requires proof of enrollment and financial support.',
      'documents': [
        'Passport',
        'Acceptance letter',
        'Financial statements',
        'Health insurance',
      ],
      'processingTime': '4-6 weeks',
      'fees': '\$200',
      'validity': 'Duration of study program',
    },
    {
      'type': 'Work Visa',
      'eligibility':
          'For individuals with a job offer from a company in the host country. Requires sponsorship from the employer.',
      'documents': [
        'Passport',
        'Job offer letter',
        'Employment contract',
        'Qualification certificates',
      ],
      'processingTime': '6-8 weeks',
      'fees': '\$300',
      'validity': 'Up to 2 years, renewable',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, IconData> sectionIcons = {
      'Eligibility': Icons.person,
      'Required Documents': Icons.description,
      'Processing Time': Icons.timer,
      'Fees': Icons.monetization_on,
      'Validity': Icons.calendar_today,
    };

    Widget _buildSection(String title, Widget content) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(sectionIcons[title], color: Colors.teal, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  content,
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildVisaTile(Map<String, dynamic> visa) {
      return ExpansionTile(
        title: Text(
          visa['type'],
          style: GoogleFonts.orbitron(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Eligibility',
                  Text(
                    visa['eligibility'],
                    style: GoogleFonts.montserrat(color: Colors.white70),
                  ),
                ),
                _buildSection(
                  'Required Documents',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        visa['documents']
                            .map<Widget>(
                              (doc) => Text(
                                '• $doc',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white70,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                _buildSection(
                  'Processing Time',
                  Text(
                    visa['processingTime'],
                    style: GoogleFonts.montserrat(color: Colors.white70),
                  ),
                ),
                _buildSection(
                  'Fees',
                  Text(
                    visa['fees'],
                    style: GoogleFonts.montserrat(color: Colors.white70),
                  ),
                ),
                _buildSection(
                  'Validity',
                  Text(
                    visa['validity'],
                    style: GoogleFonts.montserrat(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {}, // Placeholder for apply action
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Apply Now',
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget _buildPersonalizedRecommendation() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.teal.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Recommendation',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your profile, we recommend the Student Visa.',
                  style: GoogleFonts.montserrat(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {}, // Placeholder for profile update
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Profile',
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recommendations',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            _buildPersonalizedRecommendation(),
            ...visaTypes.map((visa) => _buildVisaTile(visa)).toList(),
          ],
        ),
      ),
    );
  }
}
