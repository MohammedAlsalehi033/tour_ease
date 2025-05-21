import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_state.dart';
import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';
import 'package:tour_ease/model/rideSharing/offer/offerRepo.dart';



// ===== Offer BLoC =====
class OfferBloc extends Bloc<OfferEvent, OfferState> {
  final OffersRepo offersRepo;

  OfferBloc(this.offersRepo) : super(OfferInitial()) {
    on<GetAllOffersEvent>(_onGetAllOffers);
    on<GetOfferByIdEvent>(_onGetOfferById);
    on<CreateOfferEvent>(_onCreateOffer);
    on<AcceptOfferEvent>(_onAcceptOffer);
    on<RejectOfferEvent>(_onRejectOffer);
    on<GetReceivedOffersEvent>(_onGetReceivedOffers);
    on<GetSentOffersEvent>(_onGetSentOffers);
    on<GetOffersForListingEvent>(_onGetOffersForListing);
    on<GetOffersForRequestEvent>(_onGetOffersForRequest);
    on<GetUserOfferStatsEvent>(_onGetUserOfferStats);
  }

  Future<void> _onGetAllOffers(GetAllOffersEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offers = await offersRepo.getAllOffers(
        page: event.page,
        limit: event.limit,
        sort: event.sort,
        senderId: event.senderId,
        recipientId: event.recipientId,
        status: event.status,
        listingId: event.listingId,
        requestId: event.requestId,
      );
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onGetOfferById(GetOfferByIdEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offer = await offersRepo.getOfferById(event.id);
      emit(SingleOfferLoaded(offer));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onCreateOffer(CreateOfferEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offer = await offersRepo.createOffer(
        senderId: event.senderId,
        recipientId: event.recipientId,
        pricePerSeat: event.pricePerSeat,
        seatsRequested: event.seatsRequested,
        message: event.message,
        transportationListingId: event.transportationListingId,
        transportationRequestId: event.transportationRequestId,
      );
      emit(OfferCreated(offer));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onAcceptOffer(AcceptOfferEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final result = await offersRepo.acceptOffer(event.id);
      emit(OfferAccepted(
        offer: result['offer'],
        booking: result['booking'],
        message: result['message'],
      ));

    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onRejectOffer(RejectOfferEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offer = await offersRepo.rejectOffer(event.id);
      emit(OfferRejected(offer));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onGetReceivedOffers(GetReceivedOffersEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offers = await offersRepo.getReceivedOffers(
        event.userId,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onGetSentOffers(GetSentOffersEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offers = await offersRepo.getSentOffers(
        event.userId,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onGetOffersForListing(GetOffersForListingEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offers = await offersRepo.getOffersForListing(
        event.listingId,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onGetOffersForRequest(GetOffersForRequestEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final offers = await offersRepo.getOffersForRequest(
        event.requestId,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> _onGetUserOfferStats(GetUserOfferStatsEvent event, Emitter<OfferState> emit) async {
    try {
      emit(OfferLoading());
      final stats = await offersRepo.getUserOfferStats(event.userId);
      emit(UserOfferStatsLoaded(stats));
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }
}