import 'package:flutter/material.dart';
import 'package:taste_hub/components/custom_appbar.dart';
import 'package:taste_hub/controller/sign_in_controller.dart';
import 'package:taste_hub/controller/sign_up_controller.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final SignInController _signInController = SignInController();
  final SignUpController _signUpController = SignUpController();
  bool isSigningUp = false;
  bool isSigningUpWithGoogle = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomBackArrow(
        title: '',
        backButton: true,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_add, size: 36, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Create an account',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildUsernameTextField(),
            const SizedBox(height: 18),
            _buildEmailTextField(),
            const SizedBox(height: 18),
            _buildPasswordTextField(),
            const SizedBox(height: 24),
            _buildCreateAccountButton(),
            const SizedBox(height: 12),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            const Center(
              child: Text(
                'OR',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  // Method to build the username text field
  TextField _buildUsernameTextField() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Full Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.person),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.name,
    );
  }

  // Method to build the email text field
  TextField _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.email),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  // Method to build the password text field
  TextField _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.lock),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
    );
  }

  // Method to build the create account button
  ElevatedButton _buildCreateAccountButton() {
    return ElevatedButton(
      onPressed: _signUp,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: const Color.fromARGB(255, 228, 15, 0),
      ),
      child: isSigningUp
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
    );
  }

  // Method to handle the sign up process
  Future<void> _signUp() async {
    setState(() {
      isSigningUp = true;
    });
    await _signUpController.signUp(
        context, _emailController, _passwordController, _usernameController);
    setState(() {
      isSigningUp = false;
    });
  }

  // Method to build the Google sign in button
  ElevatedButton _buildGoogleSignInButton() {
    return ElevatedButton(
      onPressed: _signInWithGoogle,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      child: isSigningUpWithGoogle
          ? const CircularProgressIndicator(
              color: Colors.black,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/google.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
    );
  }

  // Method to handle sign in with Google process
  Future<void> _signInWithGoogle() async {
    setState(() {
      isSigningUpWithGoogle = true;
    });
    await _signInController.signInWithGoogle(context);
    setState(() {
      isSigningUpWithGoogle = false;
    });
  }
}
