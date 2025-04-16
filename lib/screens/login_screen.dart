import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math' as math;
import 'dart:ui'; // For BackdropFilter

// LoginScreen: A fluid, watery login interface with email, phone, and Google auth
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Controllers for input and animations
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  bool _isLoading = false;
  bool _isDarkTheme = true; // Theme toggle state
  bool _obscurePassword = true; // Password visibility toggle
  late AnimationController _globeController;
  late AnimationController _panelController;
  late AnimationController _buttonController;
  late Animation<double> _globeRotation;
  late Animation<Offset> _panelSlide;
  late Animation<double> _buttonScale;
  late Animation<double> _waveEffect; // For watery panel animation

  @override
  void initState() {
    super.initState();

    // Globe rotation animation for a dynamic GIF effect
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 200),
    )..repeat();
    _globeRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _globeController, curve: Curves.linear));

    // Sliding panel animation with watery wave effect
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeOutSine),
    );
    _waveEffect = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
    );
    _panelController.forward();

    // Button scale animation for ripple feedback
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _globeController.dispose();
    _panelController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Sign in with email and password
  Future<void> _signInWithEmail() async {
    // Validate inputs
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Animate button
    _buttonController.forward().then((_) => _buttonController.reverse());

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message ?? "Authentication failed"}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Register with email and password
  Future<void> _registerWithEmail() async {
    // Validate inputs
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Animate button
    _buttonController.forward().then((_) => _buttonController.reverse());

    setState(() => _isLoading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message ?? "Registration failed"}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Sign in with phone number
  Future<void> _signInWithPhone() async {
    // Validate phone number
    if (!_isValidPhoneNumber(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid phone number (e.g., +1234567890)',
          ),
        ),
      );
      return;
    }

    // Animate button
    _buttonController.forward().then((_) => _buttonController.reverse());

    setState(() => _isLoading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message ?? "Authentication failed"}'),
            ),
          );
        },
        timeout: const Duration(seconds: 60),
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _verificationId = verificationId);
          _showOtpDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    // Animate button
    _buttonController.forward().then((_) => _buttonController.reverse());

    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate phone number format
  bool _isValidPhoneNumber(String phone) {
    final RegExp phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }

  // Show OTP dialog for phone auth
  void _showOtpDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF00ACC1), width: 2),
            ),
            title: Text(
              'Enter OTP',
              style: TextStyle(
                color: _isDarkTheme ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: _isDarkTheme ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'OTP',
                labelStyle: const TextStyle(color: Color(0xFF80DEEA)),
                filled: true,
                fillColor: _isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: _verificationId!,
                      smsCode: otpController.text,
                    );
                    await _auth.signInWithCredential(credential);
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Invalid OTP: $e')));
                  }
                },
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Color(0xFFFFCA28)),
                ),
              ),
            ],
          ),
    );
  }

  // Toggle theme
  void _toggleTheme() {
    setState(() => _isDarkTheme = !_isDarkTheme);
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with a fluid gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isDarkTheme
                        ? [const Color(0xFF002027), const Color(0xFF004D40)]
                        : [Colors.blue[100]!, Colors.green[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animated globe GIF
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedBuilder(
              animation: _globeRotation,
              builder:
                  (context, _) => Transform.rotate(
                    angle: _globeRotation.value,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/globe.png',
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
            ),
          ),
          // Sliding login panel with watery effect
          AnimatedBuilder(
            animation: _waveEffect,
            builder:
                (context, child) => SlideTransition(
                  position: _panelSlide,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                _isDarkTheme
                                    ? Colors.grey[900]!.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF00ACC1),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00ACC1,
                                ).withOpacity(0.3 * _waveEffect.value),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Theme toggle at top
                              Align(
                                alignment: Alignment.topCenter,
                                child: IconButton(
                                  icon: Icon(
                                    _isDarkTheme
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                    color:
                                        _isDarkTheme
                                            ? Colors.yellow
                                            : Colors.grey[800],
                                  ),
                                  onPressed: _toggleTheme,
                                  tooltip: 'Toggle Theme',
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Title with neumorphic shadow
                              Text(
                                'Visa & Education Consultant',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isDarkTheme
                                          ? const Color.fromARGB(
                                            255,
                                            53,
                                            26,
                                            26,
                                          )
                                          : const Color.fromARGB(
                                            255,
                                            19,
                                            14,
                                            14,
                                          ),
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFF00ACC1),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Passport motif
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      _isDarkTheme
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFCA28),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.book,
                                      color: Color(0xFFFFCA28),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Passport to Your Future',
                                      style: TextStyle(
                                        color:
                                            _isDarkTheme
                                                ? Colors.white
                                                : Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Email input
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color:
                                      _isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      _isDarkTheme
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF80DEEA),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFF80DEEA),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF00ACC1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF00ACC1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Password input
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  color:
                                      _isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      _isDarkTheme
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF80DEEA),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Color(0xFF80DEEA),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFF80DEEA),
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF00ACC1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF00ACC1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Email sign-in button
                              AnimatedBuilder(
                                animation: _buttonScale,
                                builder:
                                    (context, child) => Transform.scale(
                                      scale: _buttonScale.value,
                                      child: GestureDetector(
                                        onTap:
                                            _isLoading
                                                ? null
                                                : _signInWithEmail,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF00ACC1),
                                                Color(0xFF26A69A),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF00ACC1,
                                                ).withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child:
                                                _isLoading
                                                    ? const SpinKitRipple(
                                                      color: Colors.white,
                                                      size: 40,
                                                    )
                                                    : const Text(
                                                      'Sign In with Email',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 12),

                              // Email registration button

                              // Phone input
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'New to our services? ',
                                    style: TextStyle(
                                      color:
                                          _isDarkTheme
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xFFFFCA28),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
          // Google Sign-In floating button at bottom
          Positioned(
            bottom: 30,
            left:
                MediaQuery.of(context).size.width / 2 -
                80, // Center horizontally
            child: AnimatedBuilder(
              animation: _buttonScale,
              builder:
                  (context, child) => Transform.scale(
                    scale: _buttonScale.value,
                    child: GestureDetector(
                      onTap: _isLoading ? null : _signInWithGoogle,
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _isDarkTheme ? Colors.white : Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00ACC1).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.g_mobiledata,
                              color: Colors.black,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Google Sign-In',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitCubeGrid(color: Colors.white, size: 50),
              ),
            ),
        ],
      ),
    );
  }
}
