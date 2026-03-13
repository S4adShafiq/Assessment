import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'services.dart';
import 'models.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setEmail(String value) => state = state.copyWith(email: value);

  void setUsername(String value) => state = state.copyWith(username: value);

  void setBirthday(DateTime? value) => state = state.copyWith(birthday: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }
}

class OnboardingState {
  const OnboardingState({
    this.email = '',
    this.username = '',
    this.birthday,
    this.password = '',
    this.showPassword = false,
    this.isSubmitting = false,
  });

  final String email;
  final String username;
  final DateTime? birthday;
  final String password;
  final bool showPassword;
  final bool isSubmitting;

  bool get isEmailValid {
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  bool get isUsernameValid => username.trim().length >= 2;

  bool get isBirthdayValid => birthday != null;

  bool get isPasswordValid {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  bool get isFormValid =>
      isEmailValid && isUsernameValid && isBirthdayValid && isPasswordValid;

  OnboardingState copyWith({
    String? email,
    String? username,
    DateTime? birthday,
    String? password,
    bool? showPassword,
    bool? isSubmitting,
  }) {
    return OnboardingState(
      email: email ?? this.email,
      username: username ?? this.username,
      birthday: birthday ?? this.birthday,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    final state = ref.read(onboardingProvider);
    _emailController = TextEditingController(text: state.email);
    _usernameController = TextEditingController(text: state.username);
    _birthdayController = TextEditingController(
      text: state.birthday == null ? '' : _formatDate(state.birthday!),
    );
    _passwordController = TextEditingController(text: state.password);

    _emailController.addListener(() {
      ref.read(onboardingProvider.notifier).setEmail(_emailController.text);
    });
    _usernameController.addListener(() {
      ref
          .read(onboardingProvider.notifier)
          .setUsername(_usernameController.text);
    });
    _passwordController.addListener(() {
      ref
          .read(onboardingProvider.notifier)
          .setPassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000, 1, 1),
    );

    if (selected == null) {
      return;
    }

    _birthdayController.text = _formatDate(selected);
    ref.read(onboardingProvider.notifier).setBirthday(selected);
  }

  Future<void> _submit() async {
    final state = ref.read(onboardingProvider);
    if (!state.isFormValid || state.isSubmitting) return;

    ref.read(onboardingProvider.notifier).setSubmitting(true);

    try {
      final isar = await ref.read(isarProvider.future);
      await isar.writeTxn(() async {
        await isar.userDraft33720s.put(
          UserDraft33720()
            ..email = state.email
            ..username = state.username
            ..birthday = state.birthday
            ..password = state.password,
        );
      });

      try {
        await ref.read(firebaseAuthProvider).signInAnonymously();
      } catch (_) {}

      try {
        await ref.read(dioProvider).get('https://example.com/api/ping');
      } catch (_) {}

      if (mounted) {
        context.push('/next');
      }
    } finally {
      if (mounted) {
        ref.read(onboardingProvider.notifier).setSubmitting(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Please complete the required information, and then press the Next button',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6F6F6F),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _ContactTabs(),
                  const SizedBox(height: 12),
                  _AnimatedInputTile(
                    icon: Icons.email_rounded,
                    label: 'E-mail',
                    hint: 'example@email.com',
                    controller: _emailController,
                    isValid: state.isEmailValid,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _AnimatedInputTile(
                    icon: Icons.person,
                    label: 'Username',
                    hint: 'JohnApple',
                    controller: _usernameController,
                    isValid: state.isUsernameValid,
                  ),
                  const SizedBox(height: 12),
                  _AnimatedInputTile(
                    icon: Icons.cake,
                    label: 'Birthday',
                    hint: 'dd/MM/yyyy',
                    controller: _birthdayController,
                    isValid: state.isBirthdayValid,
                    readOnly: true,
                    onTap: _pickBirthday,
                  ),
                  const SizedBox(height: 12),
                  _AnimatedInputTile(
                    icon: Icons.lock,
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    isValid: state.isPasswordValid,
                    obscureText: !state.showPassword,
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        onPressed: ref
                            .read(onboardingProvider.notifier)
                            .togglePasswordVisibility,
                        icon: Icon(
                          state.showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF6F6F6F),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Password must include a number, a letter, and a special character.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF909090),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedNextButton(
                    enabled: state.isFormValid && !state.isSubmitting,
                    onPressed: _submit,
                    isLoading: state.isSubmitting,
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => context.push('/'),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF646464),
                        ),
                        children: const [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Signin',
                            style: TextStyle(
                              color: Color(0xFF1F1F1F),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

class _ContactTabs extends StatelessWidget {
  const _ContactTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              'Email Address',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Container(width: 78, height: 2, color: const Color(0xFF198EFF)),
          ],
        ),
        const SizedBox(width: 18),
        Text(
          'Phone Number',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF787878)),
        ),
      ],
    );
  }
}

class _AnimatedInputTile extends StatelessWidget {
  const _AnimatedInputTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isValid,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.obscureText = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isValid;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool obscureText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4DAEFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ), // Increased vertical padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          width: 1.5,
          color: isValid
              ? blue.withValues(alpha: 0.35)
              : const Color(0xFFF0F0F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: isValid ? blue : const Color(0xFFD5D5D5), size: 22),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: const Color(0xFFF0F0F0)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFD5D5D5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  onTap: onTap,
                  obscureText: obscureText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFD6D6D6),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _AnimatedNextButton extends StatelessWidget {
  const _AnimatedNextButton({
    required this.enabled,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool enabled;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      height: 94, // Increased height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // Fully rounded like fields
        gradient: enabled || isLoading
            ? const LinearGradient(
                colors: [Color(0xFF4DAEFF), Color(0xFF007DFF)],
              )
            : const LinearGradient(
                colors: [Color(0xFFD8D8D8), Color(0xFFB5B5B5)],
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    'Next',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
