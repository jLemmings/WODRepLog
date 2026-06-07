import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(104);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF001A27),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF244F78), width: 1.4),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 18),
              const Text(
                'WODREPLOG',
                style: TextStyle(
                  color: Color(0xFF347FFF),
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
