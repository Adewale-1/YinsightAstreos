import 'package:flutter/material.dart';


class InputField extends StatelessWidget {
  final String title;
  final String? hint;
  final TextEditingController? controller;
  final Widget? widget;
  final VoidCallback? onTap;

  const InputField({
    super.key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: widget != null || onTap != null,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                         hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 16, right: 16),
                      ),
                    ),
                  ),
                  if (widget != null) widget!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
