import 'package:flutter/material.dart';
import 'dart:async';

class PulsatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final Duration animationInterval;

  const PulsatingActionButton({
    Key? key,
    required this.onPressed,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.animationInterval = const Duration(seconds: 10),
  }) : super(key: key);

  @override
  _PulsatingActionButtonState createState() => _PulsatingActionButtonState();
}

class _PulsatingActionButtonState extends State<PulsatingActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _widthAnimation;
  late Timer _animationTimer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _widthAnimation = Tween<double>(begin: 56.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start periodic animation with configurable interval
    _animationTimer = Timer.periodic(widget.animationInterval, (timer) {
      _triggerAnimation();
    });
  }

  void _triggerAnimation() async {
    if (!mounted) return;

    setState(() {
      _isExpanded = true;
    });

    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 1500)); // Show expanded state for 1.5 seconds

    if (!mounted) return;

    await _animationController.reverse();

    setState(() {
      _isExpanded = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              height: 56.0,
              width: _widthAnimation.value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isExpanded
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: widget.textColor),
                    SizedBox(width: 8.0),
                    AnimatedOpacity(
                      opacity: _animationController.value,
                      duration: Duration(milliseconds: 200),
                      child: Text(
                        'Make a Ride Request',
                        style: TextStyle(
                          color: widget.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                )
                    : Icon(Icons.add, color: widget.textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}