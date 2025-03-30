import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class UserInitializer {

  Future<void> initializeUser() async {
    final dio = Dio();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }


    try {
      final response = await dio.get(
        'http://13.201.19.41:3003/api/getUserById',
        queryParameters: {
          "id": currentUser.uid,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;

        if (responseBody['success'] == true && responseBody['data'] != null) {
          UserModel.fromJson(responseBody['data']);
        } else {
          throw Exception('Failed to fetch user: ${responseBody['message'] ?? "Unknown error"}');
        }
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (error) {
      print("Error initializing user: $error");
      throw Exception('Failed to fetch user: $error');
    }
  }


  

}