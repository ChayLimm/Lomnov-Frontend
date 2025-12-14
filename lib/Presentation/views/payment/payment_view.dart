import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/views/payment/widgets/info_row.dart';
import 'package:app/Presentation/views/payment/widgets/payment_detail.dart';
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
      PaymentViewModel paymentProvider = context.read<PaymentViewModel>();
      paymentProvider.loadData();
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
                body: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaymentDetail(),
                      SizedBox(height: 10),
                      Text(
                        "Services",
                        style: LomTextStyles.captionText().copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...paymentProvider.roomServices.map(
                        (item) => InfoRow(
                          keyData: item.name,
                          value: "${item.unitPrice.toString()} \$",
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (paymentProvider.contract != null) ...[
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
                          value:
                              paymentProvider.contract!.tenant.email ?? "None",
                        ),
                        InfoRow(
                          keyData: "Phone Number",
                          value:
                              paymentProvider.contract!.tenant.phone ?? "None",
                        ),
                        InfoRow(
                          keyData: "Identity ID",
                          value:
                              paymentProvider.contract!.tenant.identifyId ??
                              "None",
                        ),
                      ],
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: AppColors.primaryColor,
                  child: Text("Next",style: LomTextStyles.headline2().copyWith(color: AppColors.backgroundColor,),),
                  onPressed: () {
                    paymentProvider.tester();
                  },
                ),
              );
      },
    );
  }
}
