import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/bloc/themeSwithBloc.dart';
import 'package:tour_ease/bloc/rideResultsBloc.dart';
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/controller/chat/chat_bloc.dart';
import 'package:tour_ease/controller/chat/messages_bloc.dart';
import 'package:tour_ease/controller/report/report_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/provider/booking_for_provider_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/traveler/booking_for_traveler_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideRequests/ride_request_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_bloc.dart';
import 'package:tour_ease/controller/rideSharing/offers/offers_event.dart';
import 'package:tour_ease/controller/rideSharing/transportationProvider/transporation_provider_bloc.dart';
import 'package:tour_ease/controller/userManagment/JWTController.dart';
import 'package:tour_ease/controller/question/commets/comments_bloc.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/controller/question/votes/votes_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tour_ease/model/chat/chatRepo.dart';
import 'package:tour_ease/model/report/report_repository.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBookingRepo.dart';
import 'package:tour_ease/model/rideSharing/offer/offerRepo.dart';
import 'package:tour_ease/model/userManagment/transportationProviderRepo.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/question/comments/commentRepo.dart';
import 'package:tour_ease/model/question/questionRepo.dart';
import 'package:tour_ease/model/question/votes/votesRepo.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideRepository.dart';
import 'package:tour_ease/theme.dart';
import 'package:tour_ease/view/auth.dart';
import 'package:tour_ease/view/mainPage.dart';
import 'package:tour_ease/Services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();

  // Always print FCM token at app start
  try {
    final String? startupToken = await NotificationService().getToken();
    if (startupToken != null) {
      // ignore: avoid_print
      print('FCM at startup: ' + startupToken);
    }
  } catch (_) {}

  // final baseUrlLocal = "http://10.0.2.2:3000";
  final baseUrlDeploied = "https://api.tourease.me";

  final userJWT = await getFirebaseIdToken();

  final APIService apiService = APIServiceNodeJS(baseUrlDeploied, userJWT ?? "");

  runApp(
    // 3. Provide that single instance to the entire widget tree.
    RepositoryProvider.value(
      value: apiService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(
            create: (context) => RideFilterBloc(),
          ),
          BlocProvider(
            create: (context) => RideResultBloc(
              // 4. Read the provided instance from the context.
              rideRepository: RideRepositoryImpl(
                  apiService: context.read<APIService>()),
            ),
          ),
          BlocProvider(
            create: (context) => QuestionBloc(
                questionRepository:
                QuestionRepoFromAPI(context.read<APIService>())),
          ),
          BlocProvider(
              create: (context) =>
                  VotesBloc(VotesRepoNodeAPI(context.read<APIService>()))),
          BlocProvider(
              create: (context) => CommentsBloc(
                  CommentRepoNodeJSApi(context.read<APIService>()))),
          BlocProvider(
              create: (context) => RideRequestBloc(
                  rideRepository:
                  RideRepositoryImpl(apiService: context.read<APIService>()))),
          BlocProvider(
              create: (context) => TransporationProviderBloc(
                  TransportationProviderRepoFromAPI(
                      apiService: context.read<APIService>()),
                  RideRepositoryImpl(
                      apiService: context.read<APIService>()))),
          BlocProvider(
              create: (context) => OfferBloc(
                  OfferRepoNodeJSApi(context.read<APIService>()))
                ..add(GetAllOffersEvent())),
          BlocProvider(
              create: (context) => BookingBloc(
                  bookingRepository: BookingRepositoryImpl(
                      apiService: context.read<APIService>()))), BlocProvider(
              create: (context) => BookingForTravelerBloc(
                   BookingRepositoryImpl(
                      apiService: context.read<APIService>()))), BlocProvider(
              create: (context) => BookingForProviderBloc(
                   BookingRepositoryImpl(
                      apiService: context.read<APIService>()))),
          BlocProvider(
              create: (context) => ChatBloc(
                  chatService: ChatService(
                      apiService: context.read<APIService>(),
                      apiBaseUrl: context.read<APIService>().baseUrl,
                      currentUserId: UserModel().id),
                  currentUserId: UserModel().id))
        ,BlocProvider(create: (context) => MessagesBloc(chatService: ChatService(
              apiService: context.read<APIService>(),
              apiBaseUrl: context.read<APIService>().baseUrl,
              currentUserId: UserModel().id), currentUserId: UserModel().id,),),
        BlocProvider(create: (context) => ReportBloc(reportRepository: ReportRepoFromAPI(apiService) ),)
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          darkTheme: AppThemes.darkTheme,
          home: ScreenUtilInit(
            designSize: const Size(360, 800),
            builder: (_, child) => _handleAuthState(),
          ),
        );
      },
    );
  }

  Widget _handleAuthState() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Upload FCM token only once per user (first login)
          final String uid = snapshot.data!.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _uploadFcmTokenOnce(context, uid);
          });
          return const MainPage();
        }
        return const AuthScreen();
      },
    );
  }
}

Future<void> _uploadFcmTokenOnce(BuildContext context, String userId) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'fcm_uploaded_' + userId;
    final bool alreadyUploaded = prefs.getBool(key) ?? false;
    if (alreadyUploaded) return;

    final String? token = await NotificationService().getToken();
    if (token == null || token.isEmpty) return;

    final APIService api = context.read<APIService>();
    await api.post(
      path: '/FCMToken/' + userId,
      body: {'fcmToken': token},
      fromJson: (json) => json,
    );

    await prefs.setBool(key, true);
    // ignore: avoid_print
    print('Uploaded FCM for first login of ' + userId);
  } catch (e) {
    // ignore: avoid_print
    print('Failed first-time FCM upload: ' + e.toString());
  }
}




