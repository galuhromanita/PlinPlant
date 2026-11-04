import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/plant_model.dart';
import '../stores/plant_store.dart';
import '../widgets/app_widgets.dart';

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

  // ── Simpan ──────────────────────────────────────────────────

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
      await store.addPlant(newPlant);

      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    } else {
      final updated = widget.plantToEdit!.copyWith(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        wateringIntervalDays: _waterInterval,
        lastWatered: _lastWatered!,
        fertilizerEnabled: _fertilizerEnabled,
        fertilizerIntervalDays: _fertilizerEnabled ? _fertilizerInterval : 7,
        lastFertilized: _fertilizerEnabled ? _lastFertilized : null,
        clearLastFertilized: !_fertilizerEnabled,
      );
      await store.updatePlant(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    }
  }

  // ── Helper: Label ────────────────────────────────────────────

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

  // ── Helper: TextField ────────────────────────────────────────

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
              // ── Foto Tanaman Placeholder ────────────────────────
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur foto tanaman akan segera hadir!'),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
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
                        'Pilih dari galeri atau ambil foto',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
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
