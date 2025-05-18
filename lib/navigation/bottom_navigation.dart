import 'package:flutter/material.dart';
import 'package:wineline/pages/add_bottle.dart';

import 'package:wineline/pages/manager_page.dart';
import 'package:wineline/pages/map_page.dart';
import 'package:wineline/pages/recomendation_page.dart';

class NavigationItem {
  final Widget page;
  final IconData icon;
  final String label;
  final String description;
  final Color activeColor;
  final Color inactiveColor;

  const NavigationItem({
    required this.page,
    required this.icon,
    required this.label,
    required this.description,
    this.activeColor = const Color(0xFFF4570C),
    this.inactiveColor = Colors.white70,
  });
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      page: MapPage(),
      icon: Icons.location_on,
      label: '',
      description: '',
      activeColor: Color(0xFFF4570C),
    ),
    NavigationItem(
      page: RecomendationPage(),
      icon: Icons.star,
      label: '',
      description: '',
      activeColor: Color(0xFFF4570C),
    ),
    NavigationItem(
      page: ManagerPage(),
      icon: Icons.group,
      label: '',
      description: '',
      activeColor: Color(0xFFF4570C),
    ),
    NavigationItem(
      page: AddBottle(),
      icon: Icons.lightbulb,
      label: ' ',
      description: '',
      activeColor: Color(0xFFF4570C),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navigationItems[_selectedIndex].page,
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_navigationItems.length, (index) {
            final item = _navigationItems[index];
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                width: 80,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration:
                          isSelected
                              ? BoxDecoration(
                                color: item.activeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              )
                              : null,
                      padding:
                          isSelected
                              ? const EdgeInsets.all(12)
                              : const EdgeInsets.all(0),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: isSelected ? 32 : 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color:
                            isSelected ? item.activeColor : item.inactiveColor,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
