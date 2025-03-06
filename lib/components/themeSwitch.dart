import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/bloc/themeSwithBloc.dart';

class Themeswitch extends StatelessWidget {
  const Themeswitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final icon = state is LightThemeState ? Icons.dark_mode : Icons.light_mode;
        final iconColor = state is LightThemeState ? Colors.black : Colors.yellow;

        return FloatingActionButton(
          onPressed: () {
            context.read<ThemeBloc>().add(ToggleThemeEvent());
          },
          backgroundColor: Colors.transparent,
          elevation: 0, // Add shadow
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), // Smooth transition
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Icon(
              icon,
              key: ValueKey(icon), // Unique key for animation
              color: iconColor,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}