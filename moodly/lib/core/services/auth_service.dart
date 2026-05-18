import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_result.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;

    await _googleSignIn.initialize();

    _isGoogleInitialized = true;
  }

  Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'user';

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return 'user';

    final data = doc.data()!;
    return (data['role'] as String?) ?? 'user';
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return AuthResult.failure(
          message: 'Akun tidak ditemukan.',
          errorType: AuthErrorType.userNotFound,
        );
      }

      final user = await _getUserFromFirestore(firebaseUser.uid);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (_) {
      return AuthResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final cleanFullName = fullName.trim();
      final cleanEmail = email.trim();
      final cleanPhoneNumber = phoneNumber.trim();

      final phoneQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: cleanPhoneNumber)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return AuthResult.failure(
          message: 'Nomor telepon sudah digunakan.',
          errorType: AuthErrorType.phoneAlreadyInUse,
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password.trim(),
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return AuthResult.failure(
          message: 'Gagal membuat akun. Silakan coba lagi.',
          errorType: AuthErrorType.unknown,
        );
      }

      await firebaseUser.updateDisplayName(cleanFullName);

      final newUser = UserModel(
        uid: firebaseUser.uid,
        fullName: cleanFullName,
        email: cleanEmail,
        phoneNumber: cleanPhoneNumber,
        createdAt: DateTime.now(),
        isEmailVerified: firebaseUser.emailVerified,
        role: 'user',
      );

      await _saveUserToFirestore(
        firebaseUser: firebaseUser,
        fallbackUser: newUser,
        phoneNumber: cleanPhoneNumber,
      );

      return AuthResult.success(newUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (_) {
      return AuthResult.failure(
        message: 'Terjadi kesalahan. Silakan coba lagi.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return AuthResult.failure(
          message:
              'Token Google tidak ditemukan. Coba cek konfigurasi SHA-1/SHA-256 dan google-services.json.',
          errorType: AuthErrorType.unknown,
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return AuthResult.failure(
          message: 'Login Google gagal. Silakan coba lagi.',
          errorType: AuthErrorType.unknown,
        );
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        isEmailVerified: true,
        role: 'user',
      );

      await _saveUserToFirestore(
        firebaseUser: firebaseUser,
        fallbackUser: userModel,
      );

      final savedUser = await _getUserFromFirestore(firebaseUser.uid);
      return AuthResult.success(savedUser);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return AuthResult.failure(
          message: 'Login Google dibatalkan.',
          errorType: AuthErrorType.unknown,
        );
      }

      return AuthResult.failure(
        message: 'Login Google gagal: ${e.description ?? e.code.name}',
        errorType: AuthErrorType.unknown,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Login Google gagal. Silakan coba lagi. Detail: $e',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<AuthResult> signInWithFacebook() async {
    try {
      await FacebookAuth.instance.logOut();

      final loginResult = await FacebookAuth.instance.login(
        permissions: const ['public_profile'],
        loginBehavior: LoginBehavior.nativeWithFallback,
      );

      if (loginResult.status != LoginStatus.success) {
        return AuthResult.failure(
          message: 'Login Facebook dibatalkan atau gagal.',
          errorType: AuthErrorType.unknown,
        );
      }

      final accessToken = loginResult.accessToken;

      if (accessToken == null) {
        return AuthResult.failure(
          message: 'Token Facebook tidak ditemukan.',
          errorType: AuthErrorType.unknown,
        );
      }

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return AuthResult.failure(
          message: 'Login Facebook gagal.',
          errorType: AuthErrorType.unknown,
        );
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        isEmailVerified: firebaseUser.emailVerified,
        role: 'user',
      );

      await _saveUserToFirestore(
        firebaseUser: firebaseUser,
        fallbackUser: userModel,
      );

      final savedUser = await _getUserFromFirestore(firebaseUser.uid);
      return AuthResult.success(savedUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Login Facebook gagal. Detail: $e',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      return AuthResult.success(
        UserModel(
          uid: '',
          fullName: '',
          email: email.trim(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (_) {
      return AuthResult.failure(
        message: 'Gagal mengirim email reset password. Silakan coba lagi.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return AuthResult.failure(
          message: 'Tidak ada akun yang sedang login.',
          errorType: AuthErrorType.userNotFound,
        );
      }

      await user.sendEmailVerification();

      return AuthResult.success(
        UserModel(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          isEmailVerified: user.emailVerified,
          role: 'user',
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (_) {
      return AuthResult.failure(
        message: 'Gagal mengirim verifikasi email. Silakan coba lagi.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<AuthResult> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return AuthResult.failure(
          message: 'Tidak ada akun yang sedang login.',
          errorType: AuthErrorType.userNotFound,
        );
      }

      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return AuthResult.failure(
          message: 'Akun tidak ditemukan.',
          errorType: AuthErrorType.userNotFound,
        );
      }

      if (!refreshedUser.emailVerified) {
        return AuthResult.failure(
          message:
              'Email belum diverifikasi. Buka email Anda lalu klik tautan verifikasi.',
          errorType: AuthErrorType.emailNotVerified,
        );
      }

      await _firestore.collection('users').doc(refreshedUser.uid).set({
        'isEmailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final userModel = await _getUserFromFirestore(refreshedUser.uid);

      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (_) {
      return AuthResult.failure(
        message: 'Gagal mengecek verifikasi email. Silakan coba lagi.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  Future<User?> signInAnonymouslyForTesting() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      FacebookAuth.instance.logOut(),
    ]);

    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {
      // Diabaikan supaya logout Firebase tetap jalan.
    }
  }

  Future<void> _saveUserToFirestore({
    required User firebaseUser,
    required UserModel fallbackUser,
    String? phoneNumber,
  }) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await userRef.get();
    final oldData = doc.data();

    final oldNickname = oldData?['nickname'];
    final oldAvatarId = oldData?['avatarId'];
    final oldStatus = oldData?['status'];
    final oldCurrentRoomId = oldData?['currentRoomId'];

    await userRef.set({
      'uid': firebaseUser.uid,
      'fullName': fallbackUser.fullName,
      'email': fallbackUser.email,
      'phoneNumber': phoneNumber ?? fallbackUser.phoneNumber,
      'photoUrl': fallbackUser.photoUrl,
      'isEmailVerified':
          firebaseUser.emailVerified || fallbackUser.isEmailVerified,
      'nickname': oldNickname,
      'avatarId': oldAvatarId,
      'status': oldStatus ?? 'idle',
      'currentRoomId': oldCurrentRoomId,
      'role': oldData?['role'] ?? fallbackUser.role,
      'createdAt': oldData?['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }

    final firebaseUser = _auth.currentUser;

    return UserModel(
      uid: uid,
      fullName: firebaseUser?.displayName ?? '',
      email: firebaseUser?.email ?? '',
      photoUrl: firebaseUser?.photoURL,
      isEmailVerified: firebaseUser?.emailVerified ?? false,
      role: 'user',
    );
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terdaftar dengan metode login lain.';
      case 'credential-already-in-use':
        return 'Credential ini sudah digunakan oleh akun lain.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan di Firebase.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  AuthErrorType _mapErrorType(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthErrorType.userNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthErrorType.invalidCredentials;
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return AuthErrorType.emailAlreadyInUse;
      case 'network-request-failed':
        return AuthErrorType.networkError;
      case 'too-many-requests':
        return AuthErrorType.tooManyRequests;
      default:
        return AuthErrorType.unknown;
    }
  }
}