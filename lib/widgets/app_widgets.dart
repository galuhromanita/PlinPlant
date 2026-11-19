import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export '../theme/app_colors.dart';
export '../theme/app_spacing.dart';
import '../models/plant_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.eco_rounded,
                label: 'Tanaman',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textHint,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.micro),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge status tanaman
class StatusBadge extends StatelessWidget {
  final PlantStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    IconData icon;

    switch (status) {
      case PlantStatus.safe:
        color = AppColors.success;
        bgColor = AppColors.successBg;
        icon = Icons.check_circle_rounded;
        break;
      case PlantStatus.due:
        color = AppColors.warning;
        bgColor = AppColors.warningBg;
        icon = Icons.opacity_rounded;
        break;
      case PlantStatus.overdue:
        color = AppColors.danger;
        bgColor = AppColors.dangerBg;
        icon = Icons.warning_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.item,
        vertical: AppSpacing.tight,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.tight),
          Text(
            status.label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol utama hijau
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.tight),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Tombol outline
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: c,
        minimumSize: const Size(double.infinity, AppSizes.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          side: BorderSide(color: c, width: 1.5),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.tight),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon lingkaran tanaman placeholder
class PlantAvatarPlaceholder extends StatelessWidget {
  final double size;
  final String? imagePath;

  const PlantAvatarPlaceholder({super.key, this.size = 70, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imagePath != null && imagePath!.startsWith('http');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(size * 0.2),
        image: !isNetworkImage && imagePath != null
            ? DecorationImage(image: AssetImage(imagePath!), fit: BoxFit.cover)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetworkImage
          ? Image.network(
              imagePath!,
              fit: BoxFit.cover,
              // key berdasarkan URL agar widget rebuild ketika foto berubah
              key: ValueKey(imagePath),
              loadingBuilder: (ctx, child, progress) =>
                  progress == null ? child : _placeholder(),
              errorBuilder: (ctx, err, stack) => _placeholder(),
            )
          : imagePath == null
          ? _placeholder()
          : null,
    );
  }

  Widget _placeholder() =>
      Icon(Icons.eco_rounded, color: AppColors.primary, size: size * 0.5);
}

/// Card tanaman di list
class PlantListCard extends StatelessWidget {
  final String name;
  final String species;
  final PlantStatus status;
  final String timeText;
  final String? imagePath;
  final VoidCallback? onTap;

  const PlantListCard({
    super.key,
    required this.name,
    required this.species,
    required this.status,
    required this.timeText,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            PlantAvatarPlaceholder(imagePath: imagePath, size: 64),
            const SizedBox(width: AppSpacing.item),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Divider(),
                  // const SizedBox(height: AppSpacing.micro),
                  Text(
                    species,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                  // const SizedBox(height: AppSpacing.item),
                  StatusBadge(status: status),
                  // const SizedBox(height: AppSpacing.item),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      // const SizedBox(width: AppSpacing.tight),
                      Text(
                        timeText,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

/// Success popup / notification popup
Future<void> showSuccessPopup(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SuccessDialog(title: title, message: message),
  );
}

class _SuccessDialog extends StatelessWidget {
  final String title;
  final String message;

  const _SuccessDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.item),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            PrimaryButton(label: 'OK', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

/// Delete popup
Future<bool?> showDeleteConfirmDialog(BuildContext context, String name) {
  return showConfirmDialog(
    context,
    title: 'Hapus Tanaman?',
    message: '$name akan dihapus dari daftar Anda.',
    confirmLabel: 'Hapus',
    icon: Icons.delete_rounded,
  );
}

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required IconData icon,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      icon: icon,
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final IconData icon;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.danger, size: 32),
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.item),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Batal',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: AppSpacing.item),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
