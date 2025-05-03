import 'package:flutter/material.dart';
import 'package:tour_ease/view/forMidLab/database.dart';
import 'package:tour_ease/view/forMidLab/signIn.dart';
import 'package:tour_ease/view/forMidLab/userDashBoard.dart';

class SignUpForMidLab extends StatefulWidget {
  const SignUpForMidLab({super.key});

  @override
  State<SignUpForMidLab> createState() => _SignUpForMidLabState();
}

class _SignUpForMidLabState extends State<SignUpForMidLab> {
  @override
  Widget build(BuildContext context) {
    String name = "";
    String password = "";
    String role = "";

    return  Scaffold(
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
        Text("Enter user Role" , style: Theme.of(context).textTheme.titleMedium,),
        SizedBox(height: 20,),
          TextField(keyboardType: TextInputType.none,onChanged: (value) {
            role = value;
          },),
        SizedBox(height: 40,),
        
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(onPressed: () {
              print(DataBaseForMidLab.users);
        
              if(name.isEmpty || password.isEmpty){
                return;
              }
              DataBaseForMidLab.users.add({"name":name, "password" : password , "role" : role});
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserdashboardForMidLab(userName: name,userRole: role),));


            }, child: Text("sign up")),
            ElevatedButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SigninLabMid(),));
            }, child: Text(" or Sign in ")),
          ],
        )
            ],
            ),
      ),
    );
  }
}



