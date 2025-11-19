import 'package:flutter/material.dart';

import '../../config/style/colors.dart';

class CustomInputField extends StatefulWidget {
  const CustomInputField({
    required this.label,
    required this.onChanged,
    this.errorText,
    this.isPassword = false,
    super.key,
  });

  final String label;
  final String? errorText;
  final Function(String) onChanged;
  final bool isPassword;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          autocorrect: false,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          obscureText: _obscureText,
          decoration: InputDecoration(
            suffixIcon:
                widget.isPassword
                    ? _VisibilityButton(
                      obscureText: _obscureText,
                      onTap: _onVisibilityButtonTap,
                    )
                    : null,

            errorText: widget.errorText,
            errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.red600,
              fontSize: 14,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 2, color: AppColors.red600),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 2, color: AppColors.red600),
            ),
          ),
        ),
      ],
    );
  }

  void _onVisibilityButtonTap() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}

class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton({required this.obscureText, required this.onTap});

  final bool obscureText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        obscureText ? Icons.visibility_off : Icons.visibility,
        color: AppColors.slate800,
      ),
    );
  }
}
