part of 'transporation_provider_bloc.dart';

@immutable
sealed class TransporationProviderEvent {}

class FetchCurrentTransportationProviderData extends TransporationProviderEvent{}
