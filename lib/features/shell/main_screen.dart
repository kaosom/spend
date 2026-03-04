import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';
import 'tabs/insights_tab.dart';
import '../../design_system/organisms/add_transaction_sheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to Insight tab based on the request

  final List<Widget> _tabs = [
    const Center(child: Text('Inicio Content')), // Placeholder for "Home"
    const InsightsTab(), // The new "Insights" screen
    const SizedBox.shrink(), // Placeholder for FAB
    const Center(
      child: Text('Transacciones'),
    ), // Placeholder for "Transactions"
    const Center(child: Text('Perfil')), // Placeholder for "Profile"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AvidTokens.backgroundPrimary,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: AvidTokens.accentPrimary, // Dark black button
        shape: BoxShape.circle,
        boxShadow: AvidTokens.shadowMedium,
      ),
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: AvidTokens.backgroundSecondary,
      surfaceTintColor: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_outlined, label: 'Inicio', index: 0),
          _buildNavItem(icon: Icons.bar_chart, label: 'Resumen', index: 1),
          const SizedBox(width: 48), // Space for FAB
          _buildNavItem(icon: Icons.sync_alt, label: 'Transacción', index: 3),
          _buildNavItem(icon: Icons.person_outline, label: 'Perfil', index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AvidTokens.textPrimary : AvidTokens.textTertiary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: AvidTokens.labelSmall.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
