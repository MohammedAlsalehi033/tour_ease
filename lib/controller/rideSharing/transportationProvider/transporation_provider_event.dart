part of 'transporation_provider_bloc.dart';

@immutable
sealed class TransporationProviderEvent {}

class FetchCurrentTransportationProviderData extends TransporationProviderEvent{}

class CreateTransportationProvider extends TransporationProviderEvent{
    final TransportationProviderModel transportationProviderModel;
    final List<XFile> licenseMedia;
    final List<XFile> vehicleMedia;

    CreateTransportationProvider(
      this.transportationProviderModel, this.licenseMedia, this.vehicleMedia);
}

class CreateTransportationProviderListing extends TransporationProviderEvent{
     final RideListingModel rideListing;

  CreateTransportationProviderListing({required this.rideListing});
}

