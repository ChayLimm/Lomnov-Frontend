import 'package:app/data/implementations/building/building_implementation.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
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
      } else {
        // Create mode
        final created = await _repository.createBuilding(
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
    // Upload the bytes to the backend and store the returned URL
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      await _uploadToServer(file.bytes!, file.name);
    }
  }

  Future<void> _uploadToServer(Uint8List bytes, String filename) async {
    setState(() => _uploading = true);
    try {
      final uri = Endpoints.uri(Endpoints.buildingPicturesUpload);
      final req = http.MultipartRequest('POST', uri);
      // Attach auth header if present and common headers
      final token = await _auth.getToken();
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.headers['Accept'] = 'application/json';
      req.headers['ngrok-skip-browser-warning'] = 'true';

      // Field name commonly used by backends: "image"
      req.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
      ));

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final url = _extractUrl(resp.body);
        if (url != null && url.isNotEmpty) {
          widget.controller.text = url;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded')),
            );
          }
        } else {
          throw Exception('Upload succeeded but no URL returned');
        }
      } else {
        throw Exception('Upload failed (${resp.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
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
