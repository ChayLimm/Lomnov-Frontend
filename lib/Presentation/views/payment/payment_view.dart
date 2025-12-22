// ignore_for_file: use_build_context_synchronously

import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/views/payment/widgets/info_row.dart';
import 'package:app/Presentation/views/payment/widgets/payment_detail.dart';
import 'package:app/data/dto/consumption_dto.dart';
import 'package:app/data/dto/service_dto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentViewModel>(
      builder: (context, paymentProvider, child) {
        return paymentProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: AppColors.surfaceColor,
                appBar: AppBar(
                  title: const Text('Payment'),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PaymentDetail(),
                        const SizedBox(height: 10),
                        _buildContent(paymentProvider),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    "Next",
                    style: LomTextStyles.headline2().copyWith(
                      color: AppColors.backgroundColor,
                    ),
                  ),
                  onPressed: () {
                    paymentProvider.tester();
                  },
                ),
              );
      },
    );
  }

  Widget _buildContent(PaymentViewModel paymentProvider) {
    if (paymentProvider.selectedBuilding == null) {
      return _buildEmptyState(
        "Select a building to continue",
        "No building selected",
      );
    }
    
    if (paymentProvider.selectedRoom == null) {
      return _buildEmptyState(
        "Select a room to see payment details",
        "No room selected",
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTenantInfo(paymentProvider),
          const Divider(),
          _buildConsumptionSection(paymentProvider),
          const Divider(),
          _buildServicesSection(paymentProvider),
          const Divider(),
          _buildSubtotal(paymentProvider),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: LomTextStyles.captionText().copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: LomTextStyles.bodyText().copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantInfo(PaymentViewModel paymentProvider) {
    if (paymentProvider.contract == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tenant's info",
          style: LomTextStyles.captionText().copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        InfoRow(
          keyData: "Username",
          value:
              "${paymentProvider.contract!.tenant.firstName} ${paymentProvider.contract!.tenant.lastName}",
        ),
        InfoRow(
          keyData: "Email",
          value: paymentProvider.contract!.tenant.email ?? "None",
        ),
        InfoRow(
          keyData: "Phone Number",
          value: paymentProvider.contract!.tenant.phone ?? "None",
        ),
        InfoRow(
          keyData: "Identity ID",
          value: paymentProvider.contract!.tenant.identifyId ?? "None",
        ),
      ],
    );
  }

  Widget _buildConsumptionSection(PaymentViewModel paymentProvider) {
    if (paymentProvider.latestConsumptions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Consumption",
          style: LomTextStyles.captionText().copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: paymentProvider.latestConsumptions.map(_buildConsumptionItem).toList(),
        ),
      ],
    );
  }

  Widget _buildConsumptionItem(ConsumptionDto item) {
    return Consumer<PaymentViewModel>(
      builder: (context, paymentProvider, child) {
        final isWater = item.type == 'water';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isWater ? 'Water' : 'Electricity',
                    style: LomTextStyles.bodyText().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isWater
                        ? "\$ ${paymentProvider.water_total}"
                        : "\$ ${paymentProvider.electricity_total}",
                    style: LomTextStyles.bodyText().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${isWater ? paymentProvider.water : paymentProvider.electricity} - ${item.endReading} = ${isWater ? paymentProvider.water_qty : paymentProvider.electricity_qty} ${isWater ? 'm³' : 'kWh'}",
                      style: LomTextStyles.bodyText().copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesSection(PaymentViewModel paymentProvider) {
    if (paymentProvider.roomServices.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Services",
          style: LomTextStyles.captionText().copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: [
            if (!paymentProvider.isLastPayment) _buildRoomPrice(paymentProvider),
            ...paymentProvider.roomServices.map(_buildServiceItem),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomPrice(PaymentViewModel paymentProvider) {
    if (paymentProvider.selectedRoom == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text("1x"),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Room",
              style: LomTextStyles.bodyText().copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "\$${paymentProvider.selectedRoom!.price}",
            style: LomTextStyles.bodyText().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceDto item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text("1x"),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: LomTextStyles.bodyText().copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "\$${item.unitPrice}",
            style: LomTextStyles.bodyText().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotal(PaymentViewModel paymentProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Subtotal: \$${_calculateSubtotal(
            paymentProvider.roomServices,
            (paymentProvider.isLastPayment ? 0 : paymentProvider.selectedRoom?.price),
            paymentProvider,
          ).toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  double _calculateSubtotal(
    List<ServiceDto> services,
    double? roomPrice,
    PaymentViewModel paymentProvider,
  ) {
    double total = services.fold(0, (sum, item) => sum + (item.unitPrice ?? 0));
    double roomTotal = roomPrice ?? 0;
    double waterTotal = paymentProvider.water_total;
    double electricityTotal = paymentProvider.electricity_total;

    return total + roomTotal + waterTotal + electricityTotal;
  }
}