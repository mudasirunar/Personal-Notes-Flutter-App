import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable text field widget used across the app.
///
/// Anti-jump defaults are baked in:
/// - `scrollPadding: EdgeInsets.zero`
/// - `autocorrect: false` / `enableSuggestions: false` by default
/// - Empty `autofillHints` for password fields
/// - `TextInputType.visiblePassword` auto-applied for password fields
///
/// Password visibility toggle is handled internally — only this widget's
/// subtree rebuilds on toggle, never the parent screen.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool showLabel;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autocorrect;
  final bool enableSuggestions;
  final EdgeInsets scrollPadding;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.showLabel = true,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.scrollPadding = EdgeInsets.zero,
    this.autofillHints,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPassword != oldWidget.isPassword) {
      _obscured = widget.isPassword ? _obscured : false;
    }
  }

  void _toggleObscure() {
    setState(() => _obscured = !_obscured);
  }

  @override
  Widget build(BuildContext context) {
    // ── Resolve keyboard type ──
    final effectiveKeyboardType = widget.keyboardType ??
        (widget.isPassword ? TextInputType.visiblePassword : TextInputType.text);

    // ── Resolve autofill hints ──
    final effectiveAutofillHints = widget.autofillHints ??
        (widget.isPassword ? const <String>[] : null);

    // ── Resolve prefix icon ──
    final effectivePrefixIcon = widget.prefixIcon ??
        (widget.isPassword ? Icons.lock_outline_rounded : null);

    // ── Resolve suffix icon ──
    Widget? effectiveSuffixIcon = widget.suffixIcon;
    if (widget.isPassword && effectiveSuffixIcon == null) {
      effectiveSuffixIcon = GestureDetector(
        onTap: _toggleObscure,
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondaryOf(context),
            size: 20,
          ),
        ),
      );
    }

    // ── Build the TextFormField ──
    final textField = TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscured,
      keyboardType: effectiveKeyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      scrollPadding: widget.scrollPadding,
      autofillHints: effectiveAutofillHints,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: TextStyle(
        color: AppColors.textPrimaryOf(context),
        fontSize: 14.5,
        height: 1.25,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: effectivePrefixIcon != null
            ? Icon(effectivePrefixIcon, size: 20, color: AppColors.textSecondaryOf(context))
            : null,
        suffixIcon: effectiveSuffixIcon,
        suffixIconConstraints: effectiveSuffixIcon != null
            ? const BoxConstraints(minWidth: 44, minHeight: 44)
            : null,
        counterText: widget.maxLength != null ? null : '',
      ),
    );

    // ── Optionally wrap with a label ──
    if (!widget.showLabel) return textField;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        textField,
      ],
    );
  }
}
