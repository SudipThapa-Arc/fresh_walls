import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

class WebRouterService {
  static void updateWebTitle(String title) {
    if (kIsWeb) {
      html.document.title = title;
    }
  }

  static void updateWebUrl(String path) {
    if (kIsWeb) {
      html.window.history.pushState(null, '', path);
    }
  }

  static String getCurrentPath() {
    if (kIsWeb) {
      return html.window.location.pathname ?? '/';
    }
    return '/';
  }

  static void initWebRouting(NavigatorObserver observer) {
    if (kIsWeb) {
      html.window.onPopState.listen((event) {
        final path = getCurrentPath();
        observer.navigator?.pushNamed(path);
      });
    }
  }
}
