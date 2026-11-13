import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/features/auth/presentation/session_controller.dart';
import 'package:speedvideo/features/library/presentation/my_netflix_page.dart';

import '../../helpers/test_app.dart';

class _GuestSessionController extends SessionController {
  @override
  SessionState build() {
    return const SessionState(status: SessionStatus.unauthenticated);
  }
}

void main() {
  testWidgets('guest library shows a sign-in prompt instead of a login wall', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithApp(
        const MyNetflixPage(),
        overrides: [
          sessionControllerProvider.overrideWith(_GuestSessionController.new),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in to sync your library'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
