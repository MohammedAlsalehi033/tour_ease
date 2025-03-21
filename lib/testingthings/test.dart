import 'package:flutter/material.dart';

class Lab6 extends StatefulWidget {
  const Lab6({super.key});
  @override
  State<Lab6> createState() => _Lab6State();
}

class _Lab6State extends State<Lab6> {
  String currentImage = "assets/1.jpg";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: (){
              setState(() {
                currentImage = "assets/2.jpg";
              });
            }, child: Text("Change image")),
            Container(
              width: 300,
              height: 200,
             child: Image.network("https://fastly.picsum.photos/id/502/536/354.jpg?hmac=-e-4OQHUZCdO_v_d4XJpFk01dcotMFot4VDE5htgtic"),
            ),
          ],
        ),
      ),
    );
  }
}
