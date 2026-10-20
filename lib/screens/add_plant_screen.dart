import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/plant_model.dart';
import '../providers/plant_store.dart';
import '../widgets/app_widgets.dart';

// ============================================================
// ADD / EDIT PLANT SCREEN — Screen #5
// [2] Pupuk muncul saat toggle aktif
// [3] Jenis tanaman: input bebas
// [4] Interval: stepper + input angka
// ============================================================

class AddPlantScreen extends StatefulWidget {
  final PlantModel? plantToEdit;

  const AddPlantScreen({super.key, this.plantToEdit});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // [3] Jenis tanaman input bebas
  final _speciesController = TextEditingController();
  int _waterInterval = 3;
  // [4] Controller angka manual
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
    if (_lastWatered == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi tanggal terakhir disiram!')),
      );
      return;
    }
    if (_fertilizerEnabled && _lastFertilized == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap isi tanggal terakhir dipupuk!')),
      );
      return;
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
        fertilizerIntervalDays:
            _fertilizerEnabled ? _fertilizerInterval : 7,
        lastFertilized: _fertilizerEnabled ? _lastFertilized : null,
      );
      await store.addPlant(newPlant);

      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.pop(context);
      showSuccessPopup(
        context,
        title: 'Berhasil Menambahkan Tanaman!',
        message:
            'Tanaman ${_nameController.text.trim()} telah ditambahkan.',
      );
    } else {
      final updated = widget.plantToEdit!.copyWith(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        wateringIntervalDays: _waterInterval,
        lastWatered: _lastWatered!,
        fertilizerEnabled: _fertilizerEnabled,
        fertilizerIntervalDays:
            _fertilizerEnabled ? _fertilizerInterval : 7,
        lastFertilized: _fertilizerEnabled ? _lastFertilized : null,
      );
      await store.updatePlant(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.pop(context);
      showSuccessPopup(
        context,
        title: 'Berhasil Mengedit Tanaman!',
        message:
            'Data tanaman ${_nameController.text.trim()} telah diperbarui.',
      );
    }
  }

  // ── Helper: Label ────────────────────────────────────────────

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
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
      validator: validator ??
          (val) =>
              (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // [4] Helper: Stepper + Input Angka
  Widget _buildNumberStepper({
    required int value,
    required ValueChanged<int> onChanged,
    required TextEditingController controller,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Tombol minus
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
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
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border:
                    Border(right: BorderSide(color: AppColors.border)),
              ),
              child: const Icon(Icons.remove_rounded,
                  color: AppColors.primary, size: 22),
            ),
          ),

          // Input angka manual di tengah
          Expanded(
            child: TextField(
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
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed >= 1) {
                  onChanged(parsed);
                }
              },
              onSubmitted: (val) {
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
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            onTap: () {
              final newVal = value + 1;
              onChanged(newVal);
              controller.text = '$newVal';
            },
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border:
                    Border(left: BorderSide(color: AppColors.border)),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 22),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null
                  ? hint
                  : DateFormat('dd MMM yyyy').format(date),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: date == null
                    ? AppColors.textHint
                    : AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.calendar_today_rounded,
                size: 20, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Tanaman' : 'Tambah Tanaman',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = (constraints.maxWidth * 0.05).clamp(16.0, 24.0);
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: hPad, vertical: 20),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto Tanaman Placeholder ────────────────────────
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Fitur foto tanaman akan segera hadir!'),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 36, color: AppColors.textHint),
                      const SizedBox(height: 8),
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
                            fontSize: 12, color: AppColors.textHint),
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
              ),

              // [3] Jenis Tanaman — input teks bebas
              _buildLabel('Jenis Tanaman', isRequired: true),
              _buildTextField(
                controller: _speciesController,
                hint: 'Contoh: Monstera, Kaktus, Sansevieria...',
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
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _lastWatered ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _lastWatered = d);
                },
              ),

              // [2] Pengaturan Pupuk — muncul saat toggle ON
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header toggle
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                      child: Row(
                        children: [
                          const Icon(Icons.eco_rounded,
                              color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
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
                                // [1] Tidak auto-set tanggal — biarkan null agar
                                // user wajib memilih sendiri (seperti Terakhir Disiram)
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // [2] Konten pupuk tampil saat aktif
                    if (_fertilizerEnabled) ...[
                      const Divider(
                          height: 1, color: AppColors.border),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Interval Pupuk — [4] stepper + input angka
                            _buildLabel('Interval Pupuk (hari)'),
                            _buildNumberStepper(
                              value: _fertilizerInterval,
                              onChanged: (val) => setState(
                                  () => _fertilizerInterval = val),
                              controller: _fertilizerIntervalController,
                            ),

                            // Terakhir Dipupuk
                            _buildLabel('Terakhir Dipupuk'),
                            _buildDatePicker(
                              date: _lastFertilized,
                              hint: 'Pilih tanggal',
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _lastFertilized ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) {
                                  setState(
                                      () => _lastFertilized = d);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Tombol Simpan ────────────────────────────────────
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
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
                      : Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
        },
      ),
    );
  }
}
