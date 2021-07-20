import 'package:flutter/material.dart';
import 'package:livelocationtracker/Provider/auth_provider.dart';
import 'package:livelocationtracker/Screens/AuthScreen/login.dart';


class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {

  TextEditingController _email= TextEditingController();

  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Reset password",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
      ),

      body: isLoading==false?Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                hintText: "Email",
              ),
            ),

            const SizedBox(height: 30,),


            FlatButton(
              color: Colors.greenAccent,
              onPressed: () {
                setState(() {
                  isLoading= true;
                });
                AuthClass()
                    .resetPassword(email: _email.text.trim(),)
                    .then((value) {
                  if(value=="Email Sent"){
                    setState(() {
                      isLoading= false;
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context)=>LoginPage()),
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
              child: Text("Reset Account",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            ),

            SizedBox(height: 20,),

            GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                },
                child: Text("Already have an account? Login")
            ),

          ],
        ),
      ):Center(child: CircularProgressIndicator()),
    );
  }
}
