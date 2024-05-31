import 'package:flutter/material.dart';
import 'package:taste_hub/components/custom_back_arrow.dart';
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
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
            TextField(
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
            ),
            const SizedBox(height: 18),
            TextField(
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
            ),
            const SizedBox(height: 18),
            TextField(
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
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isSigningUp = true;
                });
                await _signUpController.signUp(context, _emailController,
                    _passwordController, _usernameController);
                setState(() {
                  isSigningUp = false;
                });
              },
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
            ),
            const SizedBox(height: 12),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OR',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await _signInController.signInWithGoogle(context);
              },
              icon: Image.asset(
                'lib/resources/img/google.png',
                width: 24,
                height: 24,
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
