import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Reusable, 2.5D styled 5-tab floating bottom navigation bar for Luna Tracker.
class LunaBottomNavBar extends StatelessWidget {
  const LunaBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  /// 0: Home, 1: Calendar, 2: Care, 3: Relax, 4: Profile
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  static const items = [
    (Icons.home_rounded, 'Home'),
    (Icons.calendar_month_outlined, 'Calendar'),
    (Icons.favorite_rounded, 'Care'),
    (Icons.music_note_rounded, 'Relax'),
    (Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFAFFFFFF),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.lightPink, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20704B69),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selectedTab,
                label: items[i].$2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => onTabSelected(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].$1,
                        size: 26,
                        color: i == selectedTab
                            ? AppColors.primary
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == selectedTab
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == selectedTab
                              ? AppColors.primary
                              : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == selectedTab ? 36 : 0,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: i == selectedTab
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
