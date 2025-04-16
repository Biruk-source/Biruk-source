import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';

// User model to hold profile data
class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String? phone;
  final String? profilePictureUrl;
  final String? bio;
  final bool notificationsEnabled;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    this.phone,
    this.profilePictureUrl,
    this.bio,
    this.notificationsEnabled = true,
    this.preferences = const {},
  });

  // Factory to create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      username: data['username'] ?? 'User',
      email: data['email'] ?? '',
      phone: data['phone'],
      profilePictureUrl: data['profilePictureUrl'],
      bio: data['bio'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      preferences: data['preferences'] ?? {},
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _userProfile;
  bool _isLoading = true;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch user profile from Firestore
  Future<void> _fetchUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userProfile = UserProfile.fromFirestore(doc);
        } else {
          // Fallback if no profile exists
          _userProfile = UserProfile(
            uid: user.uid,
            username: user.displayName ?? 'User',
            email: user.email ?? '',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? Center(
                    child: SpinKitFoldingCube(
                      color: const Color(0xFF00ACC1),
                      size: 50,
                    ),
                  )
                  : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.teal.withOpacity(0.8),
                        pinned: true,
                        expandedHeight: isSmallScreen ? 200 : 250,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            'Profile',
                            style: GoogleFonts.orbitron(
                              fontSize: isSmallScreen ? 20 : 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1516321310764-908d0c1a75be',
                                fit: BoxFit.cover,
                                color: Colors.black.withOpacity(0.5),
                                colorBlendMode: BlendMode.darken,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Container(color: Colors.grey[900]),
                              ),
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(color: Colors.transparent),
                              ),
                            ],
                          ),
                        ),
                        bottom: TabBar(
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.tealAccent,
                          indicatorColor: Colors.tealAccent,
                          tabs: [
                            Tab(text: 'Overview'),
                            Tab(text: 'Settings'),
                            Tab(text: 'Statistics'),
                            Tab(text: 'Activity'),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ProfileOverviewTab(user: _userProfile!),
                              ProfileSettingsTab(user: _userProfile!),
                              ProfileStatisticsTab(user: _userProfile!),
                              ProfileActivityTab(user: _userProfile!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

// Overview Tab: Displays user profile details
class ProfileOverviewTab extends StatelessWidget {
  final UserProfile user;

  const ProfileOverviewTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isSmallScreen ? 50 : 60,
                backgroundImage:
                    user.profilePictureUrl != null
                        ? NetworkImage(user.profilePictureUrl!)
                        : null,
                child:
                    user.profilePictureUrl == null
                        ? Text(
                          user.username[0].toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: isSmallScreen ? 30 : 40,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Username
          Center(
            child: Text(
              user.username,
              style: GoogleFonts.orbitron(
                fontSize: isSmallScreen ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Email
          Center(
            child: Text(
              user.email,
              style: GoogleFonts.montserrat(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bio
          if (user.bio != null)
            Text(
              user.bio!,
              style: GoogleFonts.montserrat(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          // Phone
          if (user.phone != null)
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: user.phone!,
              isSmallScreen: isSmallScreen,
            ),
          const SizedBox(height: 8),
          // Edit Profile Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Placeholder for navigation to edit profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 30,
                  vertical: isSmallScreen ? 10 : 12,
                ),
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Additional Info (e.g., Preferences)
          if (user.preferences.isNotEmpty)
            Card(
              color: Colors.grey[900]!.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferences',
                      style: GoogleFonts.orbitron(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var entry in user.preferences.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: GoogleFonts.montserrat(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: isSmallScreen ? 20 : 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

// Settings Tab: Manage user preferences and account settings
class ProfileSettingsTab extends StatefulWidget {
  final UserProfile user;

  const ProfileSettingsTab({super.key, required this.user});

  @override
  _ProfileSettingsTabState createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.user.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifications Toggle
        SwitchListTile(
          title: Text(
            'Enable Notifications',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Receive updates about your applications',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white70,
            ),
          ),
          value: _notificationsEnabled,
          onChanged: (value) async {
            setState(() => _notificationsEnabled = value);
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.uid)
                  .update({'notificationsEnabled': value});
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating settings: $e')),
                );
              }
            }
          },
          activeColor: Colors.teal,
        ),
        // Privacy Settings
        ListTile(
          leading: Icon(Icons.lock, color: Colors.teal),
          title: Text(
            'Privacy',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Manage data sharing and visibility',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white70,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
          onTap: () {
            // Placeholder for privacy settings navigation
          },
        ),
        // Theme Selection
        ListTile(
          leading: Icon(Icons.color_lens, color: Colors.teal),
          title: Text(
            'Theme',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Customize app appearance',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white70,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
          onTap: () {
            // Placeholder for theme selection navigation
          },
        ),
        // Account Security
        ListTile(
          leading: Icon(Icons.security, color: Colors.teal),
          title: Text(
            'Security',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Update password and authentication',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white70,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
          onTap: () {
            // Placeholder for security settings navigation
          },
        ),
        const SizedBox(height: 24),
        // Delete Account
        Center(
          child: TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: Text(
                        'Delete Account',
                        style: GoogleFonts.orbitron(color: Colors.white),
                      ),
                      content: Text(
                        'Are you sure? This action cannot be undone.',
                        style: GoogleFonts.montserrat(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.montserrat(color: Colors.teal),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.montserrat(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                // Placeholder for account deletion logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion coming soon!'),
                  ),
                );
              }
            },
            child: Text(
              'Delete Account',
              style: GoogleFonts.montserrat(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Statistics Tab: Display user activity metrics
class ProfileStatisticsTab extends StatelessWidget {
  final UserProfile user;

  const ProfileStatisticsTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Statistics',
            style: GoogleFonts.orbitron(
              fontSize: isSmallScreen ? 18 : 20,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey[900]!.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Visa Applications',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: isSmallScreen ? 150 : 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 5,
                            color: Colors.teal,
                            title: 'Approved',
                            radius: isSmallScreen ? 50 : 60,
                            titleStyle: GoogleFonts.montserrat(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 3,
                            color: Colors.yellow,
                            title: 'Pending',
                            radius: isSmallScreen ? 50 : 60,
                            titleStyle: GoogleFonts.montserrat(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.black,
                            ),
                          ),
                          PieChartSectionData(
                            value: 2,
                            color: Colors.red,
                            title: 'Rejected',
                            radius: isSmallScreen ? 50 : 60,
                            titleStyle: GoogleFonts.montserrat(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: isSmallScreen ? 30 : 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey[900]!.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Activity Breakdown',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Placeholder for bar chart or other metrics
                  Text(
                    'Detailed metrics coming soon!',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Activity Tab: Show recent user actions
class ProfileActivityTab extends StatelessWidget {
  final UserProfile user;

  const ProfileActivityTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('activity')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading activity: ${snapshot.error}',
              style: GoogleFonts.montserrat(color: Colors.white70),
            ),
          );
        }
        final activities = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index].data() as Map<String, dynamic>;
            return Card(
              color: Colors.grey[900]!.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.history,
                  color: Colors.teal,
                  size: isSmallScreen ? 20 : 24,
                ),
                title: Text(
                  activity['action'] ?? 'Activity',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  activity['timestamp']?.toDate().toString() ?? 'Unknown time',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
