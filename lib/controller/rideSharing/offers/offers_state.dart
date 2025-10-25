import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';

abstract class OfferState {
  const OfferState();

  @override
  List<Object?> get props => [];
}

class OfferInitial extends OfferState {}

class OfferLoading extends OfferState {}

class OffersLoaded extends OfferState {
  final List<OfferModel> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object> get props => [offers];
}

class SingleOfferLoaded extends OfferState {
  final OfferModel offer;

  const SingleOfferLoaded(this.offer);

  @override
  List<Object> get props => [offer];
}

class OfferCreated extends OfferState {
  final OfferModel offer;

  const OfferCreated(this.offer);

  @override
  List<Object> get props => [offer];
}

class OfferAccepted extends OfferState {
  final OfferModel offer;
  final dynamic booking;
  final String message;

  const OfferAccepted({
    required this.offer,
    required this.booking,
    required this.message,
  });

  @override
  List<Object> get props => [offer, booking, message];
}

class OfferRejected extends OfferState {
  final OfferModel offer;

  const OfferRejected(this.offer);

  @override
  List<Object> get props => [offer];
}

class UserOfferStatsLoaded extends OfferState {
  final Map<String, dynamic> stats;

  const UserOfferStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class OfferError extends OfferState {
  final String message;

  const OfferError(this.message);

  @override
  List<Object> get props => [message];
}
