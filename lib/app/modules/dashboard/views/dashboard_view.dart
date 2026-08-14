import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalkulaskor/shared/controllers/theme_controller.dart';
import 'package:kalkulaskor/shared/theme/app_theme.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../shared/helper/helper.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  ThemeController get themeController => Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    // The theme is resolved once here and handed down explicitly.
    //
    // Get.theme is deliberately NOT used in this view. It resolves against
    // the navigator's context, where MaterialApp has wrapped the app in an
    // AnimatedTheme that lerps colors across ~200ms. Read during the same
    // frame as a toggle it still returns the OLD colors, and a widget that
    // reads it never subscribes to Theme - so nothing marks it dirty again
    // once the animation finishes and it stays stuck on the stale color.
    return Obx(() {
      final theme = themeController.isDarkMode.value
          ? AppTheme.dark
          : AppTheme.light;

      return Theme(
        data: theme,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(theme),
          body: _buildBody(theme),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    final textColor = theme.textTheme.bodyLarge?.color;

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: controller.openAboutDialog,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'KalkulaSkor',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            // 1. Define the triggering icon
            icon: const Icon(
              Icons.more_vert,
              size: 28,
              color: Colors.grey,
            ), // Use any icon like Icons.filter_list, Icons.menu, etc.
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                onTap: themeController.toggleTheme,
                value: 'Ganti Tema',
                child: Row(
                  children: [
                    // Shows the mode this will switch *to*, not the current
                    // one. itemBuilder re-runs on every open, so it stays
                    // correct without an Obx.
                    Icon(
                      themeController.isDarkMode.value
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: theme.indicatorColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ganti Tema',
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ),

              PopupMenuItem<String>(
                onTap: () => controller.startTour(),
                value: 'Tutorial',
                child: Row(
                  children: [
                    Icon(
                      Icons.question_mark_rounded,
                      color: theme.indicatorColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tutorial',
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ),

              PopupMenuItem<String>(
                onTap: () => WidgetsBinding.instance.addPostFrameCallback(
                  (_) => controller.openAboutDialog(),
                ),
                value: 'info',
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.indicatorColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Info',
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              PopupMenuItem<String>(
                onTap: () => controller.resetGame(),
                value: 'Mulai Ulang',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: theme.indicatorColor),
                    const SizedBox(width: 10),
                    Text(
                      'Mulai Ulang',
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Get.size * 0.15,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Get.theme.hoverColor, Get.theme.canvasColor],
              center: Alignment.bottomLeft,
              radius: 0.9,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Showcase(
            key: controller.playerNamesShowcaseKey,
            description:
                'Ubah nama masing-masing pemain, mohon gunakan nama yang berbeda-beda.',
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      _IndicatorChip(icon: Icons.flag_circle, text: '500'),
                      _IndicatorChip(
                        icon: Icons.add_circle_outline_rounded,
                        text: '5',
                      ),
                      _IndicatorChip(icon: Icons.person_2_rounded, text: '4'),
                    ],
                  ),
                  Divider(color: Colors.grey, thickness: 1),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < controller.playerNames.length; i++)
                          Expanded(child: _PlayerNameChip(index: i)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      children: [
        Obx(
          () => Column(
            children: [
              for (final round in controller.scores) _ScoreRound(round: round),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Showcase(
                  key: controller.addScoreShowcaseKey,
                  description: 'Tambahkan skor setiap selesai pertandingan',
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.canvasColor,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: controller.openAddScoreDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+ Tambah Skor',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: theme.scaffoldBackgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            shadows: [
                              Shadow(
                                blurRadius: 10, // Softness of the shadow
                                color: theme.indicatorColor, // Shadow color
                                offset: Offset(
                                  0.0,
                                  0.0,
                                ), // X and Y displacement
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: Showcase(
                  key: controller.undoScoreShowcaseKey,
                  description:
                      'Jika terjadi salah input, ubah skor yang baru saja ditambahkan',
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: controller.confirmDeleteLastScore,
                    child: Icon(
                      Icons.history_rounded,
                      size: 28,
                      color: theme.indicatorColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  const _IndicatorChip({required this.icon, required this.text});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Theme.of(context), not Get.theme: this widget sits under the Theme
    // that DashboardView installs, so it both reads the exact theme and
    // registers as a dependent - which is what gets it repainted on toggle.
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(right: 5, left: 5, bottom: 5),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.indicatorColor, size: 18),
          SizedBox(width: 5),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _PlayerNameChip extends GetView<DashboardController> {
  const _PlayerNameChip({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => controller.openEditPlayerNameDialog(index),
      child: Card(
        color: theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Get.width * 0.18,
                child: Text(
                  controller.playerNames[index],
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRound extends StatelessWidget {
  const _ScoreRound({required this.round});

  final List<int> round;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < round.length; i++)
          Expanded(
            child: _ScoreCell(round: round, index: i),
          ),
      ],
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell({required this.round, required this.index});

  final List<int> round;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowest = scoreCellState(round, index) == ScoreCellState.min;
    final highlightColor = theme.colorScheme.error;
    final onHighlightColor = theme.colorScheme.onError;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border(
            top: BorderSide(color: isLowest ? highlightColor : Colors.grey),
          ),
          color: isLowest ? onHighlightColor : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '${round[index]}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isLowest
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
