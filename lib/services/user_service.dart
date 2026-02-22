import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/special_prayer.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// 📥 Get User Profile
  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUserId == null) return null;

      DocumentSnapshot doc = await _users.doc(currentUserId).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        // Create default profile if not exists
        return await _createDefaultProfile();
      }
    } catch (e) {
      debugPrint("❌ Error getting user profile: $e");
      return null;
    }
  }

  /// 📡 Get User Profile Stream (Real-time)
  Stream<UserProfile?> getUserProfileStream() {
    if (currentUserId == null) return Stream.value(null);
    return _users.doc(currentUserId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  /// 🆕 Create Default Profile
  Future<UserProfile?> _createDefaultProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      UserProfile newProfile = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
      );

      await _users.doc(user.uid).set(newProfile.toMap());
      return newProfile;
    } catch (e) {
      debugPrint("❌ Error creating default profile: $e");
      return null;
    }
  }

  /// 💾 Update User Profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _users.doc(profile.id).update(profile.toMap());
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
      throw e;
    }
  }

  /// ⚙️ Update Settings (Dark Mode / Notifications)
  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      if (currentUserId == null) return;
      await _users.doc(currentUserId).update({'settings': newSettings});
    } catch (e) {
      debugPrint("❌ Error updating settings: $e");
    }
  }

  /// 🖼️ Update Profile Avatar (Asset Path)
  Future<void> updateAvatar(String assetPath) async {
    try {
      if (currentUserId == null) return;
      await _users.doc(currentUserId).update({'profilePhotoUrl': assetPath});
    } catch (e) {
      debugPrint("❌ Error updating avatar: $e");
    }
  }

  /// 🗑️ Delete Account
  Future<void> deleteAccount() async {
    try {
      if (currentUserId == null) return;
      
      // 1. Delete User Data from Firestore
      await _users.doc(currentUserId).delete();
      
      // 2. Delete Auth Account
      await _auth.currentUser?.delete();
      
    } catch (e) {
      debugPrint("❌ Error deleting account: $e");
      throw e;
    }
  }

  /// 🕌 --- Special Prayer Features --- 🕌

  /// 💾 Save Special Prayer
  Future<void> saveSpecialPrayer(SpecialPrayer prayer) async {
    try {
      if (currentUserId == null) return;
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('special_prayers')
          .doc(prayer.id)
          .set(prayer.toMap());
    } catch (e) {
      debugPrint("❌ Error saving special prayer: $e");
    }
  }

  /// 📡 Get Special Prayers Stream
  Stream<List<SpecialPrayer>> getSpecialPrayersStream() {
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('special_prayers')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SpecialPrayer.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// 🗑️ Delete Special Prayer
  Future<void> deleteSpecialPrayer(String prayerId) async {
    try {
      if (currentUserId == null) return;
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('special_prayers')
          .doc(prayerId)
          .delete();
    } catch (e) {
      debugPrint("❌ Error deleting special prayer: $e");
    }
  }
}
