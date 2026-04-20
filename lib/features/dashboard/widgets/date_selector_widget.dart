import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helpers/app_colors.dart';

class DateSelectorWidget extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late ScrollController _scrollCtrl;
  final List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    final today = DateTime.now();
    for (int i = -14; i <= 0; i++) {
      _dates.add(today.add(Duration(days: i)));
    }
    // Scroll to end (today)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  static const List<String> _weekDay = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          final date = _dates[i];
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected
                    ? null
                    : isDark
                        ? AppColors.darkCard
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primaryLight, width: 1.5)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekDay[date.weekday % 7],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
