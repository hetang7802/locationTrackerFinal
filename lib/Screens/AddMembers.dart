import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livelocationtracker/Screens/EditMembers.dart';
import 'package:livelocationtracker/Screens/MapPage.dart';


FirebaseAuth auth = FirebaseAuth.instance;
String _userName = auth.currentUser.displayName;
List _userNames = [];
List<String> _selectedUserNames = <String>[];
bool EnteredUsers = false;

List<String> tempSearchStore = [];
var queryResultSet = [];

bool isLoading = false;

class AddMembersPage extends StatefulWidget {
  AddMembersPage({this.Members,this.groupName});
  List? Members;
  String? groupName;
  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {

  @override
  var capitalizedValue = "";

  Widget getListView(){
    var listItems = _userNames;
    var listView = ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context,index){
        return ListTile(
          title: Text(listItems[index]),
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            child: Text(listItems[index][0]),
          ),
          trailing: IconButton(
              icon: Icon(Icons.add,size: 20,),
              onPressed:(){
                setState(() {
                  widget.Members!.add(listItems[index]);
                  _selectedUserNames.add(listItems[index]);
                  _userNames.remove(listItems[index]);
                  FirebaseFirestore.instance.collection("groupsData").doc(widget.groupName).update({'members': widget.Members});
                });
              }
          ),
        );
      },
    );
    return listView;
  }

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        _userNames = [];
      });
    }
    else {
      setState(() {
        capitalizedValue =
            value.substring(0, 1).toUpperCase() + value.substring(1);
      });
    }

    if (queryResultSet.length == 0 && value.length == 1) {
      FirebaseFirestore.instance.collection("userData").
      where('searchKey', isEqualTo: value.substring(0, 1).toUpperCase())
          .get().then((QuerySnapshot doc) {
        // setState(() {
        //   _userNames.add(doc.docs[0].toString());
        // });
        for (int i = 0; i < doc.docs.length; ++i) {
          queryResultSet.add(doc.docs[i].data());
        }
      });
    }
    else {
      tempSearchStore = [];
      _userNames = [];
      queryResultSet.forEach((element) {
        // print("working ${element['Name']} ");
        if (element['Name'].startsWith(capitalizedValue) && _selectedUserNames.contains(element['Name'])==false
                  && widget.Members!.contains(element['Name'])== false
        ) {
          //print("starts with capitalized  value works ${_userName.substring(0,1).toUpperCase()+_userName.substring(1)}  $_userName");
          if(element['Name']!= _userName && element['Name']!={_userName.substring(0,1).toUpperCase()+_userName.substring(1)}){
            setState(() {
              _userNames.add(element['Name']);
            });
          }
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
              backgroundColor: Colors.teal,
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                  child: Center(child: Text("Add members to ${widget.groupName}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)
              ,))),
          ),
          body: isLoading
              ? Center(
              child: CircularProgressIndicator()) :
          SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Center(
                      child: Text("Current members",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                  ),
                  Center(
                    child: Text("\n${widget.Members}",style: TextStyle(fontSize: 18),),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        onChanged: (val) {
                          initiateSearch(val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by user name to add',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0)
                          ),
                          contentPadding: EdgeInsets.only(left: 25.0),
                        ),
                      ),
                    ),
                  ),

                  Divider(thickness: 1.0),
                  SizedBox(
                    child: getListView(),
                    height: 250,
                  ),
                  SizedBox(height: 30),
                  FlatButton(
                    minWidth: 100,
                    color: Colors.greenAccent,
                    child: Text(
                      "Done",
                      style: TextStyle(color: Colors.black,fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: (){
                      FirebaseFirestore.instance.collection("groupsData").doc(widget.groupName).update({'members': widget.Members});
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>myMapPage()));
                    },
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}