import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideRepository.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';
import 'package:tour_ease/model/userManagment/user.dart';

abstract class TransportationProviderRepo {
  Future<TransportationProviderModel> fetchTransportationProvider(String transportationProviderId);
  Future<TransportationProviderModel> createTransportationProvider(TransportationProviderModel transportaitonProviderModel, List<XFile> vehicleMedia, List<XFile> licenseMedia);
}

class TransportationProviderRepoFromAPI extends TransportationProviderRepo {
  final APIService apiService;

  TransportationProviderRepoFromAPI({required this.apiService});

  @override
  Future<TransportationProviderModel> fetchTransportationProvider(String transportationProviderId) async {
    try {
      return await apiService.get<TransportationProviderModel>(
        path: '/api/getTransportationProvider/$transportationProviderId',
        fromJson: (json) => TransportationProviderModel.fromJson(json),
      );
    } catch (e) {
      throw Exception('Error fetching transportation provider: $e');
    }
  }

  @override
  Future<TransportationProviderModel> createTransportationProvider(
      TransportationProviderModel transportaitonProviderModel,
      List<XFile> vehicleMedia,
      List<XFile> licenseMedia) async {
    try {
      List<MultipartFile> licenseFiles = [];
      for (var file in licenseMedia) {
        licenseFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ));
      }

      List<MultipartFile> vehicleFiles = [];
      for (var file in vehicleMedia) {
        vehicleFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ));
      }

      FormData formData = FormData.fromMap({
        'id': UserModel().id,
        'role': "asdfasdfasd",
        'vehicleType': transportaitonProviderModel.vehicleType,
        'seatsAvailable': transportaitonProviderModel.seatsAvailable.toString(),
        if (licenseFiles.isNotEmpty) 'licenseMedia': licenseFiles,
        if (vehicleFiles.isNotEmpty) 'vehicleMedia': vehicleFiles,
      });

      return await apiService.post<TransportationProviderModel>(
        path: '/api/createTransportationProvider',
        body: formData,
        fromJson: (json) => TransportationProviderModel.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('An unexpected error occurred while creating provider: $e');
    }
  }
}