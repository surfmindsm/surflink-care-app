import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationUtils {
  /// 안전한 뒤로가기 - canPop 체크 후 pop하거나 홈으로 이동
  static void safeGoBack(BuildContext context, {String fallbackRoute = '/home'}) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  /// AppBar용 안전한 뒤로가기 아이콘 버튼
  static Widget buildBackButton(BuildContext context, {String fallbackRoute = '/home'}) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => safeGoBack(context, fallbackRoute: fallbackRoute),
    );
  }

  /// SliverAppBar용 안전한 뒤로가기 아이콘 버튼 (흰색 아이콘)
  static Widget buildBackButtonForSliver(BuildContext context, {String fallbackRoute = '/home'}) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => safeGoBack(context, fallbackRoute: fallbackRoute),
    );
  }
}
