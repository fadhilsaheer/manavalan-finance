import 'package:flutter/material.dart';

abstract final class Mocha {
  static const base = Color(0xff1e1e2e);
  static const mantle = Color(0xff181825);
  static const surface = Color(0xff313244);
  static const overlay = Color(0xff585b70);
  static const text = Color(0xffcdd6f4);
  static const muted = Color(0xffa6adc8);
  static const mauve = Color(0xffcba6f7);
  static const green = Color(0xffa6e3a1);
  static const red = Color(0xfff38ba8);
  static const peach = Color(0xfffab387);
  static const blue = Color(0xff89b4fa);
  static const yellow = Color(0xfff9e2af);
  static const accents = [mauve, blue, green, peach, yellow, red];
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: base,
    colorScheme: const ColorScheme.dark(
      primary: mauve,
      onPrimary: mantle,
      secondary: blue,
      onSecondary: mantle,
      surface: base,
      onSurface: text,
      onSurfaceVariant: muted,
      error: red,
      onError: mantle,
      surfaceContainerHighest: surface,
      outline: overlay,
      outlineVariant: surface,
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: base,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: mantle,
      indicatorColor: mauve.withValues(alpha: .18),
      height: 76,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: mantle,
      indicatorColor: mauve.withValues(alpha: .18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: mantle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: surface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: surface),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: text),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: surface, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: mauve,
      foregroundColor: mantle,
      elevation: 0,
      focusElevation: 1,
      hoverElevation: 1,
      highlightElevation: 1,
    ),
  );
}

const appIcons = <String, IconData>{
  'wallet': Icons.account_balance_wallet_outlined,
  'bank': Icons.account_balance_outlined,
  'cash': Icons.payments_outlined,
  'work': Icons.work_outline_rounded,
  'food': Icons.restaurant_rounded,
  'car': Icons.directions_car_outlined,
  'home': Icons.home_outlined,
  'bag': Icons.shopping_bag_outlined,
  'health': Icons.health_and_safety_outlined,
  'play': Icons.play_circle_outline,
  'book': Icons.menu_book_outlined,
  'travel': Icons.flight_outlined,
  'heart': Icons.favorite_border_rounded,
  'group': Icons.folder_outlined,
  'person': Icons.person_outline_rounded,
  'gift': Icons.card_giftcard_outlined,
  'coffee': Icons.coffee_outlined,
  'phone': Icons.devices_outlined,
  'fitness': Icons.fitness_center_rounded,
  'pet': Icons.pets_outlined,
};
IconData iconFor(String key) => appIcons[key] ?? Icons.category_outlined;
Color walletColor(int index) =>
    Mocha.accents[index.abs() % Mocha.accents.length];

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Manavalan Finance',
    image: true,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: BrandPainter()),
    ),
  );
}

class BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 1024, size.height / 1024);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 1024, 1024),
        const Radius.circular(224),
      ),
      Paint()..color = Mocha.base,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 270, 624, 490),
        const Radius.circular(90),
      ),
      Paint()..color = Mocha.mauve,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 220, 548, 126),
        const Radius.circular(60),
      ),
      Paint()..color = Mocha.blue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(650, 430, 216, 168),
        const Radius.circular(48),
      ),
      Paint()..color = Mocha.mantle,
    );
    canvas.drawCircle(const Offset(710, 514), 22, Paint()..color = Mocha.peach);
    for (final (x, top) in [(290.0, 580.0), (380.0, 520.0), (470.0, 460.0)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x, top, x + 50, 660),
          const Radius.circular(20),
        ),
        Paint()..color = Mocha.mantle,
      );
    }
  }

  @override
  bool shouldRepaint(BrandPainter oldDelegate) => false;
}
