import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive state for loading status
  var isLoading = false.obs;

  // Reactive user object to track current Firebase Auth user
  late Rxn<User> firebaseUser;

  // Reactive user model object to hold Firestore user profile data
  Rxn<UserModel> userModel = Rxn<UserModel>();

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rxn<User>(_auth.currentUser);
    // Bind stream so firebaseUser updates whenever auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());
    // Listen to firebaseUser changes and auto-navigate
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } else {
      await fetchUserProfile(user.uid);
      Get.offAllNamed(AppRoutes.home);
    }
  }

  // Fetch user details from Cloud Firestore users/{uid}
  Future<void> fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        userModel.value =
            UserModel.fromJson(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      Get.snackbar(
        'Profile Error',
        'Could not load user profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    if (name.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter your full name');
      return;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Validation Error', 'Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      Get.snackbar(
        'Validation Error',
        'Password must be at least 6 characters long',
      );
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: 'Student',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());

      userModel.value = newUser;

      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered. Please login instead.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not save user information: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Validation Error', 'Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter your password');
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await fetchUserProfile(userCredential.user!.uid);
      }

      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email. Please register first.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-credential' || e.code == 'malformed-jwt') {
        errorMessage = 'Invalid email or password. If you do not have an account, please Register.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    userModel.value = null;
    await _auth.signOut();
  }
}