import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



/// A service class for handling welcome dialogs.
class WelcomeService {
  final GlobalKey<ScaffoldState> scaffoldKey;

  /// Creates a [WelcomeService] instance.
  ///
  /// [scaffoldKey]: The global key for the scaffold.
  WelcomeService(this.scaffoldKey);

  /// Checks if the welcome dialog has been shown and shows it if not.
  ///
  /// This method uses shared preferences to track if the dialog has been shown.
  Future<void> checkAndShowWelcomeDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isThirdShown = prefs.getBool('isThirdShown') ?? false;

    if (!isThirdShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog(scaffoldKey.currentContext!);
      });
      await prefs.setBool('isThirdShown', true);
    }
  }

  /// Displays the welcome dialog.
  ///
  /// [context]: The build context to show the dialog.
  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lets Chill!😀"),
          content: const Text(
            "📚 Welcome to the Recall Section! 📚\n\n"
            "This is your go-to spot to keep class materials fresh in your mind! Just tap the 'Upload File' button below ⬇️ to add your PDFs.\n\n Want to generate questions from specific files? Easy! Just click the hamburger menu icon ☰ in the top left corner. \n\n Remember, this tool is here to boost your studying, not to replace it! 🎓 Let's make learning fun and effective!",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Got It!"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}





/* 



movq %rdi , %rbx
movq %rsi , %rax
movq %rbx , %rdi
movq %rax , %rsi
ret
*/