import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile.dart';
import 'dart:ui';
import 'login_screen.dart';
import 'Setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  late AnimationController _menuController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _staggerAnimation;
  late Animation<double> _menuAnimation;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isHighContrast = false;
  bool _isMenuOpen = false;
  String _selectedMenuItem = 'Dashboard';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOutCubic),
    );
    _menuAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
    );
    _loadPreferences();
    _fetchData();
    _fadeController.forward();
    _staggerController.forward();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHighContrast = prefs.getBool('high_contrast') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', _isHighContrast);
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _userData = userDoc.data() as Map<String, dynamic>;
        }
        QuerySnapshot appSnapshot =
            await _firestore
                .collection('users')
                .doc(user.uid)
                .collection('applications')
                .orderBy('createdAt', descending: true)
                .limit(5)
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
        QuerySnapshot notifSnapshot =
            await _firestore
                .collection('users')
                .doc(user.uid)
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .limit(3)
                .get();
        _notifications =
            notifSnapshot.docs
                .map(
                  (doc) => {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  },
                )
                .toList();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Confirm Logout',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to end your session?',
              style: GoogleFonts.montserrat(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.montserrat(color: const Color(0xFFFFCA28)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isWeb = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                _isHighContrast
                    ? [Colors.black, Colors.grey[800]!]
                    : [const Color(0xFF001A1F), const Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? Center(
                    child: SpinKitFoldingCube(
                      color: const Color(0xFFFFCA28),
                      size: 50,
                    ),
                  )
                  : Stack(
                    children: [
                      Row(
                        children: [
                          if (isWeb) _buildFixedSidebar(),
                          Expanded(
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  pinned: true,
                                  expandedHeight: isSmallScreen ? 150 : 200,
                                  flexibleSpace: FlexibleSpaceBar(
                                    title: Text(
                                      'Visa Dashboard',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isSmallScreen ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0xFF00ACC1),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    background: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?fit=crop&w=1920&q=80',
                                          fit: BoxFit.cover,
                                          color: Colors.black.withOpacity(0.3),
                                          colorBlendMode: BlendMode.darken,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: Colors.grey[900],
                                                  ),
                                        ),
                                        BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 3,
                                            sigmaY: 3,
                                          ),
                                          child: Container(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    IconButton(
                                      icon: Icon(
                                        _isHighContrast
                                            ? Icons.contrast
                                            : Icons.brightness_6,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isHighContrast = !_isHighContrast;
                                          _savePreferences();
                                        });
                                      },
                                      tooltip: 'Toggle Contrast',
                                    ),
                                    if (!isWeb)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.menu,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isMenuOpen = !_isMenuOpen;
                                            if (_isMenuOpen) {
                                              _menuController.forward();
                                            } else {
                                              _menuController.reverse();
                                            }
                                          });
                                        },
                                        tooltip: 'Toggle Menu',
                                      ),
                                  ],
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildWelcomeSection(isSmallScreen),
                                          const SizedBox(height: 24),
                                          _buildVisaProgressCard(isSmallScreen),
                                          const SizedBox(height: 24),
                                          _buildApplicationsPanel(
                                            isSmallScreen,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildNotificationsCard(
                                            isSmallScreen,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildRecommendationsCard(
                                            isSmallScreen,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildProfileCard(isSmallScreen),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!isWeb && _isMenuOpen) _buildCollapsibleDrawer(),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildFixedSidebar() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.8),
        border: const Border(
          right: BorderSide(color: Color(0xFF00ACC1), width: 2),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Visa Consultancy',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.tealAccent.withOpacity(0.5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    setState(() => _selectedMenuItem = 'Dashboard');
                  },
                  isSelected: _selectedMenuItem == 'Dashboard',
                ),
                _buildMenuItem(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  isSelected: _selectedMenuItem == 'Profile',
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/settings',
                    ).then((value) => setState(() {}));
                  },
                  isSelected: _selectedMenuItem == 'Settings',
                ),
              ],
            ),
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _logout,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCollapsibleDrawer() {
    return AnimatedBuilder(
      animation: _menuAnimation,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(_menuAnimation.value * 300, 0),
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.9),
                border: const Border(
                  right: BorderSide(color: Color(0xFF00ACC1), width: 2),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.teal.shade800],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.tealAccent,
                              child: Text(
                                _userData?['username']
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: GoogleFonts.montserrat(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userData?['username'] ?? 'Consultant',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _userData?['email'] ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildMenuItem(
                              icon: Icons.dashboard,
                              title: 'Dashboard',
                              onTap: () {
                                setState(() {
                                  _selectedMenuItem = 'Dashboard';
                                  _isMenuOpen = false;
                                  _menuController.reverse();
                                });
                              },
                              isSelected: _selectedMenuItem == 'Dashboard',
                            ),
                            _buildMenuItem(
                              icon: Icons.person,
                              title: 'Profile',
                              onTap: () {
                                setState(() {
                                  _selectedMenuItem = 'Profile';
                                  _isMenuOpen = false;
                                  _menuController.reverse();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile coming soon!'),
                                  ),
                                );
                              },
                              isSelected: _selectedMenuItem == 'Profile',
                            ),
                            _buildMenuItem(
                              icon: Icons.settings,
                              title: 'Settings',
                              onTap: () {
                                setState(() {
                                  _selectedMenuItem = 'Settings';
                                  _isMenuOpen = false;
                                  _menuController.reverse();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Settings coming soon!'),
                                  ),
                                );
                              },
                              isSelected: _selectedMenuItem == 'Settings',
                            ),
                          ],
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () {
                          _logout();
                          setState(() {
                            _isMenuOpen = false;
                            _menuController.reverse();
                          });
                        },
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = false;
                          _menuController.reverse();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder:
          (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: ListTile(
              leading: Icon(
                icon,
                color:
                    color ??
                    (isSelected ? const Color(0xFFFFCA28) : Colors.white70),
              ),
              title: Text(
                title,
                style: GoogleFonts.montserrat(
                  color:
                      color ??
                      (isSelected ? const Color(0xFFFFCA28) : Colors.white70),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                _scaleController.forward().then(
                  (_) => _scaleController.reverse(),
                );
                onTap();
              },
              selected: isSelected,
              selectedTileColor: Colors.teal.withOpacity(0.2),
            ),
          ),
    );
  }

  Widget _buildWelcomeSection(bool isSmallScreen) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/welcome'),
      child: Tilt(
        tiltConfig: const TiltConfig(angle: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    _isHighContrast
                        ? Colors.black.withOpacity(0.8)
                        : Colors.grey[900]!.withOpacity(0.7),
                border: const Border(
                  left: BorderSide(color: Color(0xFF00ACC1), width: 4),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00ACC1).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_userData?['username'] ?? 'Consultant'}',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    semanticsLabel:
                        'Welcome, ${_userData?['username'] ?? 'Consultant'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Navigate your global aspirations with precision.',
                    style: GoogleFonts.montserrat(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisaProgressCard(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _staggerAnimation.value) * 50),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/visa_progress'),
                child: Tilt(
                  tiltConfig: const TiltConfig(angle: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              _isHighContrast
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.grey[900]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00ACC1).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visa Application Progress',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
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
                                      value: 30,
                                      color: const Color(0xFFFFCA28),
                                      title: 'Initiated',
                                      radius: isSmallScreen ? 50 : 60,
                                      titleStyle: GoogleFonts.montserrat(
                                        fontSize: isSmallScreen ? 12 : 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: 20,
                                      color: const Color(0xFF00ACC1),
                                      title: 'Processing',
                                      radius: isSmallScreen ? 50 : 60,
                                      titleStyle: GoogleFonts.montserrat(
                                        fontSize: isSmallScreen ? 12 : 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: 50,
                                      color: Colors.grey[700]!,
                                      title: 'Pending',
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildActionButton(
                                  title: 'View Details',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Details coming soon!'),
                                      ),
                                    );
                                  },
                                  isSmallScreen: isSmallScreen,
                                ),
                                _buildActionButton(
                                  title: 'Update Status',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Update coming soon!'),
                                      ),
                                    );
                                  },
                                  isSmallScreen: isSmallScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildApplicationsPanel(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _staggerAnimation.value) * 50),
              child: ExpansionTile(
                title: Text(
                  'Recent Applications',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                collapsedBackgroundColor: Colors.grey[900]!.withOpacity(0.7),
                backgroundColor: Colors.grey[900]!.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                children:
                    _applications.isEmpty
                        ? [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No applications found.',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ]
                        : _applications.map((app) {
                          return ListTile(
                            title: Text(
                              app['title'] ?? 'Visa Application',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              'Status: ${app['status'] ?? 'Pending'}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFFFFCA28),
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/application_details',
                                arguments: app['id'],
                              );
                            },
                          );
                        }).toList(),
              ),
            ),
          ),
    );
  }

  Widget _buildNotificationsCard(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _staggerAnimation.value) * 50),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Tilt(
                  tiltConfig: const TiltConfig(angle: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              _isHighContrast
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.grey[900]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00ACC1).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _notifications.isEmpty
                                ? Text(
                                  'No new notifications.',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                )
                                : Column(
                                  children:
                                      _notifications.take(3).map((notif) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.notifications,
                                                color: Color(0xFFFFCA28),
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  notif['message'] ??
                                                      'New update available',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                            const SizedBox(height: 16),
                            _buildActionButton(
                              title: 'View All',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notifications coming soon!'),
                                  ),
                                );
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildRecommendationsCard(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _staggerAnimation.value) * 50),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/recommendations'),
                child: Tilt(
                  tiltConfig: const TiltConfig(angle: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              _isHighContrast
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.grey[900]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00ACC1).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommendations',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Based on your profile, we suggest exploring these visa options:',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRecommendationItem(
                              title: 'Skilled Worker Visa',
                              description:
                                  'Ideal for professionals with job offers.',
                              isSmallScreen: isSmallScreen,
                            ),
                            _buildRecommendationItem(
                              title: 'Student Visa',
                              description:
                                  'Perfect for pursuing higher education abroad.',
                              isSmallScreen: isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildActionButton(
                              title: 'Explore More',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Recommendations coming soon!',
                                    ),
                                  ),
                                );
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildRecommendationItem({
    required String title,
    required String description,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFFFFCA28), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _staggerAnimation.value) * 50),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Tilt(
                  tiltConfig: const TiltConfig(angle: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              _isHighContrast
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.grey[900]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00ACC1).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Overview',
                              style: GoogleFonts.montserrat(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileRow(
                              icon: Icons.person,
                              label: 'Username',
                              value: _userData?['username'] ?? 'N/A',
                              isSmallScreen: isSmallScreen,
                            ),
                            const SizedBox(height: 8),
                            _buildProfileRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: _userData?['email'] ?? 'N/A',
                              isSmallScreen: isSmallScreen,
                            ),
                            const SizedBox(height: 8),
                            _buildProfileRow(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: _userData?['phone'] ?? 'Not provided',
                              isSmallScreen: isSmallScreen,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildActionButton(
                                  title: 'Edit Profile',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Edit Profile coming soon!',
                                        ),
                                      ),
                                    );
                                  },
                                  isSmallScreen: isSmallScreen,
                                ),
                                _buildActionButton(
                                  title: 'Security',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Security settings coming soon!',
                                        ),
                                      ),
                                    );
                                  },
                                  isSmallScreen: isSmallScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFFCA28),
          size: isSmallScreen ? 20 : 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder:
          (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: () {
                _scaleController.forward().then(
                  (_) => _scaleController.reverse(),
                );
                onTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ACC1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 12,
                  horizontal: isSmallScreen ? 16 : 20,
                ),
                elevation: 5,
                shadowColor: const Color(0xFF00ACC1).withOpacity(0.5),
              ),
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
    );
  }
}
