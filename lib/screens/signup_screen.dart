import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isDarkTheme = true;
  bool _obscurePassword = true;
  late AnimationController _panelController;
  late AnimationController _buttonController;
  late Animation<Offset> _panelSlide;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    // Initialize animations
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
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _panelController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _panelController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User user, String username) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Sign up with email
  Future<void> _signUp() async {
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
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username')));
      return;
    }
    _buttonController.forward().then((_) => _buttonController.reverse());
    setState(() => _isLoading = true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        await _saveUserData(
          userCredential.user!,
          _usernameController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message ?? "Sign-up failed"}'),
          action: SnackBarAction(label: 'Retry', onPressed: _signUp),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _toggleTheme() {
    setState(() => _isDarkTheme = !_isDarkTheme);
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isDarkTheme
                        ? [Colors.teal.shade900, Colors.blueGrey.shade900]
                        : [Colors.teal.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Sliding sign-up panel
          SlideTransition(
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
                      border: Border.all(color: Colors.teal, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Theme toggle
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              _isDarkTheme ? Icons.light_mode : Icons.dark_mode,
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
                        // Title
                        Text(
                          'Join Visa Consultancy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isDarkTheme ? Colors.white : Colors.black,
                            shadows: const [
                              Shadow(
                                color: Colors.tealAccent,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Username input
                        TextField(
                          controller: _usernameController,
                          style: TextStyle(
                            color: _isDarkTheme ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                _isDarkTheme
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            labelText: 'Username',
                            labelStyle: const TextStyle(
                              color: Colors.tealAccent,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.tealAccent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Email input
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: _isDarkTheme ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                _isDarkTheme
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: Colors.tealAccent,
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.tealAccent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Password input
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: _isDarkTheme ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                _isDarkTheme
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Colors.tealAccent,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.tealAccent,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.tealAccent,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign-up button
                        AnimatedBuilder(
                          animation: _buttonScale,
                          builder:
                              (context, child) => Transform.scale(
                                scale: _buttonScale.value,
                                child: GestureDetector(
                                  onTap: _isLoading ? null : _signUp,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.teal,
                                          Colors.tealAccent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.tealAccent.withOpacity(
                                            0.5,
                                          ),
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
                                                'Sign Up',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                        const SizedBox(height: 12),
                        // Login prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color:
                                    _isDarkTheme
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
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
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitCubeGrid(color: Colors.tealAccent, size: 50),
              ),
            ),
        ],
      ),
    );
  }
}
