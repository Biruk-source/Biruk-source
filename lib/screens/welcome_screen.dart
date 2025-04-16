import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';

import 'package:connectivity_plus/connectivity_plus.dart'; // For network checks

/// WelcomeScreen for Global Reach Consultancy
/// Displays an interactive landing page with animations, accessibility features, and user authentication
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Animation controllers for smooth UI transitions
  late AnimationController _fadeController;
  late AnimationController _globeController;
  late AnimationController _ctaController;
  late AnimationController _shimmerController;

  // Animation values
  late Animation<double> _fadeAnimation;
  late Animation<double> _globeRotation;
  late Animation<double> _ctaScale;
  late Animation<double> _shimmerAnimation;

  // State variables
  bool _isHighContrast = false;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isDarkMode = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    // Setup animations for a polished UI
    _setupAnimations();
    // Check network connectivity
    _checkConnectivity();
    // Initialize app state
    _initialize();
  }

  /// Sets up animation controllers and tweens for fade, globe rotation, CTA scale, and shimmer effects
  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _globeRotation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(CurvedAnimation(parent: _globeController, curve: Curves.linear));
    _ctaScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctaController, curve: Curves.easeInOut));
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  /// Checks network connectivity and updates UI accordingly
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
    });
    if (!_hasInternet) {
      _showNoInternetSnackBar();
    }
  }

  /// Initializes Firebase authentication and user preferences
  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _isHighContrast = prefs.getBool('high_contrast') ?? false;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _isLoggedIn = FirebaseAuth.instance.currentUser != null;
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Initialization failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
      }
    }
  }

  /// Saves user preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', _isHighContrast);
    await prefs.setBool('dark_mode', _isDarkMode);
  }

  /// Displays an error SnackBar with a custom message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// Displays a no-internet SnackBar with a retry option
  void _showNoInternetSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'No internet connection. Some features may be limited.',
        ),
        backgroundColor: Colors.orangeAccent,
        action: SnackBarAction(label: 'Retry', onPressed: _checkConnectivity),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up animation controllers to prevent memory leaks
    _fadeController.dispose();
    _globeController.dispose();
    _ctaController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isWeb = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _isHighContrast ? Colors.black : const Color(0xFF001A1F),
              _isHighContrast
                  ? Colors.grey[800]!
                  : const Color(0xFF004D40).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/coffee_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? _buildLoadingIndicator()
                  : Stack(
                    children: [
                      // Background Rive animation (stars/particles)
                      _buildBackgroundAnimation(),
                      // Main content with bounce scroll
                      _buildMainContent(isSmallScreen, isWeb),
                      // Accessibility toggles
                      _buildAccessibilityToggles(isSmallScreen),
                    ],
                  ),
        ),
      ),
    );
  }

  /// Builds a loading indicator using SpinKit
  Widget _buildLoadingIndicator() {
    return const Center(
      child: SpinKitFoldingCube(color: Color(0xFFFFCA28), size: 50),
    );
  }

  /// Builds the background Rive animation
  Widget _buildBackgroundAnimation() {
    return Opacity(
      opacity: 0.3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00ACC1), Color(0xFFFFCA28)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  /// Builds the main content with a CustomScrollView
  Widget _buildMainContent(bool isSmallScreen, bool isWeb) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isSmallScreen, isWeb),
                  const SizedBox(height: 24),
                  _buildGlobeSection(isSmallScreen),
                  const SizedBox(height: 24),
                  _buildMissionCard(isSmallScreen),
                  const SizedBox(height: 24),
                  _buildStatsCard(isSmallScreen),
                  const SizedBox(height: 24),
                  _buildLocationCard(isSmallScreen),
                  const SizedBox(height: 24),
                  _buildCtaButton(isSmallScreen),
                  const SizedBox(height: 24),
                  _buildContactButton(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds accessibility toggles for high contrast and dark mode
  Widget _buildAccessibilityToggles(bool isSmallScreen) {
    return Positioned(
      top: 16,
      right: 16,
      child: Row(
        children: [
          _buildToggleButton(
            icon: _isHighContrast ? Icons.contrast : Icons.brightness_6,
            onTap: () {
              setState(() {
                _isHighContrast = !_isHighContrast;
                _savePreferences();
              });
            },
            label: 'Toggle High Contrast',
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
            onTap: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
                _savePreferences();
              });
            },
            label: 'Toggle Dark Mode',
          ),
        ],
      ),
    );
  }

  /// Builds a toggle button for accessibility features
  Widget _buildToggleButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Tilt(
      tiltConfig: const TiltConfig(angle: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          label: label,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00ACC1), width: 2),
            ),
            child: Icon(icon, color: const Color(0xFFFFCA28), size: 24),
          ),
        ),
      ),
    );
  }

  /// Builds the header with logo and title
  Widget _buildHeader(bool isSmallScreen, bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Global Reach Consultancy',
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00ACC1).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Text(
                'Visa & Education Experts',
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 14 : 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        if (isWeb)
          Tilt(
            tiltConfig: const TiltConfig(angle: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900]!.withOpacity(0.8),
                    border: Border.all(
                      color: const Color(0xFF00ACC1),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 80,
                    height: 80,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.school,
                          color: Color(0xFFFFCA28),
                          size: 40,
                        ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the rotating globe section with parallax tilt
  Widget _buildGlobeSection(bool isSmallScreen) {
    return Tilt(
      tiltConfig: const TiltConfig(angle: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.85),
              border: Border.all(color: const Color(0xFF00ACC1), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00ACC1).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _globeRotation,
                  builder:
                      (context, child) => Transform.rotate(
                        angle: _globeRotation.value * 3.14 / 180,
                        child: Image.asset(
                          'assets/images/globe.jpg',
                          height: isSmallScreen ? 150 : 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: isSmallScreen ? 150 : 200,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.public,
                                  color: Color(0xFFFFCA28),
                                  size: 80,
                                ),
                              ),
                        ),
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Gateway to the World',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Expert visa and education solutions for your global dreams.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the mission card with glassmorphic style
  Widget _buildMissionCard(bool isSmallScreen) {
    return Tilt(
      tiltConfig: const TiltConfig(angle: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.8),
              border: Border.all(color: const Color(0xFFFFCA28), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Mission',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Empowering your future with seamless visa and education services, blending global expertise with Ethiopian hospitality.',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildServiceChip(
                      'Visa Services',
                      Icons.flight,
                      isSmallScreen,
                    ),
                    const SizedBox(width: 8),
                    _buildServiceChip('Education', Icons.school, isSmallScreen),
                    const SizedBox(width: 8),
                    _buildServiceChip(
                      'Consulting',
                      Icons.support_agent,
                      isSmallScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the stats card with a pie chart
  Widget _buildStatsCard(bool isSmallScreen) {
    return Tilt(
      tiltConfig: const TiltConfig(angle: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.8),
              border: Border.all(color: const Color(0xFF00ACC1), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Impact',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: isSmallScreen ? 100 : 120,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 90,
                          color: const Color(0xFFFFCA28),
                          title: 'Visas 90%',
                          radius: isSmallScreen ? 50 : 60,
                          titleStyle: GoogleFonts.montserrat(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: 10,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          title: 'Admissions 10%',
                          radius: isSmallScreen ? 40 : 50,
                          titleStyle: GoogleFonts.montserrat(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: const Color.fromARGB(255, 18, 197, 203),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: isSmallScreen ? 20 : 30,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Over 90% visa success rate and 40% education placements globally.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the location card with a contact button
  Widget _buildLocationCard(bool isSmallScreen) {
    return Tilt(
      tiltConfig: const TiltConfig(angle: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.8),
              border: Border.all(color: const Color(0xFFFFCA28), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visit Us',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Golagole Side Building, 3rd Floor, Office 25, Addis Ababa, Ethiopia',
                  style: GoogleFonts.montserrat(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed:
                        _hasInternet
                            ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contact us at +251-0928211778',
                                  ),
                                ),
                              );
                            }
                            : null,
                    icon: const Icon(Icons.location_on, color: Colors.black),
                    label: Text(
                      'Get Directions',
                      style: GoogleFonts.montserrat(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCA28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 8 : 12,
                        horizontal: isSmallScreen ? 16 : 24,
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

  /// Builds the call-to-action button with a shimmer effect
  Widget _buildCtaButton(bool isSmallScreen) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_ctaScale, _shimmerAnimation]),
        builder:
            (context, child) => Transform.scale(
              scale: _ctaScale.value,
              child: GestureDetector(
                onTapDown: (_) => _ctaController.forward(),
                onTapUp: (_) {
                  _ctaController.reverse();
                  Navigator.pushNamed(
                    context,
                    _isLoggedIn ? '/home' : '/login',
                  );
                },
                onTapCancel: () => _ctaController.reverse(),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                        horizontal: isSmallScreen ? 24 : 32,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00ACC1), Color(0xFFFFCA28)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00ACC1).withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        _isLoggedIn ? 'Go to Dashboard' : 'Get Started',
                        style: GoogleFonts.montserrat(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder:
                              (context, child) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                    begin: Alignment(
                                      _shimmerAnimation.value - 1,
                                      0,
                                    ),
                                    end: Alignment(
                                      _shimmerAnimation.value + 1,
                                      0,
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

  /// Builds the contact button with haptic feedback
  Widget _buildContactButton(bool isSmallScreen) {
    return Center(
      child: Tilt(
        tiltConfig: const TiltConfig(angle: 6),
        child: ElevatedButton.icon(
          onPressed:
              _hasInternet
                  ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Call us at 0928211778')),
                    );
                  }
                  : null,
          icon: const Icon(Icons.phone, color: Colors.black),
          label: Text(
            'Contact Us',
            style: GoogleFonts.montserrat(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.black, // Fixed color (replaced Tennisball)
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00ACC1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 8 : 12,
              horizontal: isSmallScreen ? 16 : 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a service chip with a neon border
  Widget _buildServiceChip(String label, IconData icon, bool isSmallScreen) {
    return Tilt(
      tiltConfig: const TiltConfig(angle: 6),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isSmallScreen ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00ACC1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFCA28),
              size: isSmallScreen ? 16 : 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
