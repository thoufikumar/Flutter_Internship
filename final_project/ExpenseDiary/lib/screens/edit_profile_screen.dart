// edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _localImageFile;
  String? _uploadedImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _uploadedImageUrl = user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;

      setState(() {
        _localImageFile = File(picked.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image pick failed: $e')),
      );
    }
  }

  Future<String?> _uploadToFirebase(File file) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final fileExt = path.extension(file.path);
      final storagePath = 'profile_images/${user.uid}${fileExt}';

      final ref = FirebaseStorage.instance.ref().child(storagePath);

      final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask.whenComplete(() => null);

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // bubble up
      rethrow;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user logged in')));
      return;
    }

    try {
      String? downloadUrl = _uploadedImageUrl;

      // 1) If user picked a new local image -> upload and get URL
      if (_localImageFile != null) {
        downloadUrl = await _uploadToFirebase(_localImageFile!);
      }

      // 2) Update auth profile
      await user.updateDisplayName(_nameController.text.trim());
      if (downloadUrl != null) {
        await user.updatePhotoURL(downloadUrl);
      }

      // 3) Refresh local cached url and UI
      setState(() {
        _uploadedImageUrl = downloadUrl;
        _localImageFile = null;
      });

      // 4) Optionally reload user to get latest data
      await user.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildProfileAvatar() {
    final displayImage = _localImageFile != null
        ? FileImage(_localImageFile!)
        : (_uploadedImageUrl != null ? NetworkImage(_uploadedImageUrl!) : const AssetImage('assets/images/profile.jpg')) as ImageProvider;

    return CircleAvatar(
      radius: 50,
      backgroundImage: displayImage,
      backgroundColor: Colors.blueGrey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF4F9792),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          if (_localImageFile != null || _uploadedImageUrl != null)
                            ListTile(
                              leading: const Icon(Icons.delete_forever, color: Colors.red),
                              title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _localImageFile = null;
                                  _uploadedImageUrl = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                child: _buildProfileAvatar(),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F9792),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
