import 'package:app/data/dto/building_dto.dart';
import 'package:app/data/dto/contract_dto.dart';
import 'package:app/data/dto/room_dto.dart';
import 'package:app/data/dto/service_dto.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/data/services/building_service.dart';
import 'package:app/data/services/contract_service/contract_service.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/data/services/rooms_service/room_services_service.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/domain/models/settings/service_model.dart';
import 'package:app/domain/models/user_model/user_model.dart';
import 'package:flutter/material.dart';

class PaymentViewModel extends ChangeNotifier {
  final BuildingService buildingService = BuildingService();
  final RoomFetchService roomService = RoomFetchService();
  final RoomServicesService roomServiceService = RoomServicesService();
  final AuthService authService = AuthService();
  final ContractService contractService = ContractService();

  int? landlord_id = 0;
  bool _isLoading = false;

  List<BuildingModel> _buildings = [];
  List<RoomModel> _rooms = [];
  UserModel? _tenant;
  ContractDto? contract;

  BuildingModel? selectedBuilding;
  List<BuildingModel> get buildings => _buildings;

  List<ServiceDto> roomServices = [];
  double? water = 0;
  double? electricity = 0;

  bool get isLoading => _isLoading;
  // In PaymentViewModel class
  List<RoomModel> get rooms => _rooms;
  UserModel? get tenant => _tenant;

  // Add room selection method
  RoomModel? selectedRoom;

  void verifyPayment(){
    
  }

  void selectRoom(RoomModel? room) async {
    selectedRoom = room;
    await loadRoomService();
    await fetchActiveContract();
    notifyListeners();
  }

  Future<void> loadRoomService() async {
    print("Loading services");
    if (selectedRoom != null) {
      print("Start fetching serivces");
      roomServices = await roomServiceService.fetchRoomServices(
        selectedRoom!.id,
      );
      print("room serives lenght : ${roomServices.length}");
    }
    return;
  }

  void setWater(double data) {
    water = data;
    notifyListeners();
  }

  void setElectricity(double data) {
    electricity = data;
    notifyListeners();
  }

  void tester() {
    print("RoomID: ${selectedRoom?.id ?? "hark"}");
    print("water: ${water}");
    print("electricity: ${electricity}");
    fetchActiveContract();
  }

  Future<void> loadData() async {
    try {
      clearData();
      _isLoading = true;
      notifyListeners();

      landlord_id = await authService.getLandlordId();
      if (landlord_id == null) {
        print("LANORD HAVE NO ID IN PAYMENT DEAITL PROVIDER");
        return;
      }
      List<BuildingDto> buidlingDTO = await buildingService.fetchBuildings(
        landlord_id,
      );
      buidlingDTO.forEach((building) {
        BuildingModel temp = building.toDomain();
        _buildings.add(temp);
      });
      print("Bulding length${_buildings.length}");
    } catch (error) {
      print('Error loading buildings: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveContract() async {
    if (selectedRoom != null) {
      contract = await contractService.fetchActiveContract(selectedRoom!.id);
    }
  }

  Future<void> loadRoomFromBuilding(int $id) async {
    try {
      _rooms.clear();
      selectRoom(null);
      landlord_id = await authService.getLandlordId();
      if (landlord_id == null) {
        return;
      }
      final res = await roomService.fetchRooms(buildingId: $id);

      List<RoomDto> rooms = res.items;
      rooms.forEach((room) {
        RoomModel temp = room.toDomain();
        _rooms.add(temp);
      });
    } catch (error) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _buildings.clear();
    _rooms.clear();
    selectBuilding(null);
    selectRoom(null);
    roomServices.clear();
    contract = null;
    water = 0;
    electricity=0;
    notifyListeners();
  }

  // Optional: Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  void selectBuilding(BuildingModel? selected) {
    selectedBuilding = selected;
    notifyListeners();
  }

}
