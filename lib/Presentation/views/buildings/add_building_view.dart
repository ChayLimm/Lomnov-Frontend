import 'package:app/data/implementations/building/building_implementation.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'package:app/data/dto/building_dto.dart';

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
  final _floorCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController(text: '1');
  final _repository = BuildingRepositoryImpl();

  bool _submitting = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageFileName;

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
        // Edit mode - send update; if image selected, PATCH multipart
        if (_selectedImageBytes != null && _selectedImageBytes!.isNotEmpty) {
          final uri = Endpoints.uri(Endpoints.buildingById(widget.editingBuildingId!));
          // Some backends don't accept PATCH with multipart; use POST + _method=PATCH
          final req = http.MultipartRequest('POST', uri);
                    // Method spoofing for PATCH semantics
                    req.fields['_method'] = 'PATCH';
          final token = await AuthService().getToken();
          if (token != null && token.isNotEmpty) {
            req.headers['Authorization'] = 'Bearer $token';
          }
          req.headers['Accept'] = 'application/json';
          req.headers['ngrok-skip-browser-warning'] = 'true';

          if (landlordId != null) req.fields['landlord_id'] = landlordId.toString();
          req.fields['name'] = _nameCtrl.text.trim();
          req.fields['address'] = _addressCtrl.text.trim();
          req.fields['floor'] = floor.toString();
          req.fields['unit'] = unit.toString();
          if (_imageUrlCtrl.text.trim().isNotEmpty) {
            req.fields['imageUrl'] = _imageUrlCtrl.text.trim();
          }

          req.files.add(http.MultipartFile.fromBytes(
            'image',
            _selectedImageBytes!,
            filename: _selectedImageFileName ?? 'image.jpg',
          ));

          final streamed = await req.send();
          final resp = await http.Response.fromStream(streamed);
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            final dynamic decoded = resp.body.isEmpty ? null : jsonDecode(resp.body);
            BuildingDto dto;
            if (decoded is Map<String, dynamic>) {
              dto = BuildingDto.fromJson(decoded);
            } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
              dto = BuildingDto.fromJson(decoded.first as Map<String, dynamic>);
            } else {
              throw Exception('Unexpected update response format');
            }
            if (!mounted) return;
            Get.back(result: dto.toDomain());
            Get.snackbar('Success', 'Building updated');
          } else {
            throw Exception('Update failed (${resp.statusCode})');
          }
        } else {
          // No image: use repository JSON update
          final updated = await _repository.updateBuilding(
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
        }
      } else {
        // Create mode
        // If an image was selected, send as multipart together with fields
        if (_selectedImageBytes != null && _selectedImageBytes!.isNotEmpty) {
          final uri = Endpoints.uri(Endpoints.buildings);
          final req = http.MultipartRequest('POST', uri);
          final token = await AuthService().getToken();
          if (token != null && token.isNotEmpty) {
            req.headers['Authorization'] = 'Bearer $token';
          }
          req.headers['Accept'] = 'application/json';
          req.headers['ngrok-skip-browser-warning'] = 'true';

          if (landlordId != null) req.fields['landlord_id'] = landlordId.toString();
          req.fields['name'] = _nameCtrl.text.trim();
          req.fields['address'] = _addressCtrl.text.trim();
          req.fields['floor'] = floor.toString();
          req.fields['unit'] = unit.toString();
          if (_imageUrlCtrl.text.trim().isNotEmpty) {
            req.fields['imageUrl'] = _imageUrlCtrl.text.trim();
          }

          req.files.add(http.MultipartFile.fromBytes(
            'image',
            _selectedImageBytes!,
            filename: _selectedImageFileName ?? 'image.jpg',
          ));

          final streamed = await req.send();
          final resp = await http.Response.fromStream(streamed);
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            final dynamic decoded = resp.body.isEmpty ? null : jsonDecode(resp.body);
            BuildingDto dto;
            if (decoded is Map<String, dynamic>) {
              dto = BuildingDto.fromJson(decoded);
            } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
              dto = BuildingDto.fromJson(decoded.first as Map<String, dynamic>);
            } else {
              throw Exception('Unexpected create response format');
            }
            if (!mounted) return;
            Get.back(result: dto.toDomain());
            Get.snackbar('Success', 'Building created');
          } else {
            throw Exception('Create failed (${resp.statusCode})');
          }
        } else {
          // No image selected: use repository
          final created = await _repository.createBuilding(
            landlordId: landlordId,
            name: _nameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            imageUrl: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
            floor: floor,
            unit: unit,
          );

          if (!mounted) return;
          Get.back(result: created);
          Get.snackbar('Success', 'Building created');
        }
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

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
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
                        color: Colors.white,
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
                                'Provide the building details below',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: _fieldDecoration('Building name', icon: Icons.home_work_outlined),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              // Landlord ID field hidden; value is auto-filled from user
                              TextFormField(
                                controller: _addressCtrl,
                                decoration: _fieldDecoration('Address', icon: Icons.location_on_outlined),
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
                                      icon: Icons.layers_outlined,
                                      min: 1,
                                      max: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _NumberDropdownField(
                                      controller: _unitCtrl,
                                      label: 'Unit',
                                      icon: Icons.apartment,
                                      min: 1,
                                      max: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _ImagePickerPlaceholder(
                                controller: _imageUrlCtrl,
                                onFileSelected: (bytes, filename) {
                                  _selectedImageBytes = bytes;
                                  _selectedImageFileName = filename;
                                },
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
                    child: GradientButton(
                      label: _submitting
                          ? 'Please wait…'
                          : (widget.editingBuildingId != null ? 'Update' : 'Save'),
                      loading: _submitting,
                      onPressed: _submitting ? null : _submit,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      borderRadius: 12,
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
  final IconData? icon;
  final int min;
  final int max;
  const _NumberDropdownField({
    required this.controller,
    required this.label,
    this.icon,
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
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _openPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppColors.primaryColor) : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _value.toString(),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker() async {
    final values = List.generate(widget.max - widget.min + 1, (i) => widget.min + i);
    int initialIndex = values.indexOf(_value);
    if (initialIndex < 0) initialIndex = 0;
    int tempIndex = initialIndex;

    final pickedIndex = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(tempIndex),
                        child: Text('Done', style: TextStyle(color: AppColors.primaryColor)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: initialIndex),
                    itemExtent: 40,
                    onSelectedItemChanged: (i) => tempIndex = i,
                    children: values
                        .map((n) => Center(child: Text(n.toString())))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedIndex != null && pickedIndex >= 0 && pickedIndex < values.length) {
      final newVal = values[pickedIndex];
      setState(() => _value = newVal);
      widget.controller.text = newVal.toString();
    }
  }
}

/// A lightweight image picker placeholder to match the mock: shows a dotted box
/// with an icon and hint. For now it binds to a text controller for image URL.
class _ImagePickerPlaceholder extends StatefulWidget {
  final TextEditingController controller;
  final void Function(Uint8List bytes, String filename)? onFileSelected;
  const _ImagePickerPlaceholder({required this.controller, this.onFileSelected});

  @override
  State<_ImagePickerPlaceholder> createState() => _ImagePickerPlaceholderState();
}

class _ImagePickerPlaceholderState extends State<_ImagePickerPlaceholder> {
  Uint8List? _previewBytes;
  String? _fileName;
  bool _uploading = false;

  final _auth = AuthService();

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
    // Defer upload; let parent submit together with building data
    if (file.bytes != null && file.bytes!.isNotEmpty && widget.onFileSelected != null) {
      widget.onFileSelected!(file.bytes!, file.name);
    }
  }
  

  String? _extractUrl(String body) {
    // Try parse a few common response shapes
    try {
      final dynamic decoded = body.isEmpty ? null : jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final m = decoded;
        String? pick(Map<String, dynamic> x) {
          final candidates = ['url', 'image_url', 'imageUrl', 'path'];
          for (final k in candidates) {
            final v = x[k];
            if (v is String && v.isNotEmpty) return v;
          }
          return null;
        }
        final direct = pick(m);
        if (direct != null) return direct;
        if (m['data'] is Map<String, dynamic>) {
          final d = m['data'] as Map<String, dynamic>;
          final inner = pick(d);
          if (inner != null) return inner;
        }
      } else if (decoded is String && decoded.startsWith('http')) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickFile,
            child: Stack(
              children: [
                Center(
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
                if (_uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
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
