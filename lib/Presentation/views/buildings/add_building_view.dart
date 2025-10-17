import 'package:app/domain/services/building_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class AddBuildingView extends StatefulWidget {
  final int? initialLandlordId;
  // When provided, the view acts as an edit form and will update this building
  // instead of creating a new one.
  final int? editingBuildingId;
  final String? editingName;
  final String? editingAddress;
  final String? editingImageUrl;
  final int? editingFloor;
  final int? editingUnit;

  const AddBuildingView({
    super.key,
    this.initialLandlordId,
    this.editingBuildingId,
    this.editingName,
    this.editingAddress,
    this.editingImageUrl,
    this.editingFloor,
    this.editingUnit,
  });

  @override
  State<AddBuildingView> createState() => _AddBuildingViewState();
}

class _AddBuildingViewState extends State<AddBuildingView> {
  final _formKey = GlobalKey<FormState>();
  final _landlordIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _floorCtrl = TextEditingController(text: '4');
  final _unitCtrl = TextEditingController(text: '20');
  final _service = BuildingService();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill from navigation argument if provided
    if (widget.initialLandlordId != null) {
      _landlordIdCtrl.text = widget.initialLandlordId.toString();
    }
    // If editing, prefill fields from provided values
    if (widget.editingBuildingId != null) {
      if (widget.editingName != null) _nameCtrl.text = widget.editingName!;
      if (widget.editingAddress != null) _addressCtrl.text = widget.editingAddress!;
      if (widget.editingImageUrl != null) _imageUrlCtrl.text = widget.editingImageUrl!;
      if (widget.editingFloor != null) _floorCtrl.text = widget.editingFloor!.toString();
      if (widget.editingUnit != null) _unitCtrl.text = widget.editingUnit!.toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prefill landlord id from current user if available
    final uid = context.read<AuthViewModel>().user?.id;
    if (uid != null && _landlordIdCtrl.text.isEmpty) {
      _landlordIdCtrl.text = uid.toString();
    }
  }

  @override
  void dispose() {
    _landlordIdCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _imageUrlCtrl.dispose();
    _floorCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final floor = int.parse(_floorCtrl.text.trim());
      final unit = int.parse(_unitCtrl.text.trim());
      // Prefer typed landlord id; fallback to logged-in user id
      int? landlordId;
      final landlordText = _landlordIdCtrl.text.trim();
      if (landlordText.isNotEmpty) {
        landlordId = int.tryParse(landlordText);
      }
      landlordId ??= context.read<AuthViewModel>().user?.id;
      if (widget.editingBuildingId != null) {
        // Edit mode - send update
        final updated = await _service.updateBuilding(
          id: widget.editingBuildingId!,
          landlordId: landlordId,
          name: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          imageUrl: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
          floor: floor,
          unit: unit,
        );

        if (!mounted) return;
        Get.back(result: updated);
        Get.snackbar('Success', 'Building updated');
      } else {
        // Create mode
        final created = await _service.createBuilding(
          landlordId: landlordId,
          name: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          imageUrl: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
          floor: floor,
          unit: unit,
        );

        if (!mounted) return;

        // Return created model to previous screen
        Get.back(result: created);
        Get.snackbar('Success', 'Building created');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.editingBuildingId != null ? 'Edit building' : 'Add new building'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Building Info',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Specify exactly as in your building',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Building name',
                                  border: UnderlineInputBorder(),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              // Landlord ID field hidden; value is auto-filled from user
                              TextFormField(
                                controller: _addressCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: UnderlineInputBorder(),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Address is required'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _NumberDropdownField(
                                      controller: _floorCtrl,
                                      label: 'Floor',
                                      min: 1,
                                      max: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _NumberDropdownField(
                                      controller: _unitCtrl,
                                      label: 'unit',
                                      min: 1,
                                      max: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _ImagePickerPlaceholder(
                                controller: _imageUrlCtrl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Save button pinned like the mock
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dropdown-like number selector that writes the selected value to the
/// provided TextEditingController. Values range from [min]..[max].
class _NumberDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final int min;
  final int max;
  const _NumberDropdownField({
    required this.controller,
    required this.label,
    required this.min,
    required this.max,
  });

  @override
  State<_NumberDropdownField> createState() => _NumberDropdownFieldState();
}

class _NumberDropdownFieldState extends State<_NumberDropdownField> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = int.tryParse(widget.controller.text) ?? widget.min;
    widget.controller.text = _value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        border: const UnderlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _value,
          menuMaxHeight: 260, // limit popup height so it doesn't fill the screen
          items: List.generate(widget.max - widget.min + 1, (i) => widget.min + i)
              .map((n) => DropdownMenuItem(value: n, child: Text(n.toString())))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _value = v);
            widget.controller.text = v.toString();
          },
        ),
      ),
    );
  }
}

/// A lightweight image picker placeholder to match the mock: shows a dotted box
/// with an icon and hint. For now it binds to a text controller for image URL.
class _ImagePickerPlaceholder extends StatefulWidget {
  final TextEditingController controller;
  const _ImagePickerPlaceholder({required this.controller});

  @override
  State<_ImagePickerPlaceholder> createState() => _ImagePickerPlaceholderState();
}

class _ImagePickerPlaceholderState extends State<_ImagePickerPlaceholder> {
  Uint8List? _previewBytes;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    setState(() {
      _previewBytes = file.bytes;
      _fileName = file.name;
    });
    // For now, store file name in controller. If your backend expects upload,
    // you would instead upload the bytes and set the returned URL here.
    widget.controller.text = _fileName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickFile,
            child: Center(
              child: _previewBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, color: Colors.grey.shade600),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to upload image',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _previewBytes!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        if (_fileName != null && _fileName!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _fileName!,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ]
      ],
    );
  }
}
