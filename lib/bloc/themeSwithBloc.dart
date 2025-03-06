import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/theme.dart';

// Define the theme states
abstract class ThemeState {
  final ThemeData themeData;

  ThemeState(this.themeData);
}

class LightThemeState extends ThemeState {
  LightThemeState() : super(_lightTheme);

  static final ThemeData _lightTheme = AppThemes.lightTheme;
}

class DarkThemeState extends ThemeState {
  DarkThemeState() : super(_darkTheme);

  static final ThemeData _darkTheme = AppThemes.darkTheme;
}

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// Define the BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState()) {


    on<ToggleThemeEvent>((event, emit) {
      if (state is LightThemeState) {
        emit(DarkThemeState());
      } else {
        emit(LightThemeState());
      }
    });
  }
}