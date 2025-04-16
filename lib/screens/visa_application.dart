import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisaApplicationsScreen extends StatefulWidget {
  const VisaApplicationsScreen({super.key});

  @override
  State<VisaApplicationsScreen> createState() => _VisaApplicationsScreenState();
}

class _VisaApplicationsScreenState extends State<VisaApplicationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot appSnapshot =
            await _firestore
                .collection('users')
                .doc(user.uid)
                .collection('applications')
                .orderBy('createdAt', descending: true)
                .get();
        _applications =
            appSnapshot.docs
                .map(
                  (doc) => {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  },
                )
                .toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching applications: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visa Applications',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _applications.isEmpty
              ? Center(
                child: Text(
                  'No applications found.',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: _applications.length,
                itemBuilder: (context, index) {
                  final app = _applications[index];
                  return ListTile(
                    title: Text(
                      app['title'] ?? 'Visa Application',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Status: ${app['status'] ?? 'Pending'}',
                      style: GoogleFonts.montserrat(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/application_details',
                        arguments: app['id'],
                      );
                    },
                  );
                },
              ),
    );
  }
}
