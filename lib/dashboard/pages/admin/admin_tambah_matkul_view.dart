import 'package:bestpractice/dashboard/pages/widgets/admin/card_container.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_buttons.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/custom_text_field.dart';
import 'package:bestpractice/dashboard/pages/widgets/admin/sub_page_header.dart';
import 'package:flutter/material.dart';

class AdminTambahMatkulView extends StatefulWidget {
  const AdminTambahMatkulView({
    super.key,
    required this.onBack,
    required this.onSaveCourse,
  });

  final VoidCallback onBack;
  final Function({
    required String name,
    required String code,
    required int sks,
    required int semester,
    String? department,
    String? description,
  }) onSaveCourse;

  @override
  State<AdminTambahMatkulView> createState() => _AdminTambahMatkulViewState();
}

class _AdminTambahMatkulViewState extends State<AdminTambahMatkulView> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  final _semesterController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  String? _selectedDepartment;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _creditsController.dispose();
    _semesterController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final inputBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final charCount = _descriptionController.text.length;

    return Column(
      children: [
        // App bar header with back arrow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SubPageHeader(
            title: 'Tambah Mata Kuliah',
            onBack: widget.onBack,
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'Masukkan rincian mata kuliah baru di bawah ini untuk menambahkannya ke kurikulum.',
                style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Form card container
              CardContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Nama Mata Kuliah
                      CustomFormField(
                        label: 'Nama Mata Kuliah',
                        hintText: 'Contoh: Pengantar Ilmu Kompu...',
                        controller: _courseNameController,
                        prefixIcon: Icons.menu_book_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama mata kuliah wajib diisi' : null,
                      ),
                      const SizedBox(height: 18),

                      // Field 2: Kode Matkul
                      CustomFormField(
                        label: 'Kode Matkul',
                        hintText: 'Contoh: CS101',
                        controller: _courseCodeController,
                        prefixIcon: Icons.tag_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Kode mata kuliah wajib diisi' : null,
                      ),
                      const SizedBox(height: 18),

                      // Field 3: Pilih Departemen
                      Text(
                        'Pilih Departemen',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        onChanged: (val) => setState(() => _selectedDepartment = val),
                        style: TextStyle(color: titleColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Pilih Departemen...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: inputBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: inputBorderColor),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Informatika', child: Text('Teknik Informatika')),
                          DropdownMenuItem(value: 'Sistem Informasi', child: Text('Sistem Informasi')),
                          DropdownMenuItem(value: 'Teknik Komputer', child: Text('Teknik Komputer')),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // SKS & Semester row
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              label: 'Jumlah SKS',
                              hintText: '3',
                              controller: _creditsController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomFormField(
                              label: 'Semester',
                              hintText: '1',
                              controller: _semesterController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Field 4: Deskripsi
                      CustomFormField(
                        label: 'Deskripsi',
                        hintText: 'Tuliskan deskripsi singkat mengenai mata kuliah ini...',
                        controller: _descriptionController,
                        maxLines: 4,
                        maxLength: 500,
                        counterText: '$charCount/500 karakter',
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Bottom Action Buttons Row: [Batal] [Simpan]
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Batal',
                      onPressed: widget.onBack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Simpan',
                      onPressed: _handleSave,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _courseNameController.text.trim();
    final code = _courseCodeController.text.trim();
    final sks = int.tryParse(_creditsController.text) ?? 3;
    final semester = int.tryParse(_semesterController.text) ?? 1;

    widget.onSaveCourse(
      name: name,
      code: code,
      sks: sks,
      semester: semester,
      department: _selectedDepartment,
      description: _descriptionController.text.trim(),
    );
  }
}
