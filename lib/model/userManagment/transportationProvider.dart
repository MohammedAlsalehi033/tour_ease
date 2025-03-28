class TransportationProviderModel {
 final String providerId;
 final List<String> licenseMmediaUrls;
 final List<String> vehicleMediaUrls;
 final String vehicleType;
 final int seatsAvailable;
 final String accountStatus;
 final DateTime createdAt;

 TransportationProviderModel(
     this.providerId,
     this.licenseMmediaUrls,
     this.vehicleMediaUrls,
     this.vehicleType,
     this.seatsAvailable,
     this.accountStatus,
     this.createdAt,
     );

 factory TransportationProviderModel.fromJson(Map<String, dynamic> json) {
  return TransportationProviderModel(
   json['providerId'] as String,
   (json['licenseMmediaUrls'] as List<dynamic>).cast<String>(),
   (json['vehicleMediaUrls'] as List<dynamic>).cast<String>(),
   json['vehicleType'] as String,
   json['seatsAvailable'] as int,
   json['accountStatus'] as String,
   DateTime.parse(json['createdAt'] as String),
  );
 }
}