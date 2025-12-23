// ignore_for_file: use_build_context_synchronously

import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/views/payment/receipt_page.dart';
import 'package:app/Presentation/views/payment/widgets/info_row.dart';
import 'package:app/Presentation/views/payment/widgets/payment_detail.dart';
import 'package:app/data/dto/consumption_dto.dart';
import 'package:app/data/dto/service_dto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool _isProcessingPayment = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Consumer<PaymentViewModel>(
        builder: (context, paymentProvider, child) {
          return Scaffold(
            backgroundColor: AppColors.surfaceColor,
            appBar: AppBar(
              title: const Text('Payment', style: TextStyle(color: Colors.black)),
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            body: paymentProvider.isLoading || _isProcessingPayment
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
            floatingActionButton: _isProcessingPayment
                ? FloatingActionButton(
                    backgroundColor: Colors.grey,
                    onPressed: null,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      "Next",
                      style: LomTextStyles.headline2().copyWith(
                        color: AppColors.backgroundColor,
                      ),
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, paymentProvider);
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, PaymentViewModel paymentProvider) {
    // Calculate the total amount for display
    final double totalAmount = _calculateSubtotal(
      paymentProvider.roomServices,
      (paymentProvider.isLastPayment ? 0 : paymentProvider.selectedRoom?.price),
      paymentProvider,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Transaction",
            style: LomTextStyles.headline2().copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to proceed with this payment?",
                style: LomTextStyles.bodyText(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Details",
                      style: LomTextStyles.captionText().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (paymentProvider.selectedBuilding != null)
                      _buildDetailRow(
                        "Building",
                        paymentProvider.selectedBuilding!.name,
                      ),
                    if (paymentProvider.selectedRoom != null)
                      _buildDetailRow(
                        "Room",
                        paymentProvider.selectedRoom!.roomNumber,
                      ),
                    if (paymentProvider.contract != null)
                      _buildDetailRow(
                        "Tenant",
                        "${paymentProvider.contract!.tenant.firstName} ${paymentProvider.contract!.tenant.lastName}",
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: LomTextStyles.bodyText().copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${totalAmount.toStringAsFixed(2)}",
                            style: LomTextStyles.bodyText().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isProcessingPayment
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: Text(
                "Cancel",
                style: LomTextStyles.bodyText().copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isProcessingPayment
                  ? null
                  : () async {
                      // Set processing state
                      setState(() {
                        _isProcessingPayment = true;
                      });
                      
                      // Close the dialog
                      Navigator.of(context).pop();

                      // Process payment
                      try {
                        final response = await paymentProvider.processPayment();
                        
                        // // Reset processing state
                        // if (mounted) {
                        //   setState(() {
                        //     _isProcessingPayment = false;
                        //   });
                        // }
                        
                        // Extract receipt URL
                        paymentProvider.setReceipt(response['original']['payment']['receipt_url'].toString());
                        // Navigate to receipt page
                        if (mounted) {
                          Get.to(() => ReceiptPage());
                        }
                        
                      } catch (e) {
                        // Reset processing state
                        if (mounted) {
                          setState(() {
                            _isProcessingPayment = false;
                          });
                        }
                        
                        // Show error using GlobalKey to avoid context issues
                        _showErrorSnackBar("Failed to process payment: $e");
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isProcessingPayment
                    ? Colors.grey
                    : AppColors.primaryColor,
              ),
              child: _isProcessingPayment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Confirm",
                      style: LomTextStyles.bodyText().copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  // Helper method to show snackbar using GlobalKey
  void _showErrorSnackBar(String message) {
    // Use WidgetsBinding to ensure we're in a frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: LomTextStyles.bodyText().copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: LomTextStyles.captionText().copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: LomTextStyles.bodyText().copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
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
        const SizedBox(height: 8),
        if (paymentProvider.contract != null) ...[
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
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.person_off,
                  size: 20,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  "No tenant information available",
                  style: LomTextStyles.bodyText().copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConsumptionSection(PaymentViewModel paymentProvider) {
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
        const SizedBox(height: 8),
        if (paymentProvider.latestConsumptions.isNotEmpty) ...[
          Column(
            children: paymentProvider.latestConsumptions
                .map(_buildConsumptionItem)
                .toList(),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.offline_bolt_outlined,
                  size: 20,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  "No consumption data available",
                  style: LomTextStyles.bodyText().copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        const SizedBox(height: 8),
        Column(
          children: [
            if (!paymentProvider.isLastPayment &&
                paymentProvider.selectedRoom != null)
              _buildRoomPrice(paymentProvider),
            if (paymentProvider.roomServices.isNotEmpty) ...[
              ...paymentProvider.roomServices.map(_buildServiceItem),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.cleaning_services_outlined,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "No services available",
                      style: LomTextStyles.bodyText().copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRoomPrice(PaymentViewModel paymentProvider) {
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
            (paymentProvider.isLastPayment
                ? 0
                : paymentProvider.selectedRoom?.price),
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
