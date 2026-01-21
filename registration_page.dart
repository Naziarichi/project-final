import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'input_field.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool _isLoading = false;
  final _supabase = Supabase.instance.client;
  String? statusMsg;

  final RegExp emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  final RegExp passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');

  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (username.isEmpty) {
      setState(() => statusMsg = "Username cannot be empty");
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() => statusMsg = "Invalid email format");
      return;
    }
    if (!passRegex.hasMatch(password)) {
      setState(() => statusMsg = "Password: 6+ chars with letters & numbers");
      return;
    }
    if (password != confirmPassController.text.trim()) {
      setState(() => statusMsg = "Passwords do not match!");
      return;
    }

    setState(() {
      _isLoading = true;
      statusMsg = null;
    });

    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;

      if (user != null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'username': username,
          'email': email,
        });

        setState(() => statusMsg = "Registration successful!");

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registered Successfully! Redirecting to Login..."),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        });
      }
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
    usernameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
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
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text("👤", style: TextStyle(fontSize: 50)),
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputField(
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          label: "Username",
                          hint: "Enter username",
                          icon: Icons.person,
                          errorText: null,
                        ),
                        const SizedBox(height: 15),
                        InputField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          label: "Email",
                          hint: "Enter email",
                          icon: Icons.email,
                          errorText: null,
                        ),
                        const SizedBox(height: 15),
                        InputField(
                          controller: passController,
                          keyboardType: TextInputType.visiblePassword,
                          label: "Password",
                          hint: "Enter password",
                          icon: Icons.lock,
                          errorText: null,
                        ),
                        const SizedBox(height: 15),
                        InputField(
                          controller: confirmPassController,
                          keyboardType: TextInputType.visiblePassword,
                          label: "Confirm Password",
                          hint: "Re-enter password",
                          icon: Icons.lock_outline,
                          errorText: null,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : register,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Register",
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
                                color: statusMsg == "Registration successful!"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Already have an account? Login",
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
