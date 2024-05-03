import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:yinsight/Screens/HomePage/views/home/home_screen.dart';
import 'package:yinsight/Screens/Login_Signup/widgets/SignInScreen.dart';
import 'package:yinsight/Screens/Login_Signup/services/user_Authentication.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const String id = 'Signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _startSecondAnimation = false;
  final _formKey = GlobalKey<FormState>();

    // Define TextEditingControllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final AuthServices _authServices;

  @override
  void initState() {
    super.initState();
    _authServices = AuthServices(context); // Initialize AuthServices instance
  }


  void _SignIn() {
    Navigator.pushNamed(context, SignInScreen.id);
  }

  void _SignUp() { 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
  // In your sign-up method, validate the form before proceeding
  void _trySignUp() {
    if (_formKey.currentState!.validate()) {
      // Assuming you have text editing controllers for all fields
      String formattedPhoneNumber = '$_selectedCountryCode${phoneNumberController.text}';

      // print("got to before create User");

      // Call the createUser method from the AuthServices class
      _authServices.createUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: usernameController.text,
        email: emailController.text,
        phoneNumber: formattedPhoneNumber,
        age: int.parse(ageController.text),
        password: passwordController.text,
      );
      
      // print("got to after create User");
    }
  }

  String mainText = 'Yinsight';
  String firstWordInSecondAnimation = 'Learn';
  String secondWordInSecondAnimation = 'Recall';
  String thirdWordInSecondAnimation = 'Gamify';

/*
 * Parameters: 
  - int delay: The delay before the animation starts, in milliseconds.
  - int duration: The duration of the animation, in milliseconds.
  - TextInputType keyboardType: Specifies the type of keyboard to show, such as numeric or text.
  - String labelText: The text that describes the input field.
  - String hintText: The text that suggests what sort of input the field accepts.
  - IconData iconName: The icon to display in the input field.

@Returns: 
  - FadeInUp: Returns a widget that animates the position of a widget relative to its normal position. The widget will move up and fade in.

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
      String labelText, String hintText, IconData iconName, TextEditingController controller,String? Function(String?)? validator) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: duration),
      child: TextFormField( // Use TextFormField here
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
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
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
        validator: validator, // This should be inside TextFormField
      ),
    );
  }

  final List<String> _countryCodes = ['+1', '+44', '+91','+123'];
  String? _selectedCountryCode = '+1';

  FadeInUp fadeAnimationWithDropdown(int delay, int duration, TextEditingController phoneController, String? Function(String?)? validator) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: duration),
      child: Row(
        children: [
          Expanded(
            // Dropdown for country codes
            flex: 1, // Adjust flex ratio as needed
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Code',
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedCountryCode,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountryCode = newValue;
                });
              },
              items: _countryCodes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.black),),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10), // Spacing between dropdown and text field
          Expanded(
            // Text field for phone number
            flex: 3, // Adjust flex ratio as needed
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  FadeInUp(
                    child: Row(
                      children: [
                        const SizedBox(
                          height: 100,
                          width: 80,
                        ),
                        DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30.0,
                            fontFamily: 'Bobbers',
                          ),
                          child: AnimatedTextKit(
                            // repeatForever: false,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                mainText, // 'harmony' is the main text
                                speed: const Duration(milliseconds: 300),
                                textStyle: GoogleFonts.pacifico(
                                  textStyle: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 40.0,
                                  ),
                                ),
                              ),
                            ],
                            onFinished: () {
                              Future.delayed(const Duration(milliseconds: 20),
                                  () {
                                // Start the second animation after a delay
                                setState(() {
                                  _startSecondAnimation = true;
                                });
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0, height: 150.0),
                        if (_startSecondAnimation)
                          DefaultTextStyle(
                            style: GoogleFonts.sourceCodePro(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 19.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                RotateAnimatedText(firstWordInSecondAnimation),
                                RotateAnimatedText(secondWordInSecondAnimation),
                                RotateAnimatedText(thirdWordInSecondAnimation),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  fadeAnimation(
                      800,
                      100,
                      TextInputType.emailAddress,
                      'First Name',
                      'at most 10 characters',
                      FontAwesomeIcons.user,
                      firstNameController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        } else if (value.length > 10) {
                          return 'First name cannot exceed 10 characters';
                        }
                        return null; 
                      },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  fadeAnimation(900, 250, TextInputType.emailAddress, 'Last Name',
                      'at most 10 characters', FontAwesomeIcons.user,
                      lastNameController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        } else if (value.length > 10) {
                          return 'Last name cannot exceed 10 characters';
                        }
                        return null; 
                      },
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  fadeAnimation(1000, 500, TextInputType.emailAddress, 'Username',
                      'Username', FontAwesomeIcons.user,
                      usernameController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Username';
                        }
                        return null; 
                      },),
                  const SizedBox(
                    height: 20,
                  ),
                  fadeAnimation(1000, 500, TextInputType.emailAddress, 'Email',
                      'Email', FontAwesomeIcons.envelope, 
                      emailController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email';
                        }
                        return null; 
                      },),
                  const SizedBox(
                    height: 20,
                  ),
                  fadeAnimationWithDropdown(
                    1000, 
                    500, 
                    phoneNumberController, 
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null; 
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  fadeAnimation(1000, 500, TextInputType.number, 'Age',
                      'Age', FontAwesomeIcons.user,
                      ageController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Age';
                        } 
                        return null; 
                      },),
                  const SizedBox(
                    height: 20,
                  ),
                  fadeAnimation(1100, 750, TextInputType.visiblePassword,
                      'Password', 'Password', FontAwesomeIcons.key, 
                      passwordController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Password';
                        } 
                        return null; 
                      },),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    delay: const Duration(milliseconds: 800),
                    child: MaterialButton(
                      onPressed: () {
                        _trySignUp();
                      },
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.black,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 1500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _SignIn();
                          },
                          ////////////////////////////////////////// Route To Register Page- chnage content in pushReplacement to register page  ///////////////////////////////////////
              
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
