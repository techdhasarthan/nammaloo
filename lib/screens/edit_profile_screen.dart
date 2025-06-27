import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_toilet_finder/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User firebaseUser;

  const EditProfileScreen({required this.firebaseUser, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _prefController;
  late TextEditingController _bioController;
  bool _loading = false;
  bool _fetching = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _prefController = TextEditingController();
    _bioController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _fetching = true);
    try {
      final userData = await ApiService.fetchUserProfile(
        widget.firebaseUser.uid,
      );
      if (userData != null) {
        _nameController.text =
            userData['name'] ?? widget.firebaseUser.displayName ?? '';
        _prefController.text = userData['preferences'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        // If photoUrl exists and is not the same as firebaseUser.photoURL, use it
        // (Assume photoUrl is a network URL, not a file path)
        if (userData['photoUrl'] != null &&
            userData['photoUrl'] != widget.firebaseUser.photoURL) {
          // Only set if not empty and not default
          // You may want to add more logic if you support local file paths
        }
      } else {
        _nameController.text = widget.firebaseUser.displayName ?? '';
      }
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => _fetching = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ApiService.updateUserProfile(
        googleId: widget.firebaseUser.uid,
        name: _nameController.text.trim(),
        preferences: _prefController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: _selectedImage != null
            ? _selectedImage!.path
            : widget.firebaseUser.photoURL ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.firebaseUser.email ?? 'Not available';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColorDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _loading || _fetching
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white24
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (widget.firebaseUser.photoURL != null
                                        ? NetworkImage(
                                            widget.firebaseUser.photoURL!,
                                          )
                                        : const AssetImage('assets/avatar.png')
                                              as ImageProvider),
                            ),
                          ),
                          Positioned(
                            bottom: -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.primaryColor,
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (non-editable)
                    Center(
                      child: Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Name Field
                    Text(
                      'Name',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          errorStyle: const TextStyle(height: 0.6),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Preferences Field
                    Text(
                      'Preferences',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                      child: TextFormField(
                        controller: _prefController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Enter your preferences',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bio Field
                    Text(
                      'Bio',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                      child: TextFormField(
                        controller: _bioController,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tell us about yourself...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'SAVE CHANGES',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
