import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:tour_ease/model/userManagment/transportationProvider.dart';
import 'package:tour_ease/model/userManagment/transportationProviderRepo.dart';
import 'package:tour_ease/model/userManagment/user.dart';

part 'transporation_provider_event.dart';
part 'transporation_provider_state.dart';

class TransporationProviderBloc extends Bloc<TransporationProviderEvent, TransporationProviderState> {
  final TransportationProviderRepo _transportationProviderRepository;

  TransporationProviderBloc(this._transportationProviderRepository) : super(TransporationProviderInitial()) {
    on<FetchCurrentTransportationProviderData>((event, emit) async {
      emit(TransportationProviderdataLoading()); // Emit loading state

      try {
        final transportationProvider = await _transportationProviderRepository.fetchTransportationProvider(UserModel().id);
        emit(TransportationProviderdataLoaded(transportationProviderModel: transportationProvider));
      } catch (e) {
        emit(TransportationProviderdataError(error: e.toString()));
      }
    });
    on<CreateTransportationProvider>((event, emit) async {
      emit(TransportationProviderdataLoading());

      try {
        final transportationProvider = await _transportationProviderRepository.createTransportationProvider(event.transportationProviderModel,event.vehicleMedia,event.licenseMedia);
        emit(TransportationProviderdataLoaded(transportationProviderModel: transportationProvider));
      } catch (e) {
        emit(TransportationProviderdataError(error: e.toString()));
      }
    });
  }
}