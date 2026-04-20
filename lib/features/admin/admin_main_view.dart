import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_colors.dart';
import 'admin_controller.dart';
import 'admin_home_view.dart';
import 'user_management_view.dart';
import 'food_management_view.dart';
import 'submission_management_view.dart';
import '../profile/profile_view.dart';
import '../recommendation/recommendation_controller.dart';

class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadAll();
      context.read<RecommendationController>().loadAll();
    });
  }

  final List<Widget> _pages = const [
    AdminHomeView(),
    UserManagementView(),
    FoodManagementView(),
    SubmissionManagementView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedLabelStyle:
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group_rounded),
              label: 'Pengguna',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Makanan',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.pending_actions_outlined),
                  if (admin.pendingCount > 0)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        width: 14, height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${admin.pendingCount}',
                            style: GoogleFonts.poppins(
                                fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.pending_actions_rounded),
              label: 'Pengajuan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
