import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idea_rel/common/theme/app_colors.dart';

// 테마 기반 시스템!
class AppTheme {
  static const String fontFamily = 'Pretendard';
  static const String suitFontFamily = 'SUIT';

  // fontWeight를 fontVariations로 변환하는 헬퍼 함수
  static List<FontVariation> _getFontVariations(FontWeight fontWeight) {
    double weight;
    switch (fontWeight) {
      case FontWeight.w100:
        weight = 100;
        break;
      case FontWeight.w200:
        weight = 200;
        break;
      case FontWeight.w300:
        weight = 300;
        break;
      case FontWeight.w400:
        weight = 400;
        break;
      case FontWeight.w500:
        weight = 500;
        break;
      case FontWeight.w600:
        weight = 600;
        break;
      case FontWeight.w700:
        weight = 700;
        break;
      case FontWeight.w800:
        weight = 800;
        break;
      case FontWeight.w900:
        weight = 900;
        break;
      default:
        weight = 400;
    }
    return [FontVariation('wght', weight)];
  }

  // Android용 안전한 TextStyle 생성
  static TextStyle _createSafeTextStyle({
    required double fontSize,

    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (Platform.isAndroid) {
      return TextStyle(
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontVariations: _getFontVariations(fontWeight),
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    } else {
      return TextStyle(
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: AppColors.glay80, // 진한 회색 (버튼, 중요 요소)
        secondary: Color(0xFF757575), // 중간 회색 (보조 요소)
        surface: Colors.white, // 카드, 다이얼로그 배경
        onSurface: AppColors.glay80, // 텍스트 색상
        error: AppColors.redColor, // 에러 색상 (빨간색)
        onPrimary: Colors.white, // primary 위의 텍스트
        onSecondary: Colors.white, // secondary 위의 텍스트
        outline: AppColors.line, // 테두리 색상
        surfaceContainerHighest: Color(0xFFF5F5F5), // 배경 변화 색상
      ),

      // 앱바 테마 설정
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // 앱바 배경 흰색
        surfaceTintColor: Colors.transparent, // Material 3 tint 제거
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.glay80, // 아이콘 색상
        ),
        titleTextStyle: TextStyle(
          color: AppColors.glay80, // 타이틀 텍스트 색상
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        // 큰 제목들 (Weight 600)
        displayLarge: _createSafeTextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        displayMedium: _createSafeTextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        displaySmall: _createSafeTextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        // 아래가 사용중
        // 헤드라인 500 ~ 600
        headlineLarge: _createSafeTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        headlineMedium: _createSafeTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.33,
        ),
        headlineSmall: _createSafeTextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),

        // 타이틀 (Weight 500-600)
        titleLarge: _createSafeTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleMedium: _createSafeTextStyle(
          // 1
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleSmall: _createSafeTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),

        // 본문 (Weight 400)
        bodyLarge: _createSafeTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        bodyMedium: _createSafeTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        bodySmall: _createSafeTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),

        // 라벨 (Weight 500)
        labelLarge: _createSafeTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        labelMedium: _createSafeTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        labelSmall: _createSafeTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // SUIT 폰트 전용 TextStyle들
  static const TextStyle suitBold = TextStyle(
    fontFamily: suitFontFamily,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle suitExtraBold = TextStyle(
    fontFamily: suitFontFamily,
    fontWeight: FontWeight.w800,
  );

  // 자주 사용할 SUIT 스타일들을 미리 정의
  static TextStyle suitBoldText({
    double fontSize = 22,
    Color? color = AppColors.black,
    double? letterSpacing = -0.2,
    double? height = 1,
  }) {
    return suitBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitBoldSubText({
    double fontSize = 18,
    Color? color = AppColors.black,
    double? letterSpacing = -0.5,
    double? height = 1,
  }) {
    return suitBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitBoldMSizeText({
    double fontSize = 16,
    Color? color = AppColors.black,
    double? letterSpacing = -0.4,
    double? height = 1.4,
  }) {
    return suitBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitBoldSizeText({
    double fontSize = 14,
    Color? color = AppColors.black,
    double? letterSpacing = 0,
    double? height = 1,
  }) {
    return suitBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// 에ㄱ스트라-------
  ///
  static TextStyle suitEBoldBHText({
    double fontSize = 24,
    Color? color = AppColors.black,
    double? letterSpacing = -0.4,
    double? height = 1.2,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitEBoldBText({
    double fontSize = 20,
    Color? color = AppColors.black,
    double? letterSpacing = -0.4,
    double? height = 1,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitEBoldAppBarText({
    double fontSize = 18,
    Color? color = AppColors.black,
    double? letterSpacing = 0,
    double? height = 1,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitEBoldMText({
    double fontSize = 14,
    Color? color = AppColors.black,
    double? letterSpacing = -0.2,
    double? height = 1.2,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitEBoldTitleText({
    double fontSize = 22,
    Color? color = AppColors.black,
    double? letterSpacing = -0.2,
    double? height = 1.3,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitEBoldSubText({
    double fontSize = 16,
    Color? color = AppColors.black,
    double? letterSpacing = 0,
    double? height = 1,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle suitEBoldSmallText({
    double fontSize = 13,
    Color? color = AppColors.black,
    double? letterSpacing = 0,
    double? height = 1,
  }) {
    return suitExtraBold.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}



/*
ColorScheme 속성별 적용 위젯들
1. primary (AppColors.mainColor - 0xFF00B1FF)
주요 컴포넌트와 액션에 사용되는 핵심 색상
적용되는 위젯들:

FloatingActionButton - 배경색
ElevatedButton - 배경색
TextButton - 텍스트/아이콘 색상
OutlinedButton - 테두리 색상
Checkbox - 체크 시 배경색
Radio - 선택 시 색상
Switch - 활성화 시 색상
CircularProgressIndicator - 진행 바 색상
LinearProgressIndicator - 진행 바 색상
Slider - 활성 트랙 색상
BottomNavigationBar - 선택된 아이템 색상

2. secondary (AppColors.subColor - 0xFF468FEA)
덜 중요한 컴포넌트에 사용되어 색상 표현 기회를 확장하는 색상
적용되는 위젯들:

Chip - 배경색 (일부 스타일)
FilterChip - 배경색
ToggleButton - 선택되지 않은 상태
FloatingActionButton (secondary) - 보조 FAB
AppBar - 보조 액션들
일부 Icon - 보조 아이콘들

3. surface (Colors.white)
배경과 큰 저강조 영역에 사용되는 표면 색상
적용되는 위젯들:

Scaffold - body 배경색
AppBar - 배경색 (Material 3 기본)
Card - 배경색
Dialog - 배경색
BottomSheet - 배경색
Drawer - 배경색
NavigationRail - 배경색
BottomAppBar - 배경색
DataTable - 배경색

4. onSurface (AppColors.black - 0xFF32383D)
Surface 위에 그려지는 모든 콘텐츠의 색상
적용되는 위젯들:

모든 Text - 기본 텍스트 색상
Icon - 기본 아이콘 색상
ListTile - 제목/부제목 색상
TextField - 입력 텍스트 색상
AppBar - 제목/아이콘 색상 (surface 배경 위)
TabBar - 탭 텍스트/아이콘
Divider - 구분선 색상
Chip - 라벨 텍스트

5. onPrimary (Colors.white)
Primary 색상 위에 그려지는 콘텐츠 색상
적용되는 위젯들:

ElevatedButton - 텍스트/아이콘 색상
FloatingActionButton - 아이콘 색상
Chip (primary) - 텍스트 색상
Badge - 텍스트 색상
primary 배경을 가진 모든 위젯의 텍스트/아이콘

6. error (AppColors.redColor - 0xFFFF696C)
에러 상태를 나타내는 색상
적용되는 위젯들:

TextField - 에러 상태 테두리
FormField - 에러 메시지 색상
InputDecoration - 에러 텍스트
SnackBar (error) - 에러 알림
AlertDialog - 에러 다이얼로그
TextButton (destructive) - 삭제/취소 버튼

*/