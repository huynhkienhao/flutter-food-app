import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_canteen_fe/constants/border_styles.dart';

/// Email TextFormField
TextFormField emailTextField({
  required TextEditingController emailController,
  bool readOnly = false,
}) {
  return TextFormField(
    controller: emailController,
    decoration: InputDecoration(
      labelText: "Email",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    keyboardType: TextInputType.emailAddress,
    readOnly: readOnly,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email.';
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return 'Please enter a valid email.';
      }
      return null;
    },
  );
}

/// Password TextFormField
TextFormField passwordTextField({
  required TextEditingController passwordController,
  String? label,
}) {
  return TextFormField(
    controller: passwordController,
    decoration: InputDecoration(
      labelText: label ?? "Password",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    obscureText: true,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your password.';
      }
      return null;
    },
  );
}

/// Username TextFormField
TextFormField usernameTextField({
  required TextEditingController usernameController,
  bool readOnly = false,
}) {
  return TextFormField(
    controller: usernameController,
    decoration: InputDecoration(
      labelText: "Username",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    readOnly: readOnly,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your username.';
      }
      return null;
    },
  );
}

/// Role TextFormField (Dropdown for roles)
DropdownButtonFormField<String> roleDropdownField({
  required List<String> roles,
  required String? selectedRole,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: selectedRole,
    decoration: InputDecoration(
      labelText: "Role",
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
    items: roles
        .map((role) => DropdownMenuItem(
      value: role,
      child: Text(role),
    ))
        .toList(),
    onChanged: onChanged,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a role.';
      }
      return null;
    },
  );
}

/// User Details TextField (Read-only for displaying user information)
TextField userDetailsTextField({
  required String label,
  required String value,
}) {
  return TextField(
    controller: TextEditingController(text: value),
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(color: Colors.green),
      border: BorderStyles.border,
      focusedBorder: BorderStyles.focusedBorder,
      errorBorder: BorderStyles.errorBorder,
      focusedErrorBorder: BorderStyles.focusedErrorBorder,
    ),
  );
}
