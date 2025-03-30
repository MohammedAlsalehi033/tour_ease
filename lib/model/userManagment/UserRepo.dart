import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/controller/userManagment/JWTController.dart';

import 'package:tour_ease/model/userManagment/user.dart';
import 'package:http/http.dart' as http;

abstract class UserRepo {
  UserModel fetchUser();
  Future<Response> createUser(UserModel user);
}

class UserRepoFireBase extends UserRepo {
final APIService apiService;

  UserRepoFireBase({required this.apiService});

Future<Response> createUser(UserModel user) async {
  const apiUrl = 'http://13.201.19.41:3003/api/createUser';

  try {
    final response = await Dio().post(

      apiUrl,
      data: {
        "id": user.id,
        "username": user.email,
        "email": user.email,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
    return response;
  } on DioError catch (e) {
    print('Dio error during createUser: ${e.message}');
    if (e.response != null) {
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');
    } else {
      print('Request options: ${e.requestOptions}');
    }
    throw e; // Re-throwing the error for the calling function to handle
  } catch (e) {
    print('Unexpected error during createUser: $e');
    throw e;
  }
}

  @override
  UserModel fetchUser() {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }

}

