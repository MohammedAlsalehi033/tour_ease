import 'package:flutter/material.dart';
import 'package:tour_ease/view/forMidLab/database.dart';
import 'package:tour_ease/view/forMidLab/userDashBoard.dart';

class SigninLabMid extends StatefulWidget {
  const SigninLabMid({super.key});

  @override
  State<SigninLabMid> createState() => _SigninLabMidState();
}

class _SigninLabMidState extends State<SigninLabMid> {
  @override
  Widget build(BuildContext context) {
    String name = "";
    String password = "";
    return   Scaffold(
      appBar: AppBar(title: Text("SignUp"),),body: SingleChildScrollView(
      child: Column(children: [      SizedBox(height: 20,),

        Text("enter name" , style: Theme.of(context).textTheme.titleMedium,),
        SizedBox(height: 20,),
        TextField(onChanged: (value) {
          name = value;
        },),
        SizedBox(height: 20,),

        Text("enter password" , style: Theme.of(context).textTheme.titleMedium,),
        SizedBox(height: 20,),
        TextField(keyboardType: TextInputType.none,onChanged: (value) {
          password = value;
        },),
        SizedBox(height: 40,),


        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(onPressed: () {

              if(name.isEmpty || password.isEmpty){
                return;
              }
             var data = DataBaseForMidLab.users.map((e) {
                print(e);
                if(e["name"] == "mohammed"){
                  return e['password'];
                }
              },);

              var role = DataBaseForMidLab.users.map((e) {
                if(e["name"] == "mohammed"){
                  return e['role'];
                }
              },);

              if(data.contains(password)){

                Navigator.push(context, MaterialPageRoute(builder: (context) => UserdashboardForMidLab(userRole: role.contains("admin") ? "admin" : "", userName: name,),));

              }

            }, child: Text("sign in")),
          ],
        )
      ],
      ),
    ),
    );
  }
}
