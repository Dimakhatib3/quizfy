import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'generate_quiz_page.dart';
import 'profile_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "User";

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    setState(() {
      username = refreshedUser?.displayName ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF3F3B0),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, left: 30),
                      child: Text(
                        "Hello $username",
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFE6C7E8),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 120,
                      left: 30,
                      right: 30,
                    ),
                    child: Column(
                      children: [
                        _buildMenuCard(
                          text: "Generate\na quiz",
                          height: 95,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GenerateQuizPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildMenuCard(
                          text: "History",
                          height: 85,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildMenuCard(
                          text: "Profile",
                          height: 85,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                  username: username,
                                  email: user?.email ?? "",
                                ),
                              ),
                            );

                            await loadUsername();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Image.asset('assets/cat.png', width: 400),
                  Container(
                    width: 140,
                    height: 8,
                    color: const Color(0xFFE6C7E8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuCard({
    required String text,
    required double height,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3B0),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 24,
                color: Color(0xFFD7B6D9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}