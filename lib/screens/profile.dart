import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isEditing = false;
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _fetchUserData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _usernameController.text = _userData?['username'] ?? '';
            _phoneController.text = _userData?['phone'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
      setState(() => _isLoading = false);
    }
  }

  // Update user data in Firestore
  Future<void> _updateProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username')));
      return;
    }
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      final RegExp phoneRegex = RegExp(r'^\+?\d{10,15}$');
      if (!phoneRegex.hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid phone number')),
        );
        return;
      }
    }
    _buttonController.forward().then((_) => _buttonController.reverse());
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'phone': phone,
          'email': user.email,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        setState(() {
          _isEditing = false;
          _userData?['username'] = _usernameController.text.trim();
          _userData?['phone'] = phone;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001A1F), Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: SpinKitFoldingCube(
                      color: Color(0xFFFFCA28),
                      size: 50,
                    ),
                  )
                  : FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // App bar
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          pinned: true,
                          leading: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          title: Text(
                            'Your Profile',
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
                        ),
                        // Profile content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Tilt(
                              tiltConfig: const TiltConfig(angle: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900]!.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                      border: const Border(
                                        left: BorderSide(
                                          color: Color(0xFF00ACC1),
                                          width: 4,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00ACC1,
                                          ).withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Avatar and email
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: isSmallScreen ? 40 : 50,
                                              backgroundColor: const Color(
                                                0xFF00ACC1,
                                              ),
                                              child: Text(
                                                _userData?['username']
                                                        ?.substring(0, 1)
                                                        .toUpperCase() ??
                                                    'U',
                                                style: GoogleFonts.montserrat(
                                                  fontSize:
                                                      isSmallScreen ? 30 : 40,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _userData?['email'] ??
                                                        'Loading...',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize:
                                                              isSmallScreen
                                                                  ? 16
                                                                  : 18,
                                                          color: Colors.white,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Member since ${_userData?['createdAt']?.toDate().year ?? 'N/A'}',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize:
                                                              isSmallScreen
                                                                  ? 14
                                                                  : 16,
                                                          color: Colors.white70,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        // Username field
                                        TextField(
                                          controller: _usernameController,
                                          enabled: _isEditing,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[800],
                                            labelText: 'Username',
                                            labelStyle: GoogleFonts.montserrat(
                                              color: const Color(0xFF00ACC1),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.person,
                                              color: Color(0xFF00ACC1),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Phone field
                                        TextField(
                                          controller: _phoneController,
                                          enabled: _isEditing,
                                          keyboardType: TextInputType.phone,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[800],
                                            labelText: 'Phone Number',
                                            labelStyle: GoogleFonts.montserrat(
                                              color: const Color(0xFF00ACC1),
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.phone,
                                              color: Color(0xFF00ACC1),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Edit/Save button
                                        AnimatedBuilder(
                                          animation: _buttonScale,
                                          builder:
                                              (
                                                context,
                                                child,
                                              ) => Transform.scale(
                                                scale: _buttonScale.value,
                                                child: ElevatedButton(
                                                  onPressed:
                                                      _isLoading
                                                          ? null
                                                          : () {
                                                            _buttonController
                                                                .forward()
                                                                .then(
                                                                  (_) =>
                                                                      _buttonController
                                                                          .reverse(),
                                                                );
                                                            if (_isEditing) {
                                                              _updateProfile();
                                                            } else {
                                                              setState(
                                                                () =>
                                                                    _isEditing =
                                                                        true,
                                                              );
                                                            }
                                                          },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF00ACC1),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical:
                                                              isSmallScreen
                                                                  ? 14
                                                                  : 16,
                                                          horizontal:
                                                              isSmallScreen
                                                                  ? 24
                                                                  : 32,
                                                        ),
                                                    elevation: 5,
                                                    shadowColor: const Color(
                                                      0xFF00ACC1,
                                                    ).withOpacity(0.5),
                                                  ),
                                                  child: Text(
                                                    _isEditing
                                                        ? 'Save Changes'
                                                        : 'Edit Profile',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize:
                                                              isSmallScreen
                                                                  ? 16
                                                                  : 18,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
