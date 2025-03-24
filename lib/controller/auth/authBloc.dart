import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/model/auth/user.dart';

abstract class authEvents {

}

class signIn extends authEvents{}


 class authState{
  final UserModel myUser;

  authState(this.myUser);
}

class authBloc extends Bloc<authEvents, authState>{
  authBloc(super.initialState);

}