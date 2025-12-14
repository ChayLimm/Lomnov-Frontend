import 'package:flutter/material.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class BuildingCard extends StatelessWidget {
  final BuildingModel building;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const BuildingCard({super.key, required this.building, this.onTap, this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final b = building;
    final hasImage = b.imageUrl.isNotEmpty;
    final available = b.rooms.where((r) => r.status.toLowerCase() == 'available').length;
    final occupied = b.rooms.where((r) => r.status.toLowerCase() == 'occupied').length;
    final theme = Theme.of(context);
    return Material(

      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return theme.colorScheme.primary.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered)) {
            return theme.colorScheme.primary.withValues(alpha: 0.06);
          }
          return null;
        }),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          color: const Color(0xFFF8F8F8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 135,
                  height: 135,
                  child: hasImage
                      ? _AuthImage(url: b.imageUrl)
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            b.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'More',
                          // Keep the menu just next to the 3-dot
                          offset: const Offset(-30, 6),
                          elevation: 6,
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          constraints: const BoxConstraints.tightFor(width: 160),
                          onSelected: (value) {
                            if (value == 'delete' && onDelete != null) {
                              onDelete!();
                            } else if (value == 'edit' && onEdit != null) {
                              onEdit!();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'edit',
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text('Edit', style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              height: 40,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Text('Delete', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            b.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.apartment, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${b.floor} floors, ${b.unit} units',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _Pill(
                          label: '$available available room',
                          outlined: true,
                          color: AppColors.primaryColor,
                        ),
                        _Pill(
                          label: '$occupied occupied',
                          outlined: false,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Builder(
        builder: (context) => Container(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          child: const Center(child: Icon(Icons.image_not_supported_outlined)),
        ),
      );
}

class _AuthImage extends StatelessWidget {
  final String url;
  const _AuthImage({required this.url});

  @override
  Widget build(BuildContext context) {
    // Try render directly; if it fails due to auth, fetch with headers
    return FutureBuilder<Uint8List?>(
      future: _fetchBytes(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: Theme.of(context).dividerColor.withValues(alpha: 0.15));
        }
        if (snapshot.hasError) {
          return _localPlaceholder(context);
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          // Fallback to network widget (public images)
          return Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (ctx, obj, stack) => _localPlaceholder(ctx),
          );
        }
        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }

  Future<Uint8List?> _fetchBytes(String u) async {
    try {
      final auth = AuthService();
      final token = await auth.getToken();
      final headers = <String, String>{
        'Accept': 'image/*,application/octet-stream,application/json',
        'ngrok-skip-browser-warning': 'true',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final resp = await http.get(Uri.parse(u), headers: headers);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return resp.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  Widget _localPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label; final bool outlined; final Color color;
  const _Pill({required this.label, required this.outlined, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.transparent : color;
    final fg = outlined ? color : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: outlined ? Border.all(color: color, width: 1) : null,
      ),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
