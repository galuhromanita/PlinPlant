import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/plant_model.dart';
import '../services/photo_service.dart';
import '../stores/plant_store.dart';
import '../widgets/app_widgets.dart';

enum _PhotoOption { gallery, camera, remove }

class AddPlantScreen extends StatefulWidget {
  final PlantModel? plantToEdit;

  const AddPlantScreen({super.key, this.plantToEdit});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController =
      TextEditingController(); // [3] Jenis tanaman input bebas
  final _speciesController = TextEditingController();
  int _waterInterval = 3;
  final _waterIntervalController = TextEditingController();
  DateTime? _lastWatered;

  bool _fertilizerEnabled = false;
  int _fertilizerInterval = 7;
  final _fertilizerIntervalController = TextEditingController();
  DateTime? _lastFertilized;

  bool _isSaving = false;

  // ── Foto ─────────────────────────────────────────────────────
  XFile? _pickedPhoto; // File yang dipilih dari galeri / kamera
  String? _existingPhotoUrl; // URL foto lama (saat edit)
  final _photoService = PhotoService();

  bool get _isEdit => widget.plantToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.plantToEdit!;
      _nameController.text = p.name;
      _speciesController.text = p.species;
      _waterInterval = p.wateringIntervalDays;
      _lastWatered = p.lastWatered;
      _fertilizerEnabled = p.fertilizerEnabled;
      _fertilizerInterval = p.fertilizerIntervalDays;
      _lastFertilized = p.lastFertilized;
      _existingPhotoUrl = p.imagePath; // Simpan URL foto lama
    }
    _waterIntervalController.text = '$_waterInterval';
    _fertilizerIntervalController.text = '$_fertilizerInterval';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _waterIntervalController.dispose();
    _fertilizerIntervalController.dispose();
    super.dispose();
  }

  // ── Tampilkan pilihan sumber foto ────────────────────────────
  Future<void> _showPhotoOptions() async {
    final action = await showModalBottomSheet<_PhotoOption>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                'Pilih dari Galeri',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              onTap: () => Navigator.pop(ctx, _PhotoOption.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                'Ambil Foto',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              onTap: () => Navigator.pop(ctx, _PhotoOption.camera),
            ),
            // Tombol hapus foto (hanya tampil jika sudah ada foto)
            if (_pickedPhoto != null || _existingPhotoUrl != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                ),
                title: Text(
                  'Hapus Foto',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.danger,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, _PhotoOption.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (action == _PhotoOption.remove) {
      setState(() {
        _pickedPhoto = null;
        _existingPhotoUrl = null;
      });
      return;
    }
    if (action == null) return;

    XFile? picked;
    if (action == _PhotoOption.gallery) {
      // pickFromGallery() sudah menangani permission Android ≤12 secara internal.
      picked = await _photoService.pickFromGallery();

      // Jika null: kemungkinan permission ditolak (Android ≤12)
      if (!mounted) return;
      if (picked == null) {
        final permanentlyDenied =
            await _photoService.isGalleryPermissionPermanentlyDenied();
        // Hanya tampilkan dialog jika permission benar-benar diperlukan & ditolak
        if (permanentlyDenied) {
          await _showPermissionDenied(
            title: 'Akses galeri diperlukan',
            message:
                'Izinkan akses galeri di Pengaturan untuk memilih foto tanaman.',
            permanentlyDenied: true,
          );
        }
        // Jika bukan karena permission (user cancel), tidak perlu dialog
        return;
      }
    } else {
      final allowed = await _photoService.requestCameraPermission();
      if (!allowed) {
        if (!mounted) return;
        await _showPermissionDenied(
          title: 'Akses kamera diperlukan',
          message:
              'Izinkan akses kamera untuk mengambil foto tanaman langsung.',
          permanentlyDenied:
              await _photoService.isCameraPermissionPermanentlyDenied(),
        );
        return;
      }
      picked = await _photoService.captureFromCamera();
    }

    if (!mounted || picked == null) return;
    setState(() => _pickedPhoto = picked);
  }

  Future<void> _showPermissionDenied({
    required String title,
    required String message,
    required bool permanentlyDenied,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Nanti'),
          ),
          if (permanentlyDenied)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
        ],
      ),
    );
  }

  // Simpan

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Setelah valid, controller dan state memakai angka yang sama saat disimpan.
    _waterInterval = int.tryParse(_waterIntervalController.text) ?? 3;
    if (_fertilizerEnabled) {
      _fertilizerInterval =
          int.tryParse(_fertilizerIntervalController.text) ?? 7;
    }

    setState(() => _isSaving = true);
    final store = PlantStore();

    if (!_isEdit) {
      // ── TAMBAH TANAMAN ─────────────────────────────────────
      // 1. Insert dulu untuk dapat id_tanaman
      final newPlant = PlantModel(
        id: store.generateId(),
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        wateringIntervalDays: _waterInterval,
        lastWatered: _lastWatered!,
        fertilizerEnabled: _fertilizerEnabled,
        fertilizerIntervalDays: _fertilizerEnabled ? _fertilizerInterval : 7,
        lastFertilized: _fertilizerEnabled ? _lastFertilized : null,
      );
      final insertedPlant = await store.addPlant(newPlant);
      if (insertedPlant == null) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tanaman gagal disimpan. Periksa koneksi lalu coba lagi.',
            ),
          ),
        );
        return;
      }

      // 2. Upload foto jika ada, lalu update foto_url
      if (_pickedPhoto != null) {
        final photoUrl = await store.uploadPlantPhoto(
          file: _pickedPhoto!,
          plantId: insertedPlant.id,
        );
        if (photoUrl != null) {
          final updated = insertedPlant.copyWith(imagePath: photoUrl);
          await store.updatePlant(updated);
        } else if (mounted) {
          // Upload gagal — tunjukkan pesan ke pengguna
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Foto gagal diupload. Pastikan bucket "plant-photos" '
                'sudah dibuat di Supabase Storage sebagai public bucket.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      // ── EDIT TANAMAN ───────────────────────────────────────
      String? resolvedPhotoUrl = _existingPhotoUrl;

      // Upload foto baru jika pengguna memilih
      if (_pickedPhoto != null) {
        final uploadedUrl = await store.uploadPlantPhoto(
          file: _pickedPhoto!,
          plantId: widget.plantToEdit!.id,
        );
        if (uploadedUrl != null) {
          resolvedPhotoUrl = uploadedUrl;
        }
      }

      final updated = widget.plantToEdit!.copyWith(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        wateringIntervalDays: _waterInterval,
        lastWatered: _lastWatered!,
        fertilizerEnabled: _fertilizerEnabled,
        fertilizerIntervalDays: _fertilizerEnabled ? _fertilizerInterval : 7,
        lastFertilized: _fertilizerEnabled ? _lastFertilized : null,
        clearLastFertilized: !_fertilizerEnabled,
        // Jika URL null (foto dihapus), clearImagePath akan set null
        imagePath: resolvedPhotoUrl,
        clearImagePath: resolvedPhotoUrl == null,
      );
      await store.updatePlant(updated);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }

  // ── Helper: Preview foto yang dipilih / existing ─────────────
  Widget _buildPhotoPreview() {
    // Prioritas: file baru yang baru dipilih > URL foto lama > placeholder
    if (_pickedPhoto != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_pickedPhoto!.path), fit: BoxFit.cover),
          // Tombol ganti foto di pojok kanan bawah
          Positioned(
            right: 8,
            bottom: 8,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      );
    }

    if (_existingPhotoUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _existingPhotoUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
            errorBuilder: (context2, error, stack) => _photoPlaceholder(),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      );
    }

    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.camera_alt_outlined,
          size: 36,
          color: AppColors.textHint,
        ),
        const SizedBox(height: AppSpacing.micro),
        Text(
          'Tambah Foto Tanaman',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'Ketuk untuk pilih dari galeri atau ambil foto',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper: Label

  Widget _buildLabel(
    String text, {
    bool isRequired = false,
    double top = AppSpacing.field,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.item, top: top),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          children: [
            TextSpan(text: text),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger),
              ),
          ],
        ),
      ),
    );
  }

  // Helper: TextField

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      // return null = valid, return String = pesan error; dipanggil oleh
      // formKey.currentState!.validate() saat tombol Simpan ditekan.
      validator:
          validator ??
          (val) => (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null,
      // Hanya hintText — border, fill, padding diambil dari InputDecorationTheme.
      decoration: InputDecoration(hintText: hint),
    );
  }

  // [4] Helper: Stepper + Input Angka
  Widget _buildNumberStepper({
    required int value,
    required ValueChanged<int> onChanged,
    required TextEditingController controller,
  }) {
    return Container(
      height: AppSizes.control,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Tombol minus
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.input),
              bottomLeft: Radius.circular(AppRadius.input),
            ),
            onTap: () {
              if (value > 1) {
                final newVal = value - 1;
                onChanged(newVal);
                controller.text = '$newVal';
              }
            },
            child: Container(
              width: 52,
              height: AppSizes.control,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: const Icon(
                Icons.remove_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),

          // Input angka manual di tengah
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (val) {
                final parsed = int.tryParse(val?.trim() ?? '');
                if (parsed == null || parsed < 1 || parsed > 365) {
                  return 'Masukkan angka 1-365';
                }
                return null;
              },
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed >= 1) {
                  onChanged(parsed);
                }
              },
              onFieldSubmitted: (val) {
                final parsed = int.tryParse(val);
                if (parsed == null || parsed < 1) {
                  controller.text = '$value';
                }
              },
            ),
          ),

          // Tombol plus
          InkWell(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(AppRadius.input),
              bottomRight: Radius.circular(AppRadius.input),
            ),
            onTap: () {
              final newVal = value < 365 ? value + 1 : 365;
              onChanged(newVal);
              controller.text = '$newVal';
            },
            child: Container(
              width: 52,
              height: AppSizes.control,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Date Picker ──────────────────────────────────────

  Widget _buildDatePicker({
    required DateTime? date,
    required String hint,
    required Future<DateTime?> Function() onPick,
    required ValueChanged<DateTime> onChanged,
    required String errorText,
    required bool isRequired,
  }) {
    return FormField<DateTime>(
      initialValue: date,
      validator: (value) => isRequired && value == null ? errorText : null,
      builder: (field) {
        final selectedDate = field.value;
        return GestureDetector(
          onTap: () async {
            final pickedDate = await onPick();
            if (!mounted) return;
            if (pickedDate != null) {
              field.didChange(pickedDate);
              onChanged(pickedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.card),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: field.hasError ? AppColors.danger : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? hint
                      : DateFormat('dd MMM yyyy').format(selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: selectedDate == null
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Tanaman' : 'Tambah Tanaman'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto Tanaman ────────────────────────────────────
              GestureDetector(
                onTap: _showPhotoOptions,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _buildPhotoPreview(),
                ),
              ),

              // ── Nama Tanaman ────────────────────────────────────
              _buildLabel('Nama Tanaman', isRequired: true),
              _buildTextField(
                controller: _nameController,
                hint: 'Contoh: Monstera Deliciosa',
                validator: (value) {
                  final name = value?.trim() ?? '';
                  return name.length < 2
                      ? 'Nama tanaman minimal 2 karakter'
                      : null;
                },
              ),

              // [3] Jenis Tanaman — input teks bebas
              _buildLabel('Jenis Tanaman', isRequired: true),
              _buildTextField(
                controller: _speciesController,
                hint: 'Contoh: Monstera, Kaktus, Sansevieria...',
                validator: (value) {
                  final species = value?.trim() ?? '';
                  return species.length < 2
                      ? 'Jenis tanaman minimal 2 karakter'
                      : null;
                },
              ),

              // ── Interval Siram — [4] stepper + input angka ──────
              _buildLabel('Interval Siram (hari)', isRequired: true),
              _buildNumberStepper(
                value: _waterInterval,
                onChanged: (val) => setState(() => _waterInterval = val),
                controller: _waterIntervalController,
              ),

              // ── Terakhir Disiram ────────────────────────────────
              _buildLabel('Terakhir Disiram', isRequired: true),
              _buildDatePicker(
                date: _lastWatered,
                hint: 'Pilih tanggal',
                errorText: 'Pilih tanggal terakhir disiram',
                isRequired: true,
                onPick: () => showDatePicker(
                  context: context,
                  initialDate: _lastWatered ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                ),
                onChanged: (date) => setState(() => _lastWatered = date),
              ),

              // [2] Pengaturan Pupuk — muncul saat toggle ON
              const SizedBox(height: AppSpacing.section),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header toggle
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.card),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.item),
                          Expanded(
                            child: Text(
                              'Aktifkan Pupuk',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: _fertilizerEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _fertilizerEnabled = val;
                                // Tanggal tetap dipilih pengguna saat pupuk aktif.
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // [2] Konten pupuk tampil saat aktif
                    if (_fertilizerEnabled) ...[
                      const Divider(height: 1, color: AppColors.border),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.card),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Interval Pupuk — [4] stepper + input angka
                            _buildLabel('Interval Pupuk (hari)', top: 0),
                            _buildNumberStepper(
                              value: _fertilizerInterval,
                              onChanged: (val) =>
                                  setState(() => _fertilizerInterval = val),
                              controller: _fertilizerIntervalController,
                            ),

                            // Terakhir Dipupuk
                            _buildLabel('Terakhir Dipupuk'),
                            _buildDatePicker(
                              date: _lastFertilized,
                              hint: 'Pilih tanggal',
                              errorText: 'Pilih tanggal terakhir dipupuk',
                              isRequired: _fertilizerEnabled,
                              onPick: () => showDatePicker(
                                context: context,
                                initialDate: _lastFertilized ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              ),
                              onChanged: (date) =>
                                  setState(() => _lastFertilized = date),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Tombol Simpan ────────────────────────────────────
              const SizedBox(height: AppSpacing.section),
              // minimumSize sudah diatur di ElevatedButtonTheme (main.dart)
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.6,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Simpan'),
              ),
              const SizedBox(height: AppSpacing.section),
            ],
          ),
        ),
      ),
    );
  }
}
