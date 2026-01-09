import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seekr_ai/features/authentication/presentation/pages/login_page.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isSpookyMode = true; // Local state for the switch

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthCubit>().authService;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ghost Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B19E6)));
          }

          final userData = snapshot.data;
          final String name = userData?['fullName'] ?? "Mysterious Ghost";
          final String email = userData?['email'] ?? authService.currentUser?.email ?? "unknown@void.com";

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // 1. Profile Avatar & Info
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF8B19E6),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.white38, fontSize: 14)),
                
                const SizedBox(height: 40),

                // 2. Daily Usage Limit Card
                _buildUsageCard(),

                const SizedBox(height: 20),

                // 3. Spooky Mode Switch
                _buildSpookySwitch(),

                const Spacer(),

                // 4. Logout Button
                _buildLogoutButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Daily Usage Limit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              Text("10 / 10", style: TextStyle(color: Color(0xFF8B19E6), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 1.0, // 10/10 full
              minHeight: 8,
              backgroundColor: Color(0xFF1A0B2E),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B19E6)),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Your energy is full for today.", style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSpookySwitch() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B4D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          isSpookyMode ? Icons.auto_awesome : Icons.wb_sunny_outlined,
          color: const Color(0xFF8B19E6),
        ),
        title: const Text("Spooky Mode", style: TextStyle(color: Colors.white)),
        subtitle: Text(
          isSpookyMode ? "The void is active" : "The light has returned",
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Switch(
          value: isSpookyMode,
          activeColor: const Color(0xFF8B19E6),
          activeTrackColor: const Color(0xFF8B19E6).withOpacity(0.3),
          inactiveThumbColor: Colors.white70,
          onChanged: (value) {
            setState(() {
              isSpookyMode = value;
            });
            // TODO: Update theme preference in Firestore
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          context.read<AuthCubit>().logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
        child: const Text("Leave the Void (Logout)", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}