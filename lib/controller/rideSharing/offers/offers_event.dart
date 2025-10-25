abstract class OfferEvent  {
  const OfferEvent();

  @override
  List<Object?> get props => [];
}

class GetAllOffersEvent extends OfferEvent {
  final int page;
  final int limit;
  final String sort;
  final String? senderId;
  final String? recipientId;
  final String? status;
  final int? listingId;
  final int? requestId;

  const GetAllOffersEvent({
    this.page = 1,
    this.limit = 10,
    this.sort = 'newest',
    this.senderId,
    this.recipientId,
    this.status,
    this.listingId,
    this.requestId,
  });

  @override
  List<Object?> get props => [page, limit, sort, senderId, recipientId, status, listingId, requestId];
}

class GetOfferByIdEvent extends OfferEvent {
  final int id;

  const GetOfferByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class CreateOfferEvent extends OfferEvent {
  final String senderId;
  final String recipientId;
  final double pricePerSeat;
  final int seatsRequested;
  final String? message;
  final int? transportationListingId;
  final int? transportationRequestId;

  const CreateOfferEvent({
    required this.senderId,
    required this.recipientId,
    required this.pricePerSeat,
    required this.seatsRequested,
    this.message,
    this.transportationListingId,
    this.transportationRequestId,
  });

  @override
  List<Object?> get props => [
    senderId,
    recipientId,
    pricePerSeat,
    seatsRequested,
    message,
    transportationListingId,
    transportationRequestId
  ];
}

class AcceptOfferEvent extends OfferEvent {
  final int id;

  const AcceptOfferEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RejectOfferEvent extends OfferEvent {
  final int id;

  const RejectOfferEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetReceivedOffersEvent extends OfferEvent {
  final String userId;
  final int page;
  final int limit;
  final String? status;

  const GetReceivedOffersEvent({
    required this.userId,
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [userId, page, limit, status];
}

class GetSentOffersEvent extends OfferEvent {
  final String userId;
  final int page;
  final int limit;
  final String? status;

  const GetSentOffersEvent({
    required this.userId,
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [userId, page, limit, status];
}

class GetOffersForListingEvent extends OfferEvent {
  final int listingId;
  final int page;
  final int limit;
  final String? status;

  const GetOffersForListingEvent({
    required this.listingId,
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [listingId, page, limit, status];
}

class GetOffersForRequestEvent extends OfferEvent {
  final int requestId;
  final int page;
  final int limit;
  final String? status;

  const GetOffersForRequestEvent({
    required this.requestId,
    this.page = 1,
    this.limit = 10,
    this.status,
  });

  @override
  List<Object?> get props => [requestId, page, limit, status];
}

class GetUserOfferStatsEvent extends OfferEvent {
  final String userId;

  const GetUserOfferStatsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
