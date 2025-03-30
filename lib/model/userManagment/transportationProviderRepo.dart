
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/rideSharing/rideRepository.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';
import 'package:tour_ease/model/userManagment/user.dart';

abstract class TransportationProviderRepo {
  Future<TransportationProviderModel> fetchTransportationProvider(String transportationProviderId);
  Future<TransportationProviderModel> createTransportationProvider(TransportationProviderModel transportaitonProviderModel, List<XFile> vehicleMedia, List<XFile> licenseMedia);
}


class TransportationProviderRepoFromAPI extends TransportationProviderRepo {
  final APIService apiService;
  final String baseUrl;

  TransportationProviderRepoFromAPI({required this.apiService}): baseUrl = apiService.baseUrl;
  final Dio dio= Dio();
  @override
  Future<TransportationProviderModel> fetchTransportationProvider(String transportationProviderId) async {
    String url = '$baseUrl/api/getTransportationProvider/$transportationProviderId';


    try {
      final response = await dio.get(url);


      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          if (data.containsKey('success') && data['success'] == true && data.containsKey('data')) {
            return TransportationProviderModel.fromJson(data['data']);
          } else {
            String message = data['message'] ?? 'API request failed (success: false)';
            throw Exception(message);
          }
        } else {
          throw Exception('Invalid response format received from server.');
        }
      } else {

        throw Exception('Received unexpected status code: ${response.statusCode}');
      }

    } on DioException catch (e) {

      if (e.response != null) {
        final responseData = e.response!.data;
        final statusCode = e.response!.statusCode;
        String serverMessage = 'An error occurred (Status $statusCode)';

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            serverMessage = responseData['message'];
          } else if (responseData.containsKey('error')) {
            serverMessage = responseData['error'];
          }
          if (statusCode == 404 && responseData['success'] == false) {
            serverMessage = responseData['message'] ?? 'Transportation provider not found';
          }
        } else {
          serverMessage = 'Server returned error status $statusCode, but response format was unexpected.';
        }

        throw Exception(serverMessage);

      } else {
        throw Exception('Network error fetching TP data: ${e.message}');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<TransportationProviderModel> createTransportationProvider(
      TransportationProviderModel transportaitonProviderModel, // Assuming this model holds non-file input data like type, seats
      List<XFile> vehicleMedia,
      List<XFile> licenseMedia) async {

    // Assume 'dio' and 'baseUrl' are accessible/defined in the surrounding class context
    // final Dio dio = Dio();
    // final String baseUrl = 'YOUR_BASE_URL';

    List<MultipartFile> licenseFiles = [];
    if (licenseMedia != null) {
      for (var file in licenseMedia) {
        licenseFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ));
      }
    }

    List<MultipartFile> vehicleFiles = [];
    if (vehicleMedia != null) {
      for (var file in vehicleMedia) {
        vehicleFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ));
      }
    }


    FormData formData = FormData.fromMap({
      'id': UserModel().id,
      'role' : "asdfasdfasd",
      'vehicleType': transportaitonProviderModel.vehicleType,
      'seatsAvailable': transportaitonProviderModel.seatsAvailable.toString(),
      if (licenseFiles.isNotEmpty) 'licenseMedia': licenseFiles,
      if (vehicleFiles.isNotEmpty) 'vehicleMedia': vehicleFiles,
    });

    String url = '$baseUrl/api/createTransportationProvider';

    try {

      final response = await dio.post(
        url,
        data: formData,
        options: Options(method: 'POST'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(response);
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success') &&
            responseData['success'] == true &&
            responseData.containsKey('data')) {
          return TransportationProviderModel.fromJson(responseData['data']);
        } else {
          String message = (responseData is Map<String, dynamic> && responseData.containsKey('message'))
              ? responseData['message']
              : 'API returned success status but invalid data format.';
          throw Exception(message);
        }
      } else {
        throw Exception('Failed to create provider: Status Code ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to create provider.";
      if (e.response != null) {
        final errorData = e.response!.data;
        final statusCode = e.response!.statusCode;
        errorMessage = 'Error $statusCode: ';
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          errorMessage += errorData['message'];
        } else {
          errorMessage += e.response!.statusMessage ?? "Unknown server error";
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {

      throw Exception('An unexpected error occurred: $e');
    }
  }

}
