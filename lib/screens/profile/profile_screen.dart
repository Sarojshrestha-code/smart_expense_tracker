 import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';
import '../reports/data_export_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final UserService _userService = UserService();

  final AuthService _authService = AuthService();

  Map<String, dynamic>? _profile;

  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ------------------------------------------------------------
  // LOAD PROFILE
  // ------------------------------------------------------------

  Future<void> _loadProfile() async {
    try {
      final profile = await _userService.getUserProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load profile: $e'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // GET USER FIRST NAME
  // ------------------------------------------------------------

  String _getFirstName() {
    final firstName = _profile?['firstName']?.toString().trim();

    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }

    return 'User';
  }

  // ------------------------------------------------------------
  // GET USER LAST NAME
  // ------------------------------------------------------------

  String _getLastName() {
    return _profile?['lastName']?.toString().trim() ?? '';
  }

  // ------------------------------------------------------------
  // GET FULL NAME
  // ------------------------------------------------------------

  String _getFullName() {
    final firstName = _getFirstName();
    final lastName = _getLastName();

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isEmpty) {
      return 'User';
    }

    return fullName;
  }

  // ------------------------------------------------------------
  // GET EMAIL
  // ------------------------------------------------------------

  String _getEmail() {
    final profileEmail =
        _profile?['email']?.toString().trim() ?? '';

    if (profileEmail.isNotEmpty) {
      return profileEmail;
    }

    return _auth.currentUser?.email ?? '';
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to logout: $e'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // DELETE ACCOUNT
  // ------------------------------------------------------------

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action cannot be undone. '
                'Your profile, expenses and account '
                'will be permanently deleted.',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (passwordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter your password.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    if (!mounted) {
      passwordController.dispose();
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _userService.deleteAccount(
        password: passwordController.text.trim(),
      );

      passwordController.dispose();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      passwordController.dispose();

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete account: $e'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ==================================================
                // PROFILE HEADER
                // ==================================================

                const SizedBox(height: 10),

                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: Text(
                    _getFullName(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    _getEmail(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // SETTINGS
                // ==================================================

                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [
                      // ------------------------------
                      // DARK MODE
                      // ------------------------------

                      ListTile(
                        leading: Icon(
                          ThemeService.instance.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        title: const Text('Dark Mode'),
                        subtitle: Text(
                          ThemeService.instance.isDarkMode
                              ? 'Dark theme enabled'
                              : 'Light theme enabled',
                        ),
                        trailing: Switch(
                          value: ThemeService.instance.isDarkMode,
                          onChanged: (value) async {
                            await ThemeService.instance
                                .setDarkMode(value);

                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ),

                      const Divider(height: 1),

                      // ------------------------------
                      // DATA EXPORT
                      // ------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.insert_chart_outlined,
                        ),
                        title: const Text(
                          'Data Export & Reports',
                        ),
                        subtitle: const Text(
                          'Export expenses as PDF or CSV',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DataExportScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // ACCOUNT
                // ==================================================

                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [
                      // ------------------------------
                      // LOGOUT
                      // ------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                        ),
                        title: const Text('Logout'),
                        onTap: _isDeleting ? null : _logout,
                      ),

                      const Divider(height: 1),

                      // ------------------------------
                      // DELETE ACCOUNT
                      // ------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Permanently delete your account',
                        ),
                        trailing: _isDeleting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(),
                              )
                            : null,
                        onTap:
                            _isDeleting ? null : _deleteAccount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}