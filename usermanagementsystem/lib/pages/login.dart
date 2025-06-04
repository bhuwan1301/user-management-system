import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:usermanagementsystem/cubit/userdetails_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? usernameerror;
  String? passworderror;
  String? loginerror;
  bool isLoading = false;
  bool _obscurePassword = true;

  void handleLogin() async {
    setState(() {
      isLoading = true;
    });

    print("LOGGING IN");
    bool haserror = false;

    if (_usernameController.text.isEmpty) haserror = true;
    if (_passwordController.text.isEmpty) haserror = true;

    if (haserror) {
      setState(() {
        usernameerror = _usernameController.text.isEmpty
            ? "Please enter your username"
            : null;
        passworderror = _passwordController.text.isEmpty
            ? "Please enter your password"
            : null;
        isLoading = false;
      });

      return;
    }

    setState(() {
      usernameerror = null;
      passworderror = null;
      loginerror = null;
    });

    try {
      final url = Uri.parse('https://dummyjson.com/user/login');
      final loginResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (loginResponse.statusCode == 200) {
        print("LOGIN SUCCESS");
        final data = jsonDecode(loginResponse.body);
        print("DATA: ${data.toString()}");
        setState(() {
          loginerror = null;
        });
        final profileURL = Uri.parse(
          'https://dummyjson.com/users/${data['id']}',
        );
        final userpostsURL = Uri.parse(
          'https://dummyjson.com/users/${data['id']}/posts',
        );
        final profileResponse = await http.get(profileURL);
        final userpostsResponse = await http.get(userpostsURL);
        final Map<String, dynamic> profile = jsonDecode(profileResponse.body);
        final Map<String, dynamic> posts = jsonDecode(userpostsResponse.body);
        profile['posts'] = posts;

        print("PROFILE: ${profile}");
        context.read<UserDetailsCubit>().updateData(profile);
        Get.offAllNamed('/home');
      } else if (loginResponse.statusCode == 400) {
        print("INVALID CRED");
        setState(() {
          loginerror = "Invalid Credentials";
          isLoading = false;
        });
      } else {
        print("failed");
        setState(() {
          loginerror = "Failed to login";
          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to collect user infor.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }finally{
      setState(() {
         isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      size: 50,
                      color: Color(0xFF4CAF50),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Welcome Text
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Sign in to continue",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),

                        if (usernameerror != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              usernameerror!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),

                        if (passworderror != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              passworderror!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        if (loginerror != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    loginerror!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
