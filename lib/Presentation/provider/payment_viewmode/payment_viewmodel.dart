import 'package:app/data/dto/building_dto.dart';
import 'package:app/data/dto/consumption_dto.dart';
import 'package:app/data/dto/contract_dto.dart';
import 'package:app/data/dto/room_dto.dart';
import 'package:app/data/dto/service_dto.dart';
import 'package:app/data/dto/setting_dto.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/data/services/building_service.dart';
import 'package:app/data/services/consumptions_service/fetch_service.dart';
import 'package:app/data/services/contract_service/contract_service.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/data/services/rooms_service/room_services_service.dart';
import 'package:app/data/services/setting_service.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/domain/models/user_model/user_model.dart';
import 'package:flutter/material.dart';

class PaymentViewModel extends ChangeNotifier {
  final BuildingService buildingService = BuildingService();
  final RoomFetchService roomService = RoomFetchService();
  final RoomServicesService roomServiceService = RoomServicesService();
  final AuthService authService = AuthService();
  final ContractService contractService = ContractService();
  final ConsumptionsFetchService consumptionService =
      ConsumptionsFetchService();
  final SettingService settingService = ApiSettingService();
  // final Settin

  int? landlord_id = 0;
  bool _isLoading = false;

  List<BuildingModel> _buildings = [];
  List<RoomModel> _rooms = [];
  UserModel? _tenant;
  ContractDto? contract;
  int? electricityServiceID;
  int? waterServiceID;
  bool isLastPayment = false;
  List<ConsumptionDto> latestConsumptions = [];

  late SettingDto setting;

  BuildingModel? selectedBuilding;
  List<BuildingModel> get buildings => _buildings;

  List<ServiceDto> roomServices = [];
  double? water = 0;
  double? electricity = 0;

  double water_qty = 0;
  double electricity_qty = 0;

  double water_total = 0;
  double electricity_total = 0;

  bool get isLoading => _isLoading;
  // In PaymentViewModel class
  List<RoomModel> get rooms => _rooms;
  UserModel? get tenant => _tenant;

  // Add room selection method
  RoomModel? selectedRoom;

  void verifyPayment() {}

  Future<void> loadConumption() async {
    if (selectedRoom != null) {
      latestConsumptions = await roomService.getLatestConsumption(
        selectedRoom!.id,
      );
    }
  }

  void selectRoom(RoomModel? room) async {
  selectedRoom = room;
  water = 0;
  electricity = 0;
  water_qty = 0;
  electricity_qty = 0;
  water_total = 0;
  electricity_total = 0;
  roomServices.clear();
  latestConsumptions.clear();
  contract = null;
  electricityServiceID = null;
  waterServiceID = null;

  if (room != null) {
    await loadRoomService();
    await fetchActiveContract();
    await loadConumption();
  }

  notifyListeners();
}
  Future<void> loadRoomService() async {
    print("Loading services");
    if (selectedRoom != null) {
      roomServices = await roomServiceService.fetchRoomServices(
        selectedRoom!.id,
      );

      // Use forEach instead of map
      roomServices.forEach((item) {
        print("service name : ${item.name}");
        if (item.name == "electricity") {
          electricityServiceID = item.id;
        } else if (item.name == "water") {
          waterServiceID = item.id;
        }
      });

      print("Found ${roomServices.length} services");
    }
  }

  void setWater(double data) {
  final waterConsumption = latestConsumptions.firstWhere(
    (element) => element.type == "water",
    orElse: () => ConsumptionDto(
      id: 0,
      roomId: 0,
      serviceId: null,
      endReading: 0,
      photoUrl: '',
      consumption: 0,
      type: 'water',
    ),
  );
  
  // If input is smaller than end reading, set water to the reading value
  if (data < waterConsumption.endReading) {
    water = waterConsumption.endReading;
  } else {
    water = data;
  }
  
  water_qty = water! - waterConsumption.endReading;
  water_total = water_qty * (setting.waterPrice ?? 0);
  notifyListeners();
}

void setElectricity(double data) {
  final electricityConsumption = latestConsumptions.firstWhere(
    (element) => element.type == "electricity",
    orElse: () => ConsumptionDto(
      id: 0,
      roomId: 0,
      serviceId: null,
      endReading: 0,
      photoUrl: '',
      consumption: 0,
      type: 'electricity',
    ),
  );
  
  // If input is smaller than end reading, set electricity to the reading value
  if (data < electricityConsumption.endReading) {
    electricity = electricityConsumption.endReading;
  } else {
    electricity = data;
  }
  
  electricity_qty = electricity! - electricityConsumption.endReading;
  electricity_total = electricity_qty * (setting.electricityPrice ?? 0);
  
  notifyListeners();
}
  void tester() {
    print("RoomID: ${selectedRoom?.id ?? "hark"}");
    print("water: ${water}, id : ${waterServiceID}");
    print("electricity: ${electricity}, id : ${electricityServiceID}");
    print("latestConumption");
    latestConsumptions.forEach((element) {
      print(element.type);
    });
    print("Setting");
    print(setting.electricityPrice);
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

      setting = await settingService.fetchSettings(landlord_id!);

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

  Future<void> loadRoomFromBuilding(int buildingId) async {
    try {
      _rooms.clear();
      selectRoom(null); // This already clears room-related data

      landlord_id = await authService.getLandlordId();
      if (landlord_id == null) {
        return;
      }

      final res = await roomService.fetchRooms(buildingId: buildingId);

      List<RoomDto> rooms = res.items ?? []; // Handle null items
      rooms.forEach((room) {
        RoomModel temp = room.toDomain();
        _rooms.add(temp);
      });
    } catch (error) {
      print('Error loading rooms: $error');
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
    electricity = 0;
    notifyListeners();
  }

  // Optional: Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  void selectBuilding(BuildingModel? selected) {
    selectedBuilding = selected;

    // Clear all room-related data
    _rooms.clear();
    selectRoom(null);
    roomServices.clear();
    contract = null;
    water = 0;
    electricity = 0;
    water_qty = 0;
    electricity_qty = 0;
    water_total = 0;
    electricity_total = 0;
    latestConsumptions.clear();
    electricityServiceID = null;
    waterServiceID = null;

    // Only load rooms if a building is selected
    if (selected != null) {
      loadRoomFromBuilding(selected.id);
    }

    notifyListeners();
  }

  // List<ConsumptionDto> getUniqueLatestConsumptions(
  //   List<ConsumptionDto> consumptions,
  // ) {
  //   // Sort by latest createdAt first (descending)
  //   consumptions.sort((a, b) {
  //     final aDate = a.createdAt ?? DateTime(1900);
  //     final bDate = b.createdAt ?? DateTime(1900);
  //     return bDate.compareTo(aDate);
  //   });

  //   // Keep only the first (latest) occurrence of each serviceId
  //   final uniqueMap = <int, ConsumptionDto>{};
  //   for (var consumption in consumptions) {
  //     uniqueMap.putIfAbsent(consumption.serviceId, () => consumption);
  //   }

  //   // Return as list
  //   return uniqueMap.values.toList();
  // }
}
