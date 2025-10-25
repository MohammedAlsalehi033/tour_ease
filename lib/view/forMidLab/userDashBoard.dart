import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tour_ease/view/forMidLab/database.dart';

class UserdashboardForMidLab extends StatefulWidget {
  final String userRole;
  final String userName;

  const UserdashboardForMidLab({super.key, required this.userRole, required this.userName});
  @override
  State<UserdashboardForMidLab> createState() => _UserdashboardForMidLabState();
}

class _UserdashboardForMidLabState extends State<UserdashboardForMidLab> {


  @override
  Widget build(BuildContext context) {
    if (widget.userRole == "admin") {
      return  Scaffold(appBar: AppBar(title: Text("admin"),),body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(itemCount:DataBaseForMidLab.avalibleDoctors.length ,itemBuilder: (context, index) {
                return Text(DataBaseForMidLab.avalibleDoctors[index]["name"]);
              },),
            ),
            Expanded(
              child: ListView.builder(itemCount:DataBaseForMidLab.users.length , itemBuilder: (context, index) {
                return Text(DataBaseForMidLab.users[index]["name"]);
              },),
            ),
          ],
        ),
      ),);
    }

    var data = DataBaseForMidLab.appointments.map((element) {
      if (element["name"] == widget.userName) return element;
      else return null;
    },).toList();
    return    Scaffold(appBar: AppBar(title: Text(widget.userName),),body: Container(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(itemCount:DataBaseForMidLab.avalibleDoctors.length ,itemBuilder: (context, index) {
              return Card(child: Column(children: [
                Text("Name: ${DataBaseForMidLab.avalibleDoctors[index]["name"]}"),
                Text("Specialities: ${DataBaseForMidLab.avalibleDoctors[index]["specialities"]}"),
                Text("Free Time: ${DataBaseForMidLab.avalibleDoctors[index]["time"].toString()}"),
                ElevatedButton(onPressed: () {
                  setState(() {
                    DataBaseForMidLab.appointments.add({"name": widget.userName, "doctor" : DataBaseForMidLab.avalibleDoctors[index]["name"], "time": "1:30"          });

                  });
                }, child: Text("Make appointment"))
              ],),);
            },),
          ),
          SizedBox(height: 20,),
          Text("user Appointments"),
          Expanded(
            child: ListView.builder(itemCount: data.length, itemBuilder: (context, index) {

              return Card(child: Column(
                children: [
                  Text("doctor name: ${data[index]?["doctor"]}"),
                  Text("Time: ${data[index]?["time"]}"),
                ],
              ));
            },),
          ),
        ],
      ),
    ),);

  }
}
