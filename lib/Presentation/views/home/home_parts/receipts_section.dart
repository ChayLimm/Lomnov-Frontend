import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/data/services/payments_service.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/domain/models/payment.dart';
import 'package:app/data/dto/paginated_result.dart';

// --- Configurable values (change these to update the receipts UI) ---
const double kReceiptIconContainerSize = 56.0;
const double kReceiptIconSize = 28.0;
const int kReceiptItemCount = 5;
const double kReceiptSeparatorHeight = 16.0;
final Gradient kReceiptIconBackgroundGradient = AppColors.primaryGradient;
final Color kReceiptIconBackgroundColor = AppColors.primaryColor.withValues(alpha: 0.1);

class ReceiptsSection extends StatefulWidget {
  const ReceiptsSection({super.key});

  @override
  State<ReceiptsSection> createState() => _ReceiptsSectionState();
}

class _ReceiptsSectionState extends State<ReceiptsSection> {
  int _tabIndex = 0;
  int _pageIndex = 0;
  int? _landlordId;
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
    setState(() {
      _landlordId = id;
      // fallback to 1 if landlord id is missing (keeps previous dev behavior)
      final lid = _landlordId ?? 1;
      _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: _pageIndex + 1, status: null);
    });
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
                  final lid = _landlordId ?? 1;
                  _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: _pageIndex + 1, status: null);
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending',
                isSelected: _tabIndex == 1,
                onTap: () => setState(() {
                  _tabIndex = 1;
                  _pageIndex = 0;
                  final lid = _landlordId ?? 1;
                  _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: _pageIndex + 1, status: 'pending');
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Paid',
                isSelected: _tabIndex == 2,
                onTap: () => setState(() {
                  _tabIndex = 2;
                  _pageIndex = 0;
                  final lid = _landlordId ?? 1;
                  _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: _pageIndex + 1, status: 'paid');
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<PaginatedResult<Payment>>(
            future: _paymentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                final err = snapshot.error;
                return Text('Error loading receipts: ${err.toString()}');
              }
              final paged = snapshot.data;
              final payments = paged?.items ?? <Payment>[];
              final totalPages = paged?.pagination.lastPage ?? 1;
              if (payments.isEmpty) {
                return const Text('No receipts available');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) => _ReceiptItem.fromPayment(payments[index]),
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
                  final status = _tabIndex == 1 ? 'pending' : _tabIndex == 2 ? 'paid' : null;
                  final lid = _landlordId ?? 1;
                  _paymentsFuture = PaymentsService().fetchLandlordPayments(lid, page: _pageIndex + 1, status: status);
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

  const _ReceiptItem({this.payment});

  factory _ReceiptItem.fromPayment(Payment p) => _ReceiptItem(payment: p);

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final title = p != null ? 'Invoice#${p.id}' : 'Invoice#143241234';
    final roomText = p != null && p.roomId != null ? 'Room${p.roomId}' : 'RoomA002';
    // compute total
    double total = 0.0;
    if (p != null) {
      for (final it in p.items) {
        total += double.tryParse(it.subtotal) ?? 0.0;
      }
    }
    final totalText = '\$ ${total.toStringAsFixed(2)}';

    // normalize status for display and determine badge colors
    final statusRaw = p?.status ?? 'pending';
    final status = statusRaw.toLowerCase();
    Color badgeBg;
    Color badgeTextColor;
    if (status == 'paid') {
      badgeBg = AppColors.successColor.withOpacity(0.12);
      badgeTextColor = AppColors.successColor;
    } else if (status == 'pending' || status == 'unpaid') {
      badgeBg = AppColors.warningColor.withOpacity(0.12);
      badgeTextColor = AppColors.warningColor;
    } else {
      badgeBg = Colors.grey.shade200;
      badgeTextColor = Colors.black87;
    }

    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totalText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusRaw,
                style: TextStyle(color: badgeTextColor, fontSize: 10),
              ),
            ),
          ],
        ),
      ],
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
