import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:livelocationtracker/Provider/auth_provider.dart';
import 'package:livelocationtracker/Screens/AuthScreen/login.dart';
import 'package:livelocationtracker/Screens/AuthScreen/verificationPage.dart';
import 'package:livelocationtracker/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';

final CollectionReference _userDataCollectionReference =
FirebaseFirestore.instance.collection("userData");

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController _email= TextEditingController();
  TextEditingController _password= TextEditingController();
  TextEditingController _name =TextEditingController();

  bool isLoading = false;
  bool check = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        backgroundColor: Colors.teal,
      ),

      body: isLoading==false?Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                hintText: "Name",
              ),
            ),
            const SizedBox(height: 30,),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                hintText: "Email",
              ),
            ),

            const SizedBox(height: 30,),

            TextFormField(
              controller: _password,
              decoration: InputDecoration(
                hintText: "Password",
                contentPadding: EdgeInsets.only(left: 4.0),
                suffix: IconButton(
                  icon: Icon(check? Icons.visibility:Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      check == false ? check=true:check=false;
                    });
                  },
                ),
              ),
              obscureText: check==true? false:true,

            ),
            SizedBox(height: 30),
            FlatButton(
              color: Colors.greenAccent,
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('_currentUserName', _name.text);
                AuthClass()
                    .createAccount(name: _name.text.trim(), email: _email.text.trim(), password: _password.text.trim())
                    .then((value) {
                  if(value=="Account Created"){
                    setState(() {
                      isLoading= false;
                      User currentUser = FirebaseAuth.instance.currentUser;
                      currentUser.updateProfile(displayName: _name.text.substring(0,1).toUpperCase()+_name.text.substring(1));
                      userSetup(_name.text);
                    });

                    Navigator.pushAndRemoveUntil(
                        context,

                        MaterialPageRoute(builder: (context)=>VerificationPage()),
                            (route) => false);
                  }
                  else{
                    setState(() {
                      isLoading= false;
                    });
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(value)));
                  }
                });
              },
              child: Text("Create Account",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            ),

            SizedBox(height: 20),
            GestureDetector(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context)=>LoginPage()));
                },
                child: Text("Already have an account? Login")
            ),

          ],
        ),
      ): Center(child: CircularProgressIndicator()),
    );
  }

}




