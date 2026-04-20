import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../helpers/app_colors.dart';
import '../auth/auth_controller.dart';
import 'history_controller.dart';
import 'models/history_model.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthController>().currentUser?.id ?? '';
      context.read<HistoryController>().loadHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hist = context.watch<HistoryController>();
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = auth.currentUser!;

    // Group by date
    final Map<String, List<HistoryModel>> grouped = {};
    for (final h in hist.userHistory) {
      final key = DateFormat('yyyy-MM-dd').format(h.date);
      grouped.putIfAbsent(key, () => []).add(h);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Riwayat Konsumsi'),
        automaticallyImplyLeading: false,
      ),
      body: hist.userHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 64,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                  const SizedBox(height: 12),
                  Text('Belum ada riwayat konsumsi',
                      style: GoogleFonts.poppins(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: sortedKeys.length,
              itemBuilder: (_, i) {
                final key = sortedKeys[i];
                final entries = grouped[key]!;
                final date = DateTime.parse(key);
                final totalCal = entries.fold<double>(
                    0, (s, h) => s + h.totalCalories);
                final dailyTarget = user.dailyCalorieNeed ?? 2000;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Date header ───
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDate(date),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (totalCal > dailyTarget
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${totalCal.toStringAsFixed(0)} kkal',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: totalCal > dailyTarget
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Entries ───
                    ...entries.map((h) => _entryCard(context, h, user.id, isDark)),
                  ],
                );
              },
            ),
    );
  }

  Widget _entryCard(BuildContext context, HistoryModel h, String userId, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _mealColor(h.mealType).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_mealIcon(h.mealType),
                color: _mealColor(h.mealType), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.foodName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    )),
                Text(
                  '${h.amount.toStringAsFixed(0)}g · ${h.mealType} · ${DateFormat('HH:mm').format(h.date)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${h.totalCalories.toStringAsFixed(0)} kkal',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context, h, userId),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, HistoryModel h, String userId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Entry',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Hapus "${h.foodName}" dari riwayat?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<HistoryController>().deleteEntry(h.id, userId);
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return 'Hari Ini';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.day == yesterday.day &&
        d.month == yesterday.month &&
        d.year == yesterday.year) {
      return 'Kemarin';
    }
    return DateFormat('EEEE, d MMMM yyyy', 'id').format(d);
  }

  Color _mealColor(String mealType) {
    switch (mealType) {
      case 'Sarapan': return Colors.amber;
      case 'Makan Siang': return AppColors.info;
      case 'Makan Malam': return Colors.deepPurple;
      default: return AppColors.primaryLight;
    }
  }

  IconData _mealIcon(String mealType) {
    switch (mealType) {
      case 'Sarapan': return Icons.wb_sunny_rounded;
      case 'Makan Siang': return Icons.lunch_dining_rounded;
      case 'Makan Malam': return Icons.nights_stay_rounded;
      default: return Icons.cookie_rounded;
    }
  }
}
