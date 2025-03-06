import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/bloc/themeSwithBloc.dart';
import 'package:tour_ease/theme.dart';
import 'package:tour_ease/view/auth.dart';
import 'package:tour_ease/view/mainPage.dart';
import 'package:tour_ease/view/page2.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => ThemeBloc(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          theme: state.themeData,
          darkTheme: AppThemes.darkTheme,
          home: ScreenUtilInit(
            designSize: const Size(360, 800),
            builder: (_, child) => const AuthScreen(),
          ),
        );
      },
    );
  }
}
