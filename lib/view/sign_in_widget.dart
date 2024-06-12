import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/controller/sign_in_controller.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final SignInController _signInController = SignInController();
  bool isSigning = false;
  bool isSigningWithGoogle = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildSubHeader(),
              const SizedBox(height: 24),
              _buildEmailTextField(),
              const SizedBox(height: 18),
              _buildPasswordTextField(),
              const SizedBox(height: 24),
              _buildSignInButton(),
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
              const SizedBox(height: 12),
              const Spacer(),
              _buildSignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the header of the sign-in page
  Row _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.restaurant_menu, size: 36, color: Colors.red),
        SizedBox(width: 8),
        Text(
          'Sign In',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }

  // Builds the sub-header with app name
  Container _buildSubHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'TasteHUB - Meals you\'ll love!',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 228, 15, 0),
        ),
      ),
    );
  }

  // Builds the email text field for inputting email
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

  // Builds the password text field for inputting password
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

  // Builds the sign-in button
  ElevatedButton _buildSignInButton() {
    return ElevatedButton(
      onPressed: _signIn,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: const Color.fromARGB(255, 228, 15, 0),
      ),
      child: isSigning
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
    );
  }

  // Method to handle the sign-in process
  Future<void> _signIn() async {
    setState(() {
      isSigning = true;
    });
    await _signInController.signIn(
        context, _emailController, _passwordController);
    setState(() {
      isSigning = false;
    });
  }

  // Builds the Google sign-in button
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
      child: isSigningWithGoogle
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

  // Method to handle sign-in with Google process
  Future<void> _signInWithGoogle() async {
    setState(() {
      isSigningWithGoogle = true;
    });
    await _signInController.signInWithGoogle(context);
    setState(() {
      isSigningWithGoogle = false;
    });
  }

  // Builds the sign-up prompt text with navigation to sign-up screen
  Widget _buildSignUpPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: "Don't have an account yet? ",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: 'Create one!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, '/register');
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
