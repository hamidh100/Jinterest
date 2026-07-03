import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _identifier = '';
  String _password = '';
  String _fullname = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleSignup() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      final authProvider = context.read<AuthProvider>();
      bool success = await authProvider.signup(
        identifier: _identifier,
        password: _password,
        fullname: _fullname,
      );

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorToast(authProvider.errorMessage ?? 'Signup failed');
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text(
          'Account created successfully! You are now logged in.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /*void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signup Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }*/

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.image, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                'Join Jinterest',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Full name field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name required';
                  }
                  if (value.length < 2) {
                    return 'Full name must be at least 2 characters';
                  }
                  return null;
                },
                onSaved: (value) => _fullname = value ?? '',
              ),
              const SizedBox(height: 16),

              // Email or Phone field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email or Phone Number',
                  hintText: 'example@email.com or 09xxxxxxxxx',
                  prefixIcon: const Icon(Icons.mail_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email or phone number required';
                  }
                  // Check if it's email format
                  if (value.contains('@')) {
                    return Validators.validateEmail(value);
                  }
                  // Check if it's phone format
                  return Validators.validatePhone(value);
                },
                onSaved: (value) => _identifier = value ?? '',
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Min 8 chars, uppercase, lowercase, digit',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: _obscurePassword,
                validator: Validators.validatePassword,
                onSaved: (value) => _password = value ?? '',
              ),
              const SizedBox(height: 32),

              // Signup button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
