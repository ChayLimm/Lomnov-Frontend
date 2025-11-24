import 'package:app/presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';

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
                onTap: () => setState(() => _tabIndex = 0),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending',
                isSelected: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Paid',
                isSelected: _tabIndex == 2,
                onTap: () => setState(() => _tabIndex = 2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kReceiptItemCount,
            itemBuilder: (context, index) => _ReceiptItem(),
            separatorBuilder: (context, index) => const SizedBox(height: kReceiptSeparatorHeight),
          ),
          const SizedBox(height: 20),
          _Pagination(
            currentPage: _pageIndex,
            totalPages: 5,
            onPageChanged: (i) => setState(() => _pageIndex = i),
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
  const _ReceiptItem();

  @override
  Widget build(BuildContext context) {
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice#143241234',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('RoomA002', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '\$ 123.4',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withValues(alpha: 1.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(color: AppColors.warningColor, fontSize: 10),
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
        _PageButton(
          label: '1',
          isSelected: currentPage == 0,
          onTap: () => onPageChanged(0),
        ),
        _PageButton(
          label: '2',
          isSelected: currentPage == 1,
          onTap: () => onPageChanged(1),
        ),
        _PageButton(
          label: '3',
          isSelected: currentPage == 2,
          onTap: () => onPageChanged(2),
        ),
        _PageButton(
          label: '4',
          isSelected: currentPage == 3,
          onTap: () => onPageChanged(3),
        ),
        _PageButton(
          label: '5',
          isSelected: currentPage == 4,
          onTap: () => onPageChanged(4),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios, size: 16),
      ],
    );
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
