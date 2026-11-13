/// Bridge between the low-level HTTP layer and the session state machine.
///
/// The Dio interceptor performs token rotation; it cannot import feature-level
/// models, so it hands the raw refresh payload to the session controller.
class SessionSync {
  void Function(Map<String, dynamic> session)? onSessionRefreshed;
  void Function()? onExpired;
}
