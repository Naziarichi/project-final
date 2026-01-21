import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'input_field.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _isLoading = false;

  final _supabase = Supabase.instance.client;
  String? statusMsg;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      statusMsg = null;
    });

    try {
      await _supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      setState(() => statusMsg = "Logged in successfully!");
      // ❌ No Navigator here. AuthGate will switch to Dashboard automatically.
    } on AuthApiException catch (e) {
      setState(() => statusMsg = e.message);
    } catch (_) {
      setState(() => statusMsg = "Something went wrong. Try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text("💊", style: TextStyle(fontSize: 60)),
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        InputField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          label: "Email",
                          hint: "Enter your email",
                          icon: Icons.email,
                          errorText: null,
                        ),
                        const SizedBox(height: 20),
                        InputField(
                          controller: passController,
                          keyboardType: TextInputType.visiblePassword,
                          label: "Password",
                          hint: "Enter your password",
                          icon: Icons.lock,
                          errorText: null,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                        if (statusMsg != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              statusMsg!,
                              style: TextStyle(
                                color: statusMsg == "Logged in successfully!"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistrationPage(),
                            ),
                          ),
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(color: Color(0xFF667EEA)),
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
      ),
    );
  }
}
