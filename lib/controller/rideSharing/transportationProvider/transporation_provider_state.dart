part of 'transporation_provider_bloc.dart';

@immutable
sealed class TransporationProviderState {}

final class TransporationProviderInitial extends TransporationProviderState {}

class TransportationProviderdataLoaded extends TransporationProviderState{
 final TransportationProviderModel transportationProviderModel;

  TransportationProviderdataLoaded({required this.transportationProviderModel});
}

class TransportationProviderdataLoading extends TransporationProviderState {}


class TransportationProviderdataError extends TransporationProviderState {
  final String error;

  TransportationProviderdataError({required this.error});

}

