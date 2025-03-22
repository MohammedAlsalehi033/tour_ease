import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tour_ease/controller/auth/JWTController.dart';

import 'package:tour_ease/model/auth/user.dart';
import 'package:http/http.dart' as http;

abstract class UserRepo {
  UserModel fetchUser();
  Future<http.Response> createUser(UserModel user);
}

class UserRepoFireBase extends UserRepo {


  @override
  Future<http.Response> createUser(UserModel user) async {
    print(user.toString());
    const apiUrl = 'http://10.0.2.2:3000/api/createUser';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id": user.id,
        "username": user.email,
        "email": user.email,
      }),
    );

    return response;
  }

  @override
  UserModel fetchUser() {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }

}

