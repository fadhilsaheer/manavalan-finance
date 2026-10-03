import 'package:flutter/material.dart';

import '../core/models.dart';

abstract final class AppTheme {
  static const base = Color(0xfff7f6f8);
  static const mantle = Colors.white;
  static const surface = Color(0xffeeecf1);
  static const overlay = Color(0xffc5c0cf);
  static const text = Color(0xff201d25);
  static const muted = Color(0xff706a78);
  static const accent = Color(0xff7850b8);
  static const green = Color(0xff16764d);
  static const red = Color(0xffbe3d47);
  static const peach = Color(0xffa75d16);
  static const blue = Color(0xff7850b8);
  static const yellow = Color(0xff867016);
  static const blush = Color(0xfff4c7e4);
  static const lavender = Color(0xffd9c9f6);
  static const wash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xfff6d6e9), Color(0xffe3d7f9), Color(0xfffaf8fc)],
    stops: [0, .5, 1],
  );
  static const accents = [accent, green, peach, red, yellow, Color(0xff7854ad)];
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Roboto',
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
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: -.8,
        color: text,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -.4,
        color: text,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.w600,
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
      selectedColor: text,
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
          (states) => states.contains(WidgetState.selected) ? text : mantle,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : muted,
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
        backgroundColor: text,
        minimumSize: const Size(48, 54),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
      backgroundColor: text,
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
  'groceries': Icons.local_grocery_store_outlined,
  'fuel': Icons.local_gas_station_outlined,
  'bus': Icons.directions_bus_outlined,
  'taxi': Icons.local_taxi_outlined,
  'repair': Icons.handyman_outlined,
  'rent': Icons.key_outlined,
  'electricity': Icons.bolt_outlined,
  'internet': Icons.wifi_rounded,
  'clothing': Icons.checkroom_outlined,
  'medicine': Icons.medication_outlined,
  'doctor': Icons.medical_services_outlined,
  'movies': Icons.movie_outlined,
  'subscription': Icons.subscriptions_outlined,
  'games': Icons.sports_esports_outlined,
  'course': Icons.school_outlined,
  'hotel': Icons.hotel_outlined,
  'ticket': Icons.confirmation_number_outlined,
  'activity': Icons.local_activity_outlined,
  'care': Icons.spa_outlined,
  'donation': Icons.volunteer_activism_outlined,
  'salary': Icons.badge_outlined,
  'freelance': Icons.laptop_mac_outlined,
  'business': Icons.storefront_outlined,
};
IconData iconFor(String key) => appIcons[key] ?? Icons.category_outlined;
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
  if (category == null) return Icons.category_outlined;
  final parent = data.category(category.parentId);
  final key = parent != null && category.icon == parent.icon
      ? _categorySymbols[category.name.toLowerCase()] ?? category.icon
      : category.icon;
  return iconFor(key);
}

Color categoryColor(Category? category, LedgerSnapshot data) {
  if (category == null) return AppTheme.muted;
  final root = data.category(category.parentId) ?? category;
  return switch (root.icon) {
    'food' => const Color(0xffa66526),
    'car' => const Color(0xff427da0),
    'home' => const Color(0xff548069),
    'bag' => const Color(0xffa45483),
    'health' => const Color(0xffa65560),
    'play' => const Color(0xff7d62b1),
    'book' => const Color(0xff957526),
    'travel' => const Color(0xff397e83),
    'heart' => const Color(0xffa15d7d),
    'work' => AppTheme.green,
    _ => AppTheme.accent,
  };
}

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
      Paint()..color = AppTheme.accent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, 220, 548, 126),
        const Radius.circular(60),
      ),
      Paint()..color = const Color(0xffd38cb9),
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
