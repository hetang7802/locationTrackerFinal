import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livelocationtracker/Screens/AddMembers.dart';
import 'package:livelocationtracker/Screens/MapPage.dart';

class MemberEditPage extends StatefulWidget {

  MemberEditPage({this.groupName,this.members});
  String? groupName;
  List? members;

  @override
  _MemberEditPageState createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  
  String selectedMember = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Center(
          child: Text(
            "Edit members (${widget.groupName})",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
          ),
        ),
      ),
      body:
      Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height-300,
            width: MediaQuery.of(context).size.width - 20,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: ListView.builder(
                itemCount: widget.members!.length,
                itemBuilder: (context,index){
                    return Padding(padding: EdgeInsets.all(4.0),
                    child: ListTile(
                      title: Text(widget.members![index],style: TextStyle(color: Colors.black,fontSize: 18),
                      ),
                      tileColor: Colors.greenAccent,
                      trailing: IconButton(icon: Icon(Icons.cancel,color: Colors.black,size: 30,),
                        onPressed: (){
                          setState(() {
                            selectedMember =  widget.members![index];
                          });
                          if(selectedMember!=FirebaseAuth.instance.currentUser.displayName){
                            setState(() {
                              widget.members!.remove(selectedMember);
                            });
                            FirebaseFirestore.instance.collection("groupsData").doc(widget.groupName)
                                .update({'members': widget.members});
                            FirebaseFirestore.instance.collection("groupsData").doc(widget.groupName)
                                .collection("locations").doc(selectedMember).delete();
                          }
                          else{
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("cannot remove yourself"),duration: Duration(seconds: 1),
                            ));
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          FlatButton(
            color: Colors.greenAccent,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute
                (builder: (context)=>AddMembersPage(Members: widget.members, groupName: widget.groupName,)));
            },
            child: Text("Click to add member",style: TextStyle(fontSize: 20,color: Colors.black),),
          ),
          SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              Text("      "),
              FloatingActionButton(
                backgroundColor: Colors.teal,
                child: Icon(Icons.done,color: Colors.black,size: 34,),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>myMapPage(groupName:widget.groupName,groupMembers:widget.members)));
                },
              ),
              Text("      ")
            ],
          )
        ],
      ),
    );
  }
}
