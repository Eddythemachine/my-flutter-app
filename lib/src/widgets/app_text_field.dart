import 'package:flutter/material.dart';

/// A rounded text field that matches the app's red, Material 3 styling —
/// including a built-in show/hide toggle for password fields.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.prefixIcon,
    this.obscure = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final bool obscure;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outline.withAlpha(160)),
    );

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: widget.obscure && _hidden,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(color: scheme.onSurface),
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1A1A) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20, color: scheme.onSurfaceVariant),
        suffixIcon: widget.obscure ? _visibilityToggle() : null,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withAlpha(130)),
        errorStyle: TextStyle(color: scheme.error),
        border: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
    );
  }

  Widget _visibilityToggle() {
    return IconButton(
      onPressed: () => setState(() => _hidden = !_hidden),
      tooltip: _hidden ? 'Show password' : 'Hide password',
      icon: Icon(
        _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
      ),
    );
  }
}
