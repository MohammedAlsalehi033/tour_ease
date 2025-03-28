
import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/rideSharing/rideRepository.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';
import 'package:tour_ease/model/userManagment/user.dart';

abstract class TransportationProviderRepo {
  Future<TransportationProviderModel> fetchTransportationProvider(String transportationProviderId);
  Future<TransportationProviderModel> createTransportationProvider();
}


class TransportationProviderRepoFromAPI extends TransportationProviderRepo {
  final APIService apiService;
  final String baseUrl;

  TransportationProviderRepoFromAPI({required this.apiService}): baseUrl = apiService.baseUrl;
  final Dio dio= Dio();
  @override
  Future<TransportationProviderModel> fetchTransportationProvider(String transportationProviderId) async{
      String url = '$baseUrl/api/getTransportationProvider/$transportationProviderId';
      var headers = {
        'Content-Type': 'application/json',
      };

    try {

      final response = await dio.get(
        url,
        options: Options(headers: headers),
      );



      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return TransportationProviderModel.fromJson(data['data']);
        } else {
          throw Exception('API request was not successful');
        }
      } else {

        throw Exception('Failed to TP data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TP data: $e');
    }
  }

  @override
  Future<TransportationProviderModel> createTransportationProvider() {
    // TODO: implement fetchTransportationProvider
    throw UnimplementedError();
  }

}
