import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Only allows an (optionally negative) integer, e.g. "-3", "0", "12".
class _SignedIntFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text;
    if (t.isEmpty || t == '-' || RegExp(r'^-?\d+$').hasMatch(t)) {
      return newValue;
    }
    return oldValue;
  }
}

/// A signed-integer input with a leading "±" button, so negative counts can be
/// entered even on the iOS number pad (which has no minus key).
class SignedCountInput extends StatelessWidget {
  const SignedCountInput({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.hint,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final String? hint;
  final bool autofocus;

  void _toggleSign() {
    final t = controller.text;
    final next = t.startsWith('-') ? t.substring(1) : '-$t';
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 56,
          width: 52,
          child: OutlinedButton(
            onPressed: _toggleSign,
            style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('±', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType:
                const TextInputType.numberWithOptions(signed: true),
            inputFormatters: [_SignedIntFormatter()],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hint,
            ),
            onSubmitted:
                onSubmitted == null ? null : (_) => onSubmitted!.call(),
          ),
        ),
      ],
    );
  }
}
