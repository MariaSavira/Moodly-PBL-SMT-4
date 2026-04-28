import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/Auth_resulth.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // ---------- Stream ----------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ---------- Sign In ----------
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = await _getUserFromFirestore(credential.user!.uid);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Something went wrong. Please try again.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  // ---------- Sign Up ----------
  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // Check if phone number already exists
      final phoneQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber.trim())
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return AuthResult.failure(
          message: 'This email or phone number might already be in use.',
          errorType: AuthErrorType.phoneAlreadyInUse,
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final newUser = UserModel(
        uid: credential.user!.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      await credential.user!.updateDisplayName(fullName.trim());

      return AuthResult.success(newUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Something went wrong. Please try again.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  // ---------- Google Sign In ----------
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure(
          message: 'Google sign in was cancelled.',
          errorType: AuthErrorType.unknown,
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Check if user already exists in Firestore
      final docSnapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!docSnapshot.exists) {
        // New user → save to Firestore
        final newUser = UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        return AuthResult.success(newUser);
      }

      final user = await _getUserFromFirestore(firebaseUser.uid);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Google sign in failed. Please try again.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  // ---------- Forgot Password ----------
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(
        UserModel(uid: '', fullName: '', email: email),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: _mapFirebaseError(e.code),
        errorType: _mapErrorType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Failed to send reset email. Please try again.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  // ---------- Sign Out ----------
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ---------- Helpers ----------
  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    // Fallback from Firebase Auth
    final firebaseUser = _auth.currentUser!;
    return UserModel(
      uid: uid,
      fullName: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Let\'s try that again with a deep breath';
      case 'email-already-in-use':
        return 'This email or phone number might already be in use.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  AuthErrorType _mapErrorType(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthErrorType.invalidCredentials;
      case 'email-already-in-use':
        return AuthErrorType.emailAlreadyInUse;
      case 'network-request-failed':
        return AuthErrorType.networkError;
      case 'too-many-requests':
        return AuthErrorType.tooManyRequests;
      case 'user-not-found':
        return AuthErrorType.userNotFound;
      default:
        return AuthErrorType.unknown;
    }
  }
}