import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isHighContrast = false;
  bool _isLoading = false;
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
    _loadPreferences();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHighContrast = prefs.getBool('high_contrast') ?? false;
    });
  }

  // Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', _isHighContrast);
  }

  // Toggle high contrast mode
  void _toggleHighContrast() {
    setState(() {
      _isHighContrast = !_isHighContrast;
      _savePreferences();
    });
  }

  // Handle logout
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
      _buttonController.forward().then((_) => _buttonController.reverse());
      setState(() => _isLoading = true);
      try {
        await _auth.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
                            'Settings',
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
                        // Settings content
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
                                      color:
                                          _isHighContrast
                                              ? Colors.black.withOpacity(0.8)
                                              : Colors.grey[900]!.withOpacity(
                                                0.7,
                                              ),
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
                                        // Accessibility settings
                                        Text(
                                          'Accessibility',
                                          style: GoogleFonts.montserrat(
                                            fontSize: isSmallScreen ? 18 : 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SwitchListTile(
                                          title: Text(
                                            'High Contrast Mode',
                                            style: GoogleFonts.montserrat(
                                              fontSize: isSmallScreen ? 16 : 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          value: _isHighContrast,
                                          onChanged:
                                              (value) => _toggleHighContrast(),
                                          activeColor: const Color(0xFF00ACC1),
                                          thumbColor: WidgetStatePropertyAll(
                                            _isHighContrast
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Account settings
                                        Text(
                                          'Account',
                                          style: GoogleFonts.montserrat(
                                            fontSize: isSmallScreen ? 18 : 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        AnimatedBuilder(
                                          animation: _buttonScale,
                                          builder:
                                              (
                                                context,
                                                child,
                                              ) => Transform.scale(
                                                scale: _buttonScale.value,
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.logout,
                                                    color: Colors.redAccent,
                                                  ),
                                                  title: Text(
                                                    'Logout',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize:
                                                              isSmallScreen
                                                                  ? 16
                                                                  : 18,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                  ),
                                                  onTap: () {
                                                    _buttonController
                                                        .forward()
                                                        .then(
                                                          (_) =>
                                                              _buttonController
                                                                  .reverse(),
                                                        );
                                                    _logout();
                                                  },
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
