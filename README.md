# myapp

A new Flutter project.

## Recent Flutter Apps

CipherVPN : https://play.google.com/store/apps/details?id=com.fomo.ciphervpn&pcampaignid=web_share

NFL Live Streaming : https://play.google.com/store/apps/details?id=com.nfl.stream&pcampaignid=web_share



---

## 🏗 State Management Setup (Riverpod)

The application uses **Riverpod** for predictable, compile-safe, and scalable state management. Code is broken down logically separating UI from business logic.

```dart
// Example: Storing and watching a user authentication state
final authStateProvider = StateProvider<bool>((ref) => false);

class AuthConsumer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the provider and rebuilds only this widget when state changes
    final isLoggedIn = ref.watch(authStateProvider);
    return isLoggedIn ? const HomeScreen() : const SignInScreen();
  }
}
```

## 🧪 Testing Strategy

We follow a robust testing strategy that includes unit testing the providers and widget testing the UI to ensure our components behave correctly.

```dart
// Example: Widget Testing a Riverpod State Change
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Authentication state updates correctly', (tester) async {
    // Wrap the app in a ProviderScope for Riverpod
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify initial state shows SignInScreen
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    // Simulate login interaction
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(); // Wait for animations and state updates

    // Verify updated state shows HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

## ✅ Definition of Done (DoD)

Our feature delivery process ensures high quality before any code is considered "Done":
- **Code Complete:** The feature matches the provided designs seamlessly and handles edge cases appropriately.
- **Testing Requirements:** Unit and Widget tests are written and passing, covering the happy and error paths.
- **Linting & Formatting:** Zero errors or warnings via `dart analyze`. Code is formatted properly.
- **Accessibility (a11y):** Touch targets are suitably sized (`>= 48x48dp`), semantic labels are added for icons, and color contrast is verified.
- **Error Handling:** Graceful fallbacks and user-friendly error messages are implemented (e.g., handling network failures during API calls).

## ⚡ Performance Budgets & Optimization

To guarantee a buttery-smooth 60 FPS experience across devices, we adhere to strict performance best practices:

1. **Scoped Rebuilds:** We localize UI rebuilds using Riverpod's `ref.watch`, `ref.select`, or `Consumer` at the lowest possible nodes of the widget tree rather than wrapping entire pages.
2. **`const` Constructors:** Heavy enforcement of `const` widgets throughout the app to prevent unnecessary object instantiation during build cycles and minimize GC pauses.
3. **Scroll Performance:** Infinite lists and large datasets actively use `ListView.builder` or Slivers (e.g., `SliverGrid`) to lazily build elements as they scroll into view.
4. **Memory Management:** Always strictly disposing objects like `ScrollController` or `AnimationController` within the `dispose()` method of Stateful Widgets to prevent memory leaks.
5. **Asset Optimization:** Network images are cached and sized appropriately. Heavy layout passes are minimized avoiding deep nested hierarchies where possible.
