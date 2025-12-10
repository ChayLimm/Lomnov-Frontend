import 'dart:ffi';

import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/views/payment/widgets/info_row.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentDetail extends StatefulWidget {
  const PaymentDetail({super.key});

  @override
  State<PaymentDetail> createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _buildingController = TextEditingController();
    final _roomController = TextEditingController();
    final _waterController = TextEditingController();
    final _electricityController = TextEditingController();

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
                      value: paymentProvider.selectedBuilding,
                      items: paymentProvider.buildings.map((building) {
                        return DropdownMenuItem<BuildingModel>(
                          value: building,
                          child: Text(building.name ?? 'Unnamed Building'),
                        );
                      }).toList(),
                      onChanged: (BuildingModel? newValue) {
                        if (newValue != null) {
                          paymentProvider.selectBuilding(newValue);
                          paymentProvider.loadRoomFromBuilding(
                            newValue.id ?? 0,
                          );
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
                            value: paymentProvider.selectedRoom,
                            items: paymentProvider.rooms.map((rooms) {
                              return DropdownMenuItem<RoomModel>(
                                value: rooms,
                                child: Text(rooms.roomNumber ?? 'Unnamed room'),
                              );
                            }).toList(),
                            onChanged: (RoomModel? newValue) {
                              if (newValue != null) {
                                paymentProvider.selectRoom(newValue);
                                // Load rooms for selected building
                                // paymentProvider.loadRoomFromBuilding(newValue.id ?? 0);
                              }
                            },
                            validator: (value) =>
                                value == null ? 'Select a building' : null,
                          )
                        : Container(),

                    // TextFormField(
                    //   controller: _roomController,
                    //   decoration: InputDecoration(
                    //     border: UnderlineInputBorder(
                    //       borderSide: BorderSide(color: Colors.red),
                    //     ),
                    //     focusedBorder: UnderlineInputBorder(
                    //       borderSide: BorderSide(
                    //         color: AppColors.primaryColor,
                    //         width: 2.0,
                    //       ),
                    //     ),

                    //     contentPadding: EdgeInsets.symmetric(
                    //       horizontal: 16.0,
                    //       vertical: 14.0,
                    //     ),
                    //   ),
                    //   validator: (v) =>
                    //       (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    // ),
                    const SizedBox(height: 12),
                    Container(
                      child: Row(
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
                                  controller:
                                      _waterController, // Changed to different controller
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
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            InfoRow(title: "Total Amount", KeyData: "USD", value: "100"),
          ],
        );
      },
    );
  }
}
