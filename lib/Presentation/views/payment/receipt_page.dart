import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/views/payment/pdf_viewer.dart';
import 'package:app/Presentation/views/payment/receipt_webview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';

class ReceiptPage extends StatelessWidget {

  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentViewModel>(builder: (context,paymentProvider,child){
      return paymentProvider.receiptUrl != null?
      Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment Receipt",
          style: LomTextStyles.headline2(),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success icon and message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Payment Successful!",
                    style: LomTextStyles.headline2().copyWith(
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your payment has been processed successfully",
                    style: LomTextStyles.bodyText(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Receipt URL section
            Text(
              "Receipt:",
              style: LomTextStyles.captionText().copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            
            GestureDetector(
              onTap: () => _launchReceiptUrl(context, paymentProvider.receiptUrl!),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "View Receipt",
                            style: LomTextStyles.bodyText().copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            paymentProvider.receiptUrl!,
                            style: LomTextStyles.captionText().copyWith(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Instructions:",
                    style: LomTextStyles.bodyText().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInstruction("1. Tap on 'View Receipt' above"),
                  _buildInstruction("2. The receipt will open in your browser"),
                  _buildInstruction("3. Download or print the receipt for your records"),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _launchReceiptUrl(context, paymentProvider.receiptUrl!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Open Receipt Now",
                  style: LomTextStyles.bodyText().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Back to Payment",
                  style: LomTextStyles.bodyText().copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ) : Container(
      child: Center(
        child: Text("Null"),
      ),
    );
  
    });
  
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: LomTextStyles.bodyText(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchReceiptUrl(BuildContext context, String url) async {
    try {
      Get.to(()=>PDFViewerPage(pdfUrl: url,));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error opening receipt: $e",
            style: LomTextStyles.bodyText().copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}