import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../stores/user_session.dart';
import '../widgets/app_widgets.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserSession().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 72,
              ),
              const SizedBox(height: AppSpacing.section),
              _InfoTile(label: 'Nama Lengkap', value: user?.name ?? '-'),
              const SizedBox(height: AppSpacing.item),
              _InfoTile(label: 'Email', value: user?.email ?? '-'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(color: AppColors.textHint)),
          const SizedBox(height: AppSpacing.micro),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
