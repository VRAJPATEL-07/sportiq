/// LAB 5: Custom TextField Widget
/// Reusable TextField component with consistent styling
///
/// This widget provides:
///   - Consistent styling across forms
///   - Optional error message display
///   - Icon support
///   - Customizable validation
///   - Password field support
library;

import 'package:flutter/material.dart';

/// CustomTextField: Reusable text input field component
///
/// This widget wraps Flutter's TextField with Material Design styling
/// and consistent behavior across the application.
///
/// Example usage:
///   ```dart
///   CustomTextField(
///     label: 'Email',
///     hint: 'Enter your email',
///     icon: Icons.email,
///     controller: emailController,
///     errorText: emailError,
///   )
///   ```
class CustomTextField extends StatefulWidget {
  /// Label text displayed above the field
  final String label;

  /// Placeholder hint text
  final String hint;

  /// Icon to display before input
  final IconData? icon;

  /// Text editing controller
  final TextEditingController? controller;

  /// Error message to display below field
  final String? errorText;

  /// Callback when text changes
  final Function(String)? onChanged;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Optional validation function
  final String? Function(String?)? validator;

  /// Maximum lines for the field
  final int maxLines;

  /// Suffix icon (optional)
  final IconData? suffixIcon;

  /// Suffix icon on pressed callback
  final VoidCallback? onSuffixIconPressed;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.onSuffixIconPressed,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

        // TextField
        TextField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          keyboardType: widget.keyboardType,
          maxLines: _obscurePassword ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(widget.suffixIcon),
                        onPressed: widget.onSuffixIconPressed,
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorText: widget.errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
