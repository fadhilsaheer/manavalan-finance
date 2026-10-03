import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import '../core/models.dart';

abstract final class AppTheme {
  static const base = Color(0xfff6f6f6);
  static const mantle = Colors.white;
  static const surface = Color(0xffeeeeee);
  static const overlay = Color(0xffcecece);
  static const text = Color(0xff171717);
  static const muted = Color(0xff686868);
  static const accent = Color(0xff171717);
  static const green = Color(0xff16764d);
  static const red = Color(0xffbe3d47);
  static const peach = Color(0xffa75d16);
  static const blue = Color(0xff171717);
  static const yellow = Color(0xff867016);
  static const blush = Color(0xfff69dcc);
  static const lavender = Color(0xffb392ef);
  static const wash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xfff9d8e9), Color(0xffe9ddfa), Color(0xfffdfbff)],
    stops: [0, .5, 1],
  );
  static const accents = [accent, green, peach, red, yellow, Color(0xff7854ad)];
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Roboto',
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: base,
    colorScheme: const ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      secondary: blue,
      onSecondary: Colors.white,
      surface: mantle,
      onSurface: text,
      onSurfaceVariant: muted,
      error: red,
      onError: Colors.white,
      surfaceContainerHighest: surface,
      outline: overlay,
      outlineVariant: surface,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: -.6,
        color: text,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: -.4,
        color: text,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: text),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: base,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: text,
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      selectedIconTheme: const IconThemeData(color: accent),
      backgroundColor: mantle,
      indicatorColor: accent.withValues(alpha: .1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: mantle,
      labelStyle: const TextStyle(fontFamily: 'Roboto', color: muted),
      hintStyle: const TextStyle(
        fontFamily: 'Roboto',
        color: muted,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: surface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: surface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: muted,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 13,
        color: muted,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: mantle,
      selectedColor: surface,
      side: const BorderSide(color: surface),
      shape: const StadiumBorder(),
      showCheckmark: false,
      labelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: muted,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? surface : mantle,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : muted,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: text,
      contentTextStyle: TextStyle(fontFamily: 'Roboto', color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: surface, space: 1),
    popupMenuTheme: PopupMenuThemeData(
      color: mantle,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        minimumSize: const Size(48, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: surface),
        shape: const StadiumBorder(),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
    ),
  );
}

const appIcons = <String, IconData>{
  'wallet': LucideIcons.wallet300,
  'bank': LucideIcons.landmark300,
  'cash': LucideIcons.banknote300,
  'work': LucideIcons.briefcaseBusiness300,
  'food': LucideIcons.utensils300,
  'car': LucideIcons.car300,
  'home': LucideIcons.house300,
  'bag': LucideIcons.shoppingBag300,
  'health': LucideIcons.heartPulse300,
  'play': LucideIcons.circlePlay300,
  'book': LucideIcons.bookOpen300,
  'travel': LucideIcons.plane300,
  'heart': LucideIcons.heart300,
  'group': LucideIcons.folder300,
  'person': LucideIcons.userRound300,
  'gift': LucideIcons.gift300,
  'coffee': LucideIcons.coffee300,
  'phone': LucideIcons.monitorSmartphone300,
  'fitness': LucideIcons.dumbbell300,
  'pet': LucideIcons.pawPrint300,
  'groceries': LucideIcons.shoppingBasket300,
  'fuel': LucideIcons.fuel300,
  'bus': LucideIcons.bus300,
  'taxi': LucideIcons.carTaxiFront300,
  'repair': LucideIcons.wrench300,
  'rent': LucideIcons.keyRound300,
  'electricity': LucideIcons.zap300,
  'internet': LucideIcons.wifi300,
  'clothing': LucideIcons.shirt300,
  'medicine': LucideIcons.pill300,
  'doctor': LucideIcons.stethoscope300,
  'movies': LucideIcons.clapperboard300,
  'subscription': LucideIcons.repeat300,
  'games': LucideIcons.gamepad2300,
  'course': LucideIcons.graduationCap300,
  'hotel': LucideIcons.bedDouble300,
  'ticket': LucideIcons.ticket300,
  'activity': LucideIcons.sparkles300,
  'care': LucideIcons.flower2300,
  'donation': LucideIcons.handHeart300,
  'salary': LucideIcons.badgeDollarSign300,
  'freelance': LucideIcons.laptop300,
  'business': LucideIcons.store300,
};
IconData iconFor(String key) => appIcons[key] ?? LucideIcons.shapes300;
Color walletColor(int index) =>
    AppTheme.accents[index.abs() % AppTheme.accents.length];

const _categorySymbols = <String, String>{
  'groceries': 'groceries',
  'restaurants': 'food',
  'coffee': 'coffee',
  'fuel': 'fuel',
  'public transport': 'bus',
  'taxi': 'taxi',
  'maintenance': 'repair',
  'rent': 'rent',
  'electricity': 'electricity',
  'internet': 'internet',
  'repairs': 'repair',
  'clothing': 'clothing',
  'electronics': 'phone',
  'household': 'home',
  'medicine': 'medicine',
  'doctor': 'doctor',
  'fitness': 'fitness',
  'movies': 'movies',
  'subscriptions': 'subscription',
  'games': 'games',
  'courses': 'course',
  'books': 'book',
  'fees': 'cash',
  'accommodation': 'hotel',
  'tickets': 'ticket',
  'activities': 'activity',
  'gifts': 'gift',
  'care': 'care',
  'donations': 'donation',
  'salary': 'salary',
  'freelance': 'freelance',
  'business': 'business',
  'other income': 'cash',
};
IconData categoryIcon(Category? category, LedgerSnapshot data) {
  if (category == null) return LucideIcons.shapes300;
  final parent = data.category(category.parentId);
  final key = parent != null && category.icon == parent.icon
      ? _categorySymbols[category.name.toLowerCase()] ?? category.icon
      : category.icon;
  return iconFor(key);
}

Color categoryColor(Category? category, LedgerSnapshot data) {
  if (category == null) return AppTheme.muted;
  if (category.kind == 'income') return AppTheme.green;
  final root = data.category(category.parentId) ?? category;
  return switch (root.icon) {
    'food' => const Color(0xffa86438),
    'car' => const Color(0xff427b9b),
    'home' => const Color(0xff4f7c64),
    'bag' => const Color(0xffa3517c),
    'health' => AppTheme.red,
    'play' => const Color(0xff805ca7),
    'book' => const Color(0xff927222),
    'travel' => const Color(0xff367c80),
    'heart' => const Color(0xffa05576),
    _ => const Color(0xff7b64a0),
  };
}

LinearGradient softTint(Color color, {double strength = .15}) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.lerp(Colors.white, color, strength)!,
    Color.lerp(Colors.white, color, .025)!,
  ],
);
Color cashColor(EntryKind kind, int sign) =>
    (kind == EntryKind.transferIn || kind == EntryKind.transferOut)
    ? AppTheme.muted
    : sign > 0
    ? AppTheme.green
    : AppTheme.red;

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
      Paint()..color = AppTheme.base,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 270, 624, 490),
        const Radius.circular(90),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [AppTheme.blush, AppTheme.lavender],
        ).createShader(const Rect.fromLTWH(200, 270, 624, 490)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 220, 548, 126),
        const Radius.circular(60),
      ),
      Paint()..color = AppTheme.text,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(650, 430, 216, 168),
        const Radius.circular(48),
      ),
      Paint()..color = AppTheme.mantle,
    );
    canvas.drawCircle(
      const Offset(710, 514),
      22,
      Paint()..color = AppTheme.accent,
    );
    for (final (x, top) in [(290.0, 580.0), (380.0, 520.0), (470.0, 460.0)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x, top, x + 50, 660),
          const Radius.circular(20),
        ),
        Paint()..color = AppTheme.mantle,
      );
    }
  }

  @override
  bool shouldRepaint(BrandPainter oldDelegate) => false;
}
