import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livelocationtracker/Provider/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:livelocationtracker/Screens/CurrentGroups.dart';
import 'package:livelocationtracker/Screens/searchUserName.dart';
import 'AuthScreen/register.dart';
import 'package:flutter/services.dart';
import 'package:livelocationtracker/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

 final CollectionReference _userDataCollectionReference =
   FirebaseFirestore.instance.collection("userData");
 FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  var locationMessage = "";

  String email=FirebaseAuth.instance.currentUser.email;
  String name=FirebaseAuth.instance.currentUser.displayName;


var _currentPosition;
void getCurrentLocation() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name: prefs.getString('_currentUserName');
    });
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator().getLastKnownPosition();
    print(lastPosition);
    setState(() {
      locationMessage = "$position";
    });
    _currentPosition=position;
    _userDataCollectionReference.doc(auth.currentUser.uid.toString()).
    update(
        {"User location ": _currentPosition.toString()}
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Colors.teal,
          title: Center(child: Text("Welcome back ${FirebaseAuth.instance.currentUser.displayName}")),
          actions: [
            IconButton(onPressed: () {
              //Sign Out User
              AuthClass().signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context)=>RegisterPage()),
                      (route) => false);
            }, icon: Icon(Icons.exit_to_app))
          ]
      ),
      body:
      Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            RaisedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchUserName()));
              },
              child : ListTile(
                leading: Icon(Icons.add,color: Colors.black,size: 20,),
                title: Text("Create new group",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                tileColor: Colors.greenAccent,
              ),
            ),
            SizedBox(height: 30),
            RaisedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> CurrentGroupsPage()));
              },
              child : ListTile(
                //leading: Icon(Icons.add),
                title: Text("     View my groups",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                tileColor: Colors.greenAccent,
              ),
            ),
        ]
      ),
      )
    );
  }
}
