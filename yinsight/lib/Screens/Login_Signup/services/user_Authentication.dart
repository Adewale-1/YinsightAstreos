import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yinsight/Globals/services/userInfo.dart';
import 'package:yinsight/Screens/HomePage/widgets/Calender/eventsCalender.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/SignInScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:yinsight/navigationBar.dart';

/// A service class for handling authentication-related operations.
class AuthServices {
  final BuildContext context;
  final storage = const FlutterSecureStorage();

  /// Creates an [AuthServices] instance.
  ///
  /// [context]: The build context.
  AuthServices(this.context);

  /// Stores the authentication token securely.
  ///
  /// [token]: The token to store.
  Future<void> storeToken(String? token) async {
    if (token != null) {
      await storage.write(key: 'authToken', value: token);
    }
  }

  /// Fetches the stored authentication token securely.
  ///
  /// Returns the stored token if available.
  Future<String?> fetchToken() async {
    return await storage.read(key: 'authToken');
  }

  // /* Google Sign In */
  // Future<void> signInWithGoogle() async {
  //   try {

  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     if (googleUser == null) return;

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     // Refresh the token right after sign-in, if needed for immediate use
  //     String? freshIdToken = await refreshToken();

  //     final user = FirebaseAuth.instance.currentUser;
  //     // Use freshIdToken as needed, for example, sending it to your backend
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()),);

  //   } on FirebaseAuthException catch (e) {
  //     // Handle Firebase authentication errors
  //     // print('FirebaseAuthException: ${e.message}');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication error: ${e.message}')));
  //   } catch (error) {
  //     // Handle other errors
  //     // print('General Error: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred during Google Sign-In. Please try again.')));
  //   }
  // }

  /// Signs in using email and password.
  ///
  /// [email]: The email address of the user.
  /// [password]: The password of the user.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? token = await user.getIdToken();
        // print('User Token: ${token}');

        String? freshIdToken = await refreshTokenWithToken(token);
        // Use freshIdToken as needed or proceed without it if not explicitly needed
        Navigator.pushNamedAndRemoveUntil(
            context, MainNavigationScreen.id, (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      // Display snackbar to inform user about sign-in failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in failed: ${e.message}"),
          duration: const Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
    }
  }

  /// Refreshes the authentication token.
  ///
  /// [idToken]: The current ID token.
  ///
  /// Returns the refreshed token.
  Future<String?> refreshTokenWithToken(String? idToken) async {
    try {
      // Force refresh the token
      // String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      await storeToken(idToken);
      await writeTokenToFile();
      // print("Refreshed token: $idToken");
      return idToken;
    } catch (e) {
      // print("Error refreshing token: $e");
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    // Navigate to SignInScreen upon successful sign-out
    Navigator.of(context).pushReplacementNamed(SignInScreen.id);
  }

  /// Writes the current authentication token to a file.
  Future<void> writeTokenToFile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      // print("current user: ${user}");
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      // print("idToken: ${idToken}");

      // Get the directory where the app can write files
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/firebase_token.txt');

      // Write the token to the file
      await file.writeAsString(idToken ?? 'No token found');
      // print("Token written to ${file.path}");
    } catch (e) {
      // print("Error writing token to file: $e");
    }
  }

  /// Sends a password reset link to the specified email address.
  ///
  /// [emailController]: The controller containing the email address.
  /// [context]: The build context.
  Future<void> sendResetLink(
      TextEditingController emailController, BuildContext context) async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // If successful, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('A link to reset your password has been sent to $email.')),
      );
      // Wait for a few seconds and then navigate to SignIn page
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pushReplacementNamed(SignInScreen.id);
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else {
        errorMessage = 'An error occurred. Please try again later.';
      }

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle any other errors that might occur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('An unexpected error occurred. Please try again later.')),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Refresh the token right after sign-in, if needed for immediate use
      String? freshIdToken = await refreshToken();
      // print("freshIdToken: ${freshIdToken}");
      final user = FirebaseAuth.instance.currentUser;
      // Use freshIdToken as needed, for example, sending it to your backend
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoogleCalendarClass()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: ${e.message}')));
    } catch (error) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'An error occurred during Google Sign-In. Please try again.')));
    }
  }

  Future<String?> refreshToken() async {
    // Implement your token refresh logic here
    return FirebaseAuth.instance.currentUser?.getIdToken(true);
  }

  /// Creates a new user account.
  ///
  /// [firstName]: The first name of the user.
  /// [lastName]: The last name of the user.
  /// [username]: The username of the user.
  /// [email]: The email address of the user.
  /// [phoneNumber]: The phone number of the user.
  /// [age]: The age of the user.
  /// [password]: The password for the account.
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required int age,
    required String password,
  }) async {
    var url = Uri.parse(UserInformation.getRoute('signup'));

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'phone_number': phoneNumber,
          'age': age,
          'password': password,
        }),
      );
      // print("first_name: $firstName and lastnmae: $lastName and username: $username and email: $email and phone_number: $phoneNumber and password: $password");
      if (response.statusCode == 200) {
        // Successfully created an account
        var data = jsonDecode(response.body);
        // print(data['message']);

        // Force sign-in is required to synchronize the user's authentication state across backend and frontend, ensuring the newly created user is recognized by the frontend.
        signInWithEmailAndPassword(email, password);
      } else {
        // Handle errors
        var data = jsonDecode(response.body);
        // print(data['message']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      // print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('An unexpected error occurred. Please try again later.')),
      );
    }
  }
}
