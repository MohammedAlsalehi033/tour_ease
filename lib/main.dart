import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/bloc/themeSwithBloc.dart';
import 'package:tour_ease/bloc/rideResultsBloc.dart';
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/controller/auth/initialize.dart';
import 'package:tour_ease/controller/question/commets/comments_bloc.dart';
import 'package:tour_ease/controller/question/questionBloc.dart';
import 'package:tour_ease/controller/question/votes/votes_bloc.dart';
import 'package:tour_ease/model/auth/user.dart';
import 'package:tour_ease/model/question/comments/commentRepo.dart';
import 'package:tour_ease/model/question/questionRepo.dart';
import 'package:tour_ease/model/question/votes/votesRepo.dart';
import 'package:tour_ease/model/rideSharing/rideRepository.dart';
import 'package:tour_ease/testingthings/test.dart';
import 'package:tour_ease/theme.dart';
import 'package:tour_ease/view/auth.dart';
import 'package:tour_ease/view/mainPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(
          create: (context) => RideFilterBloc(),
        ),
        BlocProvider(
          create: (context) => RideResultBloc(
            rideRepository: RideRepositoryImpl(apiService: ApiService()),
          ),
        ),
        BlocProvider(create: (context) => QuestionBloc(questionRepository: QuestionRepoFromAPI(APIServiceNodeJS("http://10.0.2.2:3000"))),),
        BlocProvider(create: (context) => VotesBloc(VotesRepoNodeAPI(APIServiceNodeJS("http://10.0.2.2:3000")))),
        BlocProvider(create: (context) => CommentsBloc(CommentRepoNodeJSApi(APIServiceNodeJS("http://10.0.2.2:3000")))),
      ],
      child: MyApp(),
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
          return const MainPage();
        }
        return const AuthScreen();
      },
    );
  }
}