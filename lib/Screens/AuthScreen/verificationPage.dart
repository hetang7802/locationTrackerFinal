import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:livelocationtracker/Screens/AuthScreen/login.dart';
import 'package:flutter/material.dart';

final CollectionReference _userDataCollectionReference =
    FirebaseFirestore.instance.collection("userData");
FirebaseAuth auth = FirebaseAuth.instance;
class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  var _currentPosition;
  void getCurrentLocation() async{
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   name: prefs.getString('_currentUserName');
    // });
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator().getLastKnownPosition();
    print(lastPosition);
    // setState(() {
    //   locationMessage = "$position";
    //   //var _currentPosition = "$position";
    // });
    _currentPosition=position;
    _userDataCollectionReference.doc(auth.currentUser.uid.toString()).
    update(
        {"latitude": _currentPosition.latitude,"longitude": _currentPosition.longitude}
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Verification screen")
        ),

        body: Column(
          children: <Widget>[
            Text("You have registered succesfully!! \n now you can login",
              style: TextStyle(fontSize: 35,color: Colors.black54),),
            RaisedButton(
              onPressed: (){
                getCurrentLocation();
                Navigator.push(
                    context, MaterialPageRoute(builder: (context)=>LoginPage()));
              },
              child: Text("Go for login"),
            ),
          ],
        ),
      );
  }
}
