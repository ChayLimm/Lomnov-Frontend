import 'dart:developer';

import 'package:app/data/dto/building_dto.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/data/services/building_service.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:flutter/material.dart';

class PaymentViewModel extends ChangeNotifier {
  final BuildingService buildingService = BuildingService();
  final RoomFetchService roomService = RoomFetchService();
  final AuthService authService = AuthService();

  
  int? landlord_id = 0;
  bool _isLoading = false;
  List<BuildingModel> _buildings = [];
  List<ServiceModel>
  BuildingModel? selectedBuilding ;

  bool get isLoading => _isLoading;
  List<BuildingModel> get buildings => _buildings;

  Future<void> loadData() async {
    try {
      clearData(); 
      _isLoading = true;
      notifyListeners(); 

      landlord_id = await authService.getLandlordId();
      if(landlord_id == null){
        print("LANORD HAVE NO ID IN PAYMENT DEAITL PROVIDER");
        return ;
      }
      List<BuildingDto> buidlingDTO = await buildingService.fetchBuildings(landlord_id);
      buidlingDTO.forEach((building){
        BuildingModel temp =  building.toDomain();
        _buildings.add(temp);
      });
      
    } catch (error) {
      print('Error loading buildings: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _buildings.clear();
    notifyListeners();
  }

  // Optional: Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
}