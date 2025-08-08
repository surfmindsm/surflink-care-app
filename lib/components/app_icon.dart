import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// AppIcon
/// 
/// 프로젝트 전역에서 일관되게 아이콘을 사용할 수 있도록 만든 래퍼 위젯입니다.
/// - Lucide 아이콘: `AppIcon.lucide(icon: LucideIcons.activity, size: 24)`
///   (lucide 아이콘 상수는 사용하는 파일에서 `package:lucide_icons/lucide_icons.dart`를 import 하세요)
/// - Iconify 아이콘: `AppIcon.iconify(icon: Zondicons.airplane, size: 24)`
///   (원하는 아이콘 세트 파일을 호출부에서 import 하세요. 예: `package:iconify_flutter/icons/zondicons.dart`)
class AppIcon extends StatelessWidget {
  final Widget _child;

  const AppIcon._(this._child, {Key? key}) : super(key: key);

  /// Lucide 아이콘용 생성자
  factory AppIcon.lucide({
    Key? key,
    required IconData icon,
    double size = 24,
    Color? color,
    String? semanticLabel,
  }) {
    return AppIcon._(
      Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      ),
      key: key,
    );
  }

  /// Iconify 아이콘용 생성자
  ///
  /// icon에는 각 아이콘 세트에서 제공하는 상수를 넘겨주세요.
  /// 예) `Zondicons.airplane`, `Bi.github`, `Ph.house`
  factory AppIcon.iconify({
    Key? key,
    required String icon,
    double size = 24,
    Color? color,
    String? semanticLabel,
  }) {
    Widget child = Iconify(
      icon,
      size: size,
      color: color,
    );
    if (semanticLabel != null && semanticLabel.isNotEmpty) {
      child = Semantics(
        label: semanticLabel,
        child: child,
      );
    }
    return AppIcon._(child, key: key);
  }

  @override
  Widget build(BuildContext context) => _child;
}
