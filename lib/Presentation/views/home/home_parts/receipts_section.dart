import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/views/home/home_parts/receipt_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:app/data/services/payments_service.dart';
import 'package:app/data/services/tenant_service.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/domain/models/payment.dart';
import 'package:app/data/dto/paginated_result.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/utils/browser_utils.dart';

// --- Configurable values (change these to update the receipts UI) ---
const double kReceiptIconContainerSize = 56.0;
const double kReceiptIconSize = 28.0;
const int kReceiptItemCount = 5;
const double kReceiptSeparatorHeight = 16.0;
final Gradient kReceiptIconBackgroundGradient = AppColors.primaryGradient;
final Color kReceiptIconBackgroundColor = AppColors.primaryColor.withValues(alpha: 0.1);
// fallback example PDF URL when payment doesn't provide one
const String kFallbackReceiptPdfUrl = 'https://mustang-tidy-usefully.ngrok-free.app/storage/invoices/receipt_20_20251222085956.pdf';

class ReceiptsSection extends StatefulWidget {
  const ReceiptsSection({super.key});

  @override
  State<ReceiptsSection> createState() => _ReceiptsSectionState();
}

class _ReceiptsSectionState extends State<ReceiptsSection> {
  int _tabIndex = 0;
  int _pageIndex = 0;
  int? _landlordId;
  int? _lastPage;
  final Map<int, String> _tenantNames = {};
  final Map<int, String> _roomNames = {};
  bool _namesResolved = false;
  // initialize with a safe default so the FutureBuilder can read a Future
  late Future<PaginatedResult<Payment>> _paymentsFuture =
      PaymentsService().fetchLandlordPayments(1, page: 1, status: null);

  @override
  void initState() {
    super.initState();
    _loadLandlordAndPayments();
  }

  Future<void> _loadLandlordAndPayments() async {
    final id = await AuthService().getLandlordId();
    final lid = id ?? 1;
    try {
      // first fetch page 1 to learn total pages, then fetch the last page
      final first = await PaymentsService().fetchLandlordPayments(lid, page: 1, status: null);
      final last = first.pagination.lastPage ?? 1;
      setState(() {
        _landlordId = id;
        _lastPage = last;
        _namesResolved = false;
        // fetch the last page so UI shows newest payments first
        _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: last, status: null);
      });
    } catch (_) {
      setState(() {
        _landlordId = id;
        _namesResolved = false;
        _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: _pageIndex + 1, status: null);
      });
    }
  }

  /// Fetch payments mapping the UI page index (0 = newest page) to the
  /// server page number. If [_lastPage] is known, map: serverPage = _lastPage - uiIndex
  Future<PaginatedResult<Payment>> _fetchPaymentsForUiPage(int uiIndex, {String? status}) async {
    final lid = _landlordId ?? 1;
    final serverPage = (_lastPage != null) ? (_lastPage! - uiIndex) : (uiIndex + 1);
    final resp = await PaymentsService().fetchLandlordPayments(lid, page: serverPage, status: status);
    _lastPage = resp.pagination.lastPage ?? _lastPage;
    return resp;
  }

  Future<void> _resolveNames(List<Payment> payments) async {
    if (_landlordId == null) return;
    final missingTenantIds = <int>{};
    final missingRoomIds = <int>{};
    for (final p in payments) {
      if (p.tenantId != null && !_tenantNames.containsKey(p.tenantId)) missingTenantIds.add(p.tenantId);
      if (p.roomId != null && !_roomNames.containsKey(p.roomId)) missingRoomIds.add(p.roomId!);
    }
    if (missingTenantIds.isEmpty && missingRoomIds.isEmpty) return;

    try {
      if (missingTenantIds.isNotEmpty) {
        final tenantPage = await TenantService().fetchTenants(_landlordId ?? 1, page: 1, perPage: 1000);
        for (final t in tenantPage.items) {
          final name = '${t.firstName ?? ''} ${t.lastName ?? ''}'.trim();
          if (name.isNotEmpty) _tenantNames[t.id] = name;
        }
      }

      if (missingRoomIds.isNotEmpty) {
        try {
          // Fetch rooms in bulk to avoid N requests for N missing room ids.
          final roomsResp = await RoomFetchService().fetchRooms(page: 1, perPage: 1000);
          for (final r in roomsResp.items) {
            if (missingRoomIds.contains(r.id) && r.roomNumber.isNotEmpty) {
              _roomNames[r.id] = r.roomNumber;
            }
          }
        } catch (_) {
          // ignore fetch errors
        }
      }

      if (mounted) setState(() {});
    } catch (_) {
      // silently ignore resolution errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottomInset + 24),
      padding: const EdgeInsets.all(16),
      
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receipts',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: _tabIndex == 0,
                onTap: () => setState(() {
                  _tabIndex = 0;
                  _pageIndex = 0;
                    _namesResolved = false;
                    _paymentsFuture = _fetchPaymentsForUiPage(_pageIndex, status: null);
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending',
                isSelected: _tabIndex == 1,
                onTap: () => setState(() {
                  _tabIndex = 1;
                  _pageIndex = 0;
                    _namesResolved = false;
                    _paymentsFuture = _fetchPaymentsForUiPage(_pageIndex, status: 'pending');
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Paid',
                isSelected: _tabIndex == 2,
                onTap: () => setState(() {
                  _tabIndex = 2;
                  _pageIndex = 0;
                    _namesResolved = false;
                    // treat 'paid', 'complete' and 'completed' as paid
                    _paymentsFuture = _fetchPaymentsForUiPage(_pageIndex, status: 'paid,complete,completed');
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<PaginatedResult<Payment>>(
            future: _paymentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ReceiptShimmer();
              }
              if (snapshot.hasError) {
                final err = snapshot.error;
                return Text('Error loading receipts: ${err.toString()}');
              }
              final paged = snapshot.data;
              // show latest payments first (reverse the returned page items)
              final payments = (paged?.items ?? <Payment>[]).reversed.toList();
              if (payments.isEmpty) {
                return const Text('No receipts available');
              }
              // Resolve missing tenant/room names once for this payments page
              if (!_namesResolved) {
                _namesResolved = true;
                _resolveNames(payments);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  final display = (payment.roomName != null && payment.roomName!.isNotEmpty)
                      ? payment.roomName
                      : (payment.tenantName != null && payment.tenantName!.isNotEmpty)
                          ? payment.tenantName
                          : _roomNames[payment.roomId] ?? _tenantNames[payment.tenantId];
                  return _ReceiptItem.fromPayment(payments[index], displayName: display);
                },
                separatorBuilder: (context, index) => const SizedBox(height: kReceiptSeparatorHeight),
              );
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<PaginatedResult<Payment>>(
            future: _paymentsFuture,
            builder: (context, snap) {
              final totalPages = snap.data?.pagination.lastPage ?? 1;
                  return _Pagination(
                currentPage: _pageIndex,
                totalPages: totalPages,
                onPageChanged: (i) => setState(() {
                  _pageIndex = i;
                  // preserve current tab filter when changing page
                  // include 'complete' and 'completed' alongside 'paid' when showing paid page
                      final status = _tabIndex == 1 ? 'pending' : _tabIndex == 2 ? 'paid,complete,completed' : null;
                      _namesResolved = false;
                      _paymentsFuture = _fetchPaymentsForUiPage(_pageIndex, status: status);
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              )
            : BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReceiptItem extends StatelessWidget {
  final Payment? payment;
  final String? displayName;
  const _ReceiptItem({this.payment, this.displayName});

  factory _ReceiptItem.fromPayment(Payment p, {String? displayName}) => _ReceiptItem(payment: p, displayName: displayName);

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final title = p != null ? 'Invoice#${p.id}' : 'Invoice#143241234';
    String roomText;
    if (displayName != null && displayName!.isNotEmpty) {
      roomText = displayName!;
    } else if (p == null) {
      roomText = 'Room';
    } else if (p.roomName != null && p.roomName!.isNotEmpty) {
      roomText = p.roomName!;
    } else if (p.tenantName != null && p.tenantName!.isNotEmpty) {
      roomText = p.tenantName!;
    } else if (p.roomId != null) {
      roomText = 'Room${p.roomId}';
    } else {
      roomText = 'Room';
    }
    // Amount removed — backend does not provide reliable totals. Only show status badge.

    // Determine whether this payment should be shown as paid/green.
    final statusRaw = p?.status ?? 'pending';
    final status = statusRaw.toLowerCase();
    // treat 'complete' and 'completed' as paid for visual purposes
    final bool isPaidVisual = status == 'paid' || status == 'complete' || status == 'completed';
    Color badgeBg;
    Color badgeTextColor;
    final String badgeText = isPaidVisual ? 'Paid' : statusRaw;
    if (isPaidVisual) {
      // ignore: deprecated_member_use
      badgeBg = AppColors.successColor.withOpacity(0.12);
      badgeTextColor = AppColors.successColor;
    } else if (status == 'pending' || status == 'unpaid') {
      // ignore: deprecated_member_use
      badgeBg = AppColors.warningColor.withOpacity(0.12);
      badgeTextColor = AppColors.warningColor;
    } else {
      badgeBg = Colors.grey.shade200;
      badgeTextColor = Colors.black87;
    }

    return GestureDetector(
      onTap: () => _openPdf(context),
      child: Row(
        children: [
          Container(
            width: kReceiptIconContainerSize,
            height: kReceiptIconContainerSize,
            decoration: BoxDecoration(
              color: kReceiptIconBackgroundColor,
              // gradient: kReceiptIconBackgroundGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: kReceiptIconSize,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(roomText, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: TextStyle(color: badgeTextColor, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPdf(BuildContext context) {
    final url = (payment?.receiptUrl != null && payment!.receiptUrl!.isNotEmpty)
        ? payment!.receiptUrl!
        : kFallbackReceiptPdfUrl;
    final String title = payment != null ? 'Invoice#${payment!.id}' : 'Invoice#143241234';
    if (kIsWeb) {
      // On web, avoid CORS issues by opening the PDF in a new tab instead of XHR.
      openUrlInNewTab(url);
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PdfViewerPage(url: url, title: title)));
  }
}

class _PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const _PdfViewerPage({required this.url, required this.title});

  @override
  State<_PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<_PdfViewerPage> {
  bool _loading = true;
  String? _error;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    setState(() {
      _loading = true;
      _error = null;
      _pdfBytes = null;
    });

    try {
      final dio = Dio();
      final token = await AuthService().getToken();
      final headers = <String, String>{'Accept': 'application/pdf'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final resp = await dio.get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes, followRedirects: true, headers: headers),
      );

      if (resp.statusCode != 200) {
        setState(() {
          _error = 'HTTP ${resp.statusCode}';
          _loading = false;
        });
        return;
      }

      final bytes = Uint8List.fromList(resp.data ?? <int>[]);
      if (bytes.length < 4 || bytes[0] != 0x25 || bytes[1] != 0x50 || bytes[2] != 0x44 || bytes[3] != 0x46) {
        setState(() {
          _error = 'Downloaded file is not a valid PDF (bad signature)';
          _loading = false;
        });
        return;
      }

      setState(() {
        _pdfBytes = bytes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(child: Text('Failed to load PDF: $_error'))
          else if (_pdfBytes != null)
            SfPdfViewer.memory(_pdfBytes!)
          else
            const SizedBox.shrink(),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ..._buildPageButtons(),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios, size: 16),
      ],
    );
  }

  List<Widget> _buildPageButtons() {
    // totalPages and currentPage are 0-based here
    final List<Widget> widgets = [];
    final int tp = totalPages;
    if (tp <= 0) return widgets;

    // decide window of pages to show (1-based pages), show up to 5 pages
    final int maxButtons = 5;
    int current1 = currentPage + 1;
    int start = current1 - 2;
    if (start < 1) start = 1;
    int end = start + maxButtons - 1;
    if (end > tp) {
      end = tp;
      start = (end - maxButtons + 1).clamp(1, tp);
    }

    for (int p = start; p <= end; p++) {
      widgets.add(_PageButton(
        label: p.toString(),
        isSelected: (currentPage + 1) == p,
        onTap: () => onPageChanged(p - 1),
      ));
    }

    return widgets;
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              )
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
