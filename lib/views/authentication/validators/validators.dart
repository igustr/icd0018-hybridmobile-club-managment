String? validateEmail(String? email) {
  if (email == null || email.isEmpty) return 'Please enter your email';
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(email)) return 'Please enter a valid email';
  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) return 'Please enter your password';
  if (password.length < 5) return 'Password must be at least 5 characters long';
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Password must contain at least one uppercase letter';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your name';
  }

  final name = value.trim();

  if (name.length < 2) {
    return 'Name is too short';
  }
  final regex = RegExp(r'^[a-zA-Z\s\-]+$');
  if (!regex.hasMatch(name)) {
    return 'Name can contain only letters, spaces, and hyphens';
  }
  if (name.contains('  ')) {
    return 'Please avoid multiple spaces';
  }

  return null;
}
