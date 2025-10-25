import 'package:tour_ease/model/userManagment/UserModelTempForNow.dart';

class TransportationProviderModel {
 final String providerId;
 final List<String> licenseMmediaUrls;
 final List<String> vehicleMediaUrls;
 final String vehicleType;
 final int seatsAvailable;
 final String accountStatus;
 final DateTime createdAt;
 final UserModelTempForNow user;

 TransportationProviderModel({
  required this.providerId,
  required this.licenseMmediaUrls,
  required this.vehicleMediaUrls,
  required this.vehicleType,
  required this.seatsAvailable,
  required this.accountStatus,
  required this.createdAt,
  required this.user,
 });

 factory TransportationProviderModel.fromJson(Map<String, dynamic> json) {
  return TransportationProviderModel(
   providerId: json['providerId'],
   licenseMmediaUrls: (json['licenseMmediaUrls'] as List<dynamic>).cast<String>(),
   vehicleMediaUrls: (json['vehicleMediaUrls'] as List<dynamic>).cast<String>(),
   vehicleType: json['vehicleType'],
   seatsAvailable: json['seatsAvailable'],
   accountStatus: json['accountStatus'],
   createdAt: DateTime.parse(json['createdAt']),
   user: json['user'] != null ? UserModelTempForNow.fromJson(json['user']) : UserModelTempForNow(id: "",createdAt: DateTime.now(),accountStatus: "",mediaUrls: [],email: "",username: "") ,
  );
 }

 @override
  String toString() {
    return 'TransportationProviderModel{providerId: $providerId, licenseMmediaUrls: $licenseMmediaUrls, vehicleMediaUrls: $vehicleMediaUrls, vehicleType: $vehicleType, seatsAvailable: $seatsAvailable, accountStatus: $accountStatus, createdAt: $createdAt, user: $user}';
  }
}
