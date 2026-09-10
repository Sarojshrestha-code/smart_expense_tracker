import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final UserService _userService =
      UserService();

  final AuthService _authService =
      AuthService();

  Map<String, dynamic>? _profile;

  bool _isLoading = true;
  bool _isUploading = false;
  bool _isDeleting = false;

  final DateFormat _dateFormat =
      DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
          await _userService.getUserProfile();

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
          content: Text(
            'Unable to load profile: $e',
          ),
        ),
      );
    }
  }

  Future<void> _uploadPhoto() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _userService.uploadProfilePhoto();

      await _loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains(
            'No image selected',
          )) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to upload photo: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final passwordController =
        TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                decoration:
                    const InputDecoration(
                  labelText:
                      'Enter your password',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (passwordController
                    .text
                    .trim()
                    .isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter your password.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete Account',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
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
          builder: (context) =>
              const LoginScreen(),
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
          content: Text(
            'Unable to delete account: $e',
          ),
        ),
      );
    }
  }

  String _getFirstName() {
    return _profile?['firstName']
            ?.toString() ??
        'User';
  }

  String _getLastName() {
    return _profile?['lastName']
            ?.toString() ??
        '';
  }

  String _getGender() {
    return _profile?['gender']
            ?.toString() ??
        'Not specified';
  }

  String _getDateOfBirth() {
    final value =
        _profile?['dateOfBirth']?.toString();

    if (value == null || value.isEmpty) {
      return 'Not specified';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return 'Not specified';
    }

    return _dateFormat.format(date);
  }

  String _getEmail() {
    return _profile?['email']
            ?.toString() ??
        _auth.currentUser?.email ??
        '';
  }

  String _getPhotoUrl() {
    return _profile?['photoUrl']
            ?.toString() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _getPhotoUrl();

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
                // Profile Header
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            photoUrl.isNotEmpty
                                ? NetworkImage(
                                    photoUrl,
                                  )
                                : null,
                        child: photoUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                              )
                            : null,
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 19,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 19,
                                  ),
                            onPressed:
                                _isUploading
                                    ? null
                                    : _uploadPhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: Text(
                    '${_getFirstName()} ${_getLastName()}'
                        .trim(),
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
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Personal Information
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                        ),
                        title:
                            const Text('First Name'),
                        subtitle:
                            Text(_getFirstName()),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.person,
                        ),
                        title:
                            const Text('Last Name'),
                        subtitle:
                            Text(_getLastName()),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.wc,
                        ),
                        title:
                            const Text('Gender'),
                        subtitle:
                            Text(_getGender()),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                        ),
                        title: const Text(
                          'Date of Birth',
                        ),
                        subtitle:
                            Text(_getDateOfBirth()),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                        ),
                        title:
                            const Text('Email'),
                        subtitle:
                            Text(_getEmail()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Settings
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: Icon(
                      ThemeService
                              .instance
                              .isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    title:
                        const Text('Dark Mode'),
                    subtitle: Text(
                      ThemeService
                              .instance
                              .isDarkMode
                          ? 'Dark theme enabled'
                          : 'Light theme enabled',
                    ),
                    trailing: Switch(
                      value: ThemeService
                          .instance
                          .isDarkMode,
                      onChanged: (value) async {
                        await ThemeService
                            .instance
                            .setDarkMode(value);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Account
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
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                        ),
                        title:
                            const Text('Logout'),
                        onTap: _logout,
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Permanently delete your account',
                        ),
                        trailing:
                            _isDeleting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(),
                                  )
                                : null,
                        onTap: _isDeleting
                            ? null
                            : _deleteAccount,
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