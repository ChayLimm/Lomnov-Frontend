import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentDetail extends StatefulWidget {
  const PaymentDetail({super.key});

  @override
  State<PaymentDetail> createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
    final _formKey = GlobalKey<FormState>();
    late TextEditingController _waterController;
    late TextEditingController _electricityController;

    @override
    void initState() {
      super.initState();
      final provider = context.read<PaymentViewModel>();
      _waterController = TextEditingController(text: provider.water.toString());
      _electricityController = TextEditingController(text: provider.electricity.toString(),);
    }

    @override
    void dispose() {
      _waterController.dispose();
      _electricityController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
  
    return Consumer<PaymentViewModel>(
      builder: (context, paymentProvider, child) {
      

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment details",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Building",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    DropdownButtonFormField<BuildingModel>(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                      ),
                      initialValue: paymentProvider.selectedBuilding,
                      items: paymentProvider.buildings.map((building) {
                        return DropdownMenuItem<BuildingModel>(
                          value: building,
                          child: Text(building.name),
                        );
                      }).toList(),
                      onChanged: (BuildingModel? newValue) {
                        if (newValue != null) {
                          // selectBuilding already loads rooms for the building,
                          // avoid calling loadRoomFromBuilding twice which caused duplicates.
                          paymentProvider.selectBuilding(newValue);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Select a building' : null,
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "Room",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    paymentProvider.selectedBuilding != null
                        ? DropdownButtonFormField<RoomModel>(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                            ),
                            initialValue: paymentProvider.selectedRoom,
                            items: paymentProvider.rooms.map((rooms) {
                              return DropdownMenuItem<RoomModel>(
                                value: rooms,
                                child: Text(rooms.roomNumber),
                              );
                            }).toList(),
                            onChanged: (RoomModel? newValue) {
                              if (newValue != null) {
                                paymentProvider.selectRoom(newValue);
                              }
                            },
                            validator: (value) =>
                                value == null ? 'Select a building' : null,
                          )
                        : Container(),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Water",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                 controller: _waterController,
                                  onChanged: (value) {
                                    paymentProvider.setWater(double.tryParse(value) ?? 0);
                                  },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Water is required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16), // Add spacing between columns
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Electricity",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _electricityController,
                                onChanged: (value) {
                                  paymentProvider.setElectricity(double.tryParse(value) ?? 0);
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                    
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Electricity is required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
