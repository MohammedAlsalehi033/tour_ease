import 'package:tour_ease/model/auth/user.dart';
import 'package:http/http.dart' as http;

abstract class UserRepo {
  User fetchUser();
  Future<http.Response> createUser(User user);
}

class UserRepoFireBase extends UserRepo {

  @override
  User fetchUser() {

    return  new User()..updateUser(
      id: 'firebase_user_123',
      userName: 'firebase_user',
      email: 'firebase@example.com',
      mediaUrls: ['url1', 'url2'],
      accountStatus: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),);
  }

  @override
  Future<http.Response> createUser(User user) async {
    const apiUrl = 'https://your-api-endpoint.com/createuser';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': "mohmamed",
        'password': "hello",
      },
    );

    return response;
  }


}

