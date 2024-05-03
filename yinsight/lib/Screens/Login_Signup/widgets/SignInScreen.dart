import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yinsight/Screens/Login_Signup/widgets/ForgetPassword.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/SignUpScreen.dart';
import 'package:yinsight/Screens/Login_Signup/services/user_Authentication.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  static const String id = 'Signin';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final int _success = 1;
  int activeIndex = 0;
  Timer? _timer;
  final user  = FirebaseAuth.instance.currentUser;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> _images = [
    'lib/Assets/Image_Comp/LoginRegImages/Rainbow.png',
    'lib/Assets/Image_Comp/LoginRegImages/ManSitting.png',
    'lib/Assets/Image_Comp/LoginRegImages/GirlOnComputer.png',
  ];

  @override
  void initState() {
    super.initState();

    startTimer();
  }

/*
 * This method allows the transitioning between images every second.
 * 
 * @Requires: 

- An integer variable named 'activeIndex' must already be declared and initialized.
- A function named 'setState' must be defined which takes a function as an argument to update the state of the 'activeIndex'.
- Timer and Duration classes should be available in the scope of this function. 

 @Ensures:

- A periodic timer with a duration of 6 seconds is started.
- On each tick of the timer, the 'activeIndex' is incremented by 1.
- If 'activeIndex' equals 3, it is reset back to 0.
- The 'setState' function is called on each tick of the timer to update the state of 'activeIndex'.
 */
  void startTimer() {
      _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (mounted) { // Check if the widget is still in the widget tree
          setState(() {
            activeIndex = activeIndex + 1;

            if (activeIndex == 3) {
              activeIndex = 0;
            }
          });
        }
      });
  }
  void _SignUp() {
    Navigator.pushNamed(context, SignUpScreen.id);
  }


  void _ForgotPassword() {
    Navigator.of(context).pushNamed(ForgetPasswordScreen.id);
  }


/* 
 * This method creates a FadeInUp widget using the "animate_do.dart" library with a TextField as its child. The TextField 
 * has a specific style, cursor color,decoration, and prefix icon. The TextField's border changes when it's focused or enabled. 
 * The TextField's label and hint have specific styles. The method returns the FadeInUp widget.
 * 
 * Parameters: 
  - int delay: The delay before the animation starts, in milliseconds.
  - int duration: The duration of the animation, in milliseconds.
  - TextInputType keyboardType: Specifies the type of keyboard to show, such as numeric or text.
  - String labelText: The text that describes the input field.
  - String hintText: The text that suggests what sort of input the field accepts.
  - IconData iconName: The icon to display in the input field.

@Returns: 
  - FadeInUp: Returns a widget that animates the position of a widget relative to its normal position.
    The widget will move up and fade in.

@Requires Clause:
  - The delay and duration parameters must be integers greater than or equal to zero.
  - The keyboardType parameter must be a valid TextInputType.
  - The labelText and hintText parameters must be valid strings, not null.
  - The iconName parameter must be a valid IconData.

@Ensures Clause:
  - Returns a FadeInUp widget with the specified delay and duration.
  - The child of the FadeInUp widget is a TextField with the specified keyboardType, labelText, hintText and iconName.
  - The TextField will have a specific style, cursor color, decoration, and prefix icon as defined in the method.
  - The TextField's border changes when it's focused or enabled.
  - The TextField's label and hint have specific styles as defined in the method.
 */
  FadeInUp fadeAnimation(int delay, int duration, TextInputType keyboardType,
      String labelText, String hintText, IconData iconName, TextEditingController controller) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: duration),
      child: TextField(
        controller: controller,
        obscureText: labelText == 'Password' ? true : false,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.lexend(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          prefixIcon: Icon(
            iconName,
            color: Colors.black,
            size: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
      _timer?.cancel(); // Cancel the timer
      super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // body: SingleChildScrollView(

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              FadeInUp(
                child: SizedBox(
                  height: 270,
                  child: Stack(
                    children: _images.asMap().entries.map((e) {
                      return Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: activeIndex == e.key ? 1 : 0,
                            child: Image.asset(
                              e.value,
                              height: 400,
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              fadeAnimation(800, 170, TextInputType.emailAddress, 'Email',
                  'Email', FontAwesomeIcons.user,emailController), // FadeInUp
              const SizedBox(
                height: 20,
              ),
              fadeAnimation(900, 270, TextInputType.visiblePassword, 'Password',
                  'Password', FontAwesomeIcons.key,passwordController), // FadeInUp
              
              FadeInUp(
                duration: const Duration(milliseconds: 1300),
                delay: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        ////////////////////////////////////////// Route To Forgot Password Page- change content in pushReplacement to forgotpassword page  ///////////////////////////////////////
                        _ForgotPassword();
                      },
                      child: Text(
                        "Forgot Password",
                        style: GoogleFonts.lexend(
                          textStyle: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 1300),
                delay: const Duration(milliseconds: 800),
                child: MaterialButton(
                  onPressed: () {
                    AuthServices(context).signInWithEmailAndPassword(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                  height: 45,
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.black,
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // FadeInUp(
              //   duration: const Duration(milliseconds: 800),
              //   delay: const Duration(milliseconds: 1500),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         'Or continue with',
              //         style: GoogleFonts.lexend(
              //           textStyle: TextStyle(
              //             color: Colors.grey.shade600,
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400,
              //           ),
              //         ),
              //       ),

              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 20,
              ),
              // FadeInUp(
              //   duration: const Duration(milliseconds: 800),
              //   delay: const Duration(milliseconds: 1500),
              //   child: GestureDetector(
              //     onTap: () => AuthServices(context).signInWithGoogle(), // Pass the context here
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         SvgPicture.asset(
              //           "lib/Assets/Image_Comp/Icons/google.svg",
              //           width: 24, // Set your desired icon width
              //           height: 24, // Set your desired icon height
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 1500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: GoogleFonts.lexend(
                        textStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _SignUp();
                      },
                      ////////////////////////////////////////// Route To Register Page- chnage content in pushReplacement to register page  ///////////////////////////////////////

                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.lexend(
                          textStyle: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
