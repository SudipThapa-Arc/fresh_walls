class RefreshController {
  bool _isRefreshing = false;

  void refreshCompleted() {
    _isRefreshing = false;
  }

  void refreshFailed() {
    _isRefreshing = false;
  }

  void dispose() {
    _isRefreshing = false;
  }
}
