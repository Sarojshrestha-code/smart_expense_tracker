import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  Future<void> createUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    required String email,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'email': email,
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadProfilePhoto() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image == null) {
      throw Exception('No image selected');
    }

    final storageRef = _storage
        .ref()
        .child('profile_images')
        .child('${user.uid}.jpg');

    await storageRef.putData(
      await image.readAsBytes(),
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    final downloadUrl =
        await storageRef.getDownloadURL();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'photoUrl': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  Future<void> deleteAccount({
    required String password,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    if (user.email == null) {
      throw Exception(
        'Unable to verify your account credentials.',
      );
    }

    // Re-authentication is required by Firebase
    // before permanently deleting an account.
    final credential =
        EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(
      credential,
    );

    // Delete profile photo if it exists.
    try {
      await _storage
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg')
          .delete();
    } catch (_) {
      // Ignore if no profile image exists.
    }

    // Delete Firestore user profile.
    await _firestore
        .collection('users')
        .doc(user.uid)
        .delete();

    // Delete Firebase Authentication account.
    await user.delete();
  }
}