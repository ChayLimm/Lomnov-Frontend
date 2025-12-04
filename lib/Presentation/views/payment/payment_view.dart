import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/views/payment/widgets/image_card.dart';
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
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, paymentProvider, child) {
          return paymentProvider.isLoading
              ? const Center(child: CircularProgressIndicator(),)
              : Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: Column(children: [
                    PaymentDetail()
                    
                    ]),
                );
        },
      ),
    );
  }
}
