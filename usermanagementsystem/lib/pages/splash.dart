import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usermanagementsystem/cubit/userdetails_cubit.dart';
import 'package:usermanagementsystem/pages/homepage.dart';
import 'package:usermanagementsystem/pages/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool splashLoading = true;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  void splashDelay() async {
    // Start animations
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    _progressController.forward();
    
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      splashLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    splashDelay();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? _userdetails = context.watch<UserDetailsCubit>().state;

    return splashLoading
        ? Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32), 
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon with animations
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.people_alt_rounded,
                                size: 60,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // App title with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "User Management",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "System",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Animated progress indicator
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Container(
                              width: 200,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 200 * _progressAnimation.value,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Text(
                              "Loading...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        : _userdetails != null
            ? const HomePage()
            : const LoginPage();
  }
}