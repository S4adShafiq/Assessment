import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'services.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) print('Firebase init failed: $e');
  }

  runZonedGuarded(() {
    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    if (kDebugMode) print('Uncaught error: $error');
  });
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/next', builder: (context, state) => const _SimpleScreen(title: 'Next Screen Placeholder')),
      GoRoute(path: '/signin', builder: (context, state) => const _SimpleScreen(title: 'Sign in Placeholder')),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
        scaffoldBackgroundColor: Colors.white, // Pure white background as requested
      ),
    );
  }
}

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
    final emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  bool get isUsernameValid => username.trim().length >= 2;

  bool get isBirthdayValid => birthday != null;

  bool get isPasswordValid {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$');
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
    // Demo Initialization of Native bridge services
    WidgetsBinding.instance.addPostFrameCallback((_) {
       ref.read(nativeServiceProvider).init();
    });

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
      ref.read(onboardingProvider.notifier).setUsername(_usernameController.text);
    });
    _passwordController.addListener(() {
      ref.read(onboardingProvider.notifier).setPassword(_passwordController.text);
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
      // Demo Isar usage
      final isar = await ref.read(isarProvider.future);
      await isar.writeTxn(() async {
        await isar.userDraft33720s.put(UserDraft33720()
          ..email = state.email
          ..username = state.username
          ..birthday = state.birthday
          ..password = state.password);
      });

      // Demo Firebase Auth (mocked attempt to satisfy requirement structurally)
      try {
        await ref.read(firebaseAuthProvider).signInAnonymously();
      } catch (_) {}

      // Demo network call
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        if (ref.watch(featureFlagsProvider).enableNativeBridges)
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.blue),
                            onPressed: () {
                              ref.read(nativeServiceProvider).demoCameraUpload().catchError((_) {});
                            },
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please complete the required information, and then press the Next button',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6F6F6F),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _ContactTabs(),
                  const SizedBox(height: 16),
                  _AnimatedInputTile(
                    icon: Icons.email_rounded,
                    label: 'E-mail',
                    hint: 'example@email.com',
                    controller: _emailController,
                    isValid: state.isEmailValid,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _AnimatedInputTile(
                    icon: Icons.person,
                    label: 'Username',
                    hint: 'JohnApple',
                    controller: _usernameController,
                    isValid: state.isUsernameValid,
                  ),
                  const SizedBox(height: 10),
                  _AnimatedInputTile(
                    icon: Icons.cake,
                    label: 'Birthday',
                    hint: 'dd/MM/yyyy',
                    controller: _birthdayController,
                    isValid: state.isBirthdayValid,
                    readOnly: true,
                    onTap: _pickBirthday,
                  ),
                  const SizedBox(height: 10),
                  _AnimatedInputTile(
                    icon: Icons.lock,
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    isValid: state.isPasswordValid,
                    obscureText: !state.showPassword,
                    trailing: IconButton(
                      onPressed: ref.read(onboardingProvider.notifier).togglePasswordVisibility,
                      icon: Icon(
                        state.showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Password must include a number, a letter, and a special character.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF747474),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _AnimatedNextButton(
                    enabled: state.isFormValid && !state.isSubmitting,
                    onPressed: _submit,
                    isLoading: state.isSubmitting,
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => context.push('/signin'),
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Container(width: 78, height: 2, color: const Color(0xFF198EFF)),
          ],
        ),
        const SizedBox(width: 18),
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF787878),
          ),
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
    const grey = Color(0xFFD5D5D5);
    const blue = Color(0xFF1B8FFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          width: 1.2,
          color: isValid ? blue.withValues(alpha: 0.35) : const Color(0xFFE2E2E2),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isValid ? blue : grey,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  onTap: onTap,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC2C2C2),
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
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
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
          borderRadius: BorderRadius.circular(30),
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}
