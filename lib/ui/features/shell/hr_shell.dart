import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../firebase/firebase_bootstrap.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/views/dashboard_page.dart';
import '../departments/views/departments_page.dart';
import '../employees/views/employees_page.dart';
import '../more/views/more_page.dart';
import '../queries/views/queries_page.dart';

class HrShell extends StatefulWidget {
  const HrShell({super.key, required this.useCupertino});

  final bool useCupertino;

  @override
  State<HrShell> createState() => _HrShellState();
}

class _HrShellState extends State<HrShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<FirebaseBootstrapStatus>();
    final pages = [
      DashboardPage(useCupertino: widget.useCupertino),
      EmployeesPage(useCupertino: widget.useCupertino),
      DepartmentsPage(useCupertino: widget.useCupertino),
      QueriesPage(useCupertino: widget.useCupertino),
      MorePage(status: status, useCupertino: widget.useCupertino),
    ];

    if (widget.useCupertino) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: AppColors.brand,
          inactiveColor: const Color(0xFF8F899B),
          backgroundColor: Colors.white.withValues(alpha: .96),
          border: const Border(top: BorderSide(color: AppColors.line)),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_alt),
              activeIcon: Icon(CupertinoIcons.house_alt_fill),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_2),
              activeIcon: Icon(CupertinoIcons.person_2_fill),
              label: 'Funcionarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.briefcase),
              activeIcon: Icon(CupertinoIcons.briefcase_fill),
              label: 'Departamentos',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              activeIcon: Icon(CupertinoIcons.search_circle_fill),
              label: 'Consultas',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2),
              activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
              label: 'Mais',
            ),
          ],
        ),
        tabBuilder: (_, index) =>
            CupertinoTabView(builder: (_) => pages[index]),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Funcionarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Departamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Consultas',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
