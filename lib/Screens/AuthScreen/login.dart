import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:livelocationtracker/Provider/auth_provider.dart';
import 'package:livelocationtracker/Screens/AuthScreen/register.dart';
import 'package:livelocationtracker/Screens/AuthScreen/reset.dart';

import '../home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _email= TextEditingController();
  TextEditingController _password= TextEditingController();
  bool check = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return
    Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text("Login"),
        ),

        body: isLoading == false ?
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0,3.0,8.0,8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  height: 300,
                  child: Image.asset('images/locationImage.jpg',fit:BoxFit.fitWidth,width: MediaQuery.of(context).size.width,),
                ),
                SizedBox(height: 5,),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 4.0),
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

                FlatButton(
                  color: Colors.greenAccent,
                  onPressed: () {
                    setState(() {
                      isLoading= true;
                    });
                    AuthClass()
                        .signIn(email: _email.text.trim(), password: _password.text.trim())
                        .then((value) {
                      if(value=="Welcome"){
                        setState(() {
                          isLoading= false;
                        });
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context)=>HomePage()),
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
                  child: Text("Login Account",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                ),

                SizedBox(height: 20,),

                GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
                    },
                    child: Text("Don't have an account? Register")
                ),

                const SizedBox(height:20),

                GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ResetPage()));
                    },
                    child: Text("Forgot Password? reset")
                ),
              ],
            ),
          ),
        ):Center(child: CircularProgressIndicator(), ),
      ),
    );
  }
}
