import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livelocationtracker/Screens/CurrentGroups.dart';
import 'package:livelocationtracker/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livelocationtracker/Screens/home.dart';
import 'package:livelocationtracker/Provider/SearchService.dart';
final CollectionReference _userDataCollectionReference =
FirebaseFirestore.instance.collection("userData");

FirebaseAuth auth = FirebaseAuth.instance;
String _userName = auth.currentUser.displayName;
List<String> _userNames = <String>[];
List<String> _selectedUserNames = <String>[];
Map<String,bool> _selectedUserNamesBool = <String,bool>{};
TextEditingController _searchQuery = TextEditingController();
TextEditingController _groupNameController = TextEditingController();
bool EnteredUsers = false;

List<String> tempSearchStore = [];
var queryResultSet = [];

bool isLoading = false;

class SearchUserName extends StatefulWidget {
  const SearchUserName({Key? key}) : super(key: key);

  @override
  _SearchUserNameState createState() => _SearchUserNameState();
}

class _SearchUserNameState extends State<SearchUserName> {

  @override
  var capitalizedValue = "";
  String groupName ="";

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
                  _selectedUserNames.add(listItems[index]);
                  _userNames.remove(listItems[index]);
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
        if (element['Name'].startsWith(capitalizedValue) && _selectedUserNames.contains(element['Name'])==false) {
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
              backgroundColor: Colors.teal,
              automaticallyImplyLeading: true,
              title: Center(child: Text("Make a new group",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)),
              actions: [
                IconButton(onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false);
                }, icon: Icon(Icons.close)
                )
              ]
          ),
          body: isLoading
              ? Center(
              child: CircularProgressIndicator()) :
          SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //Text("your userName: ${auth.currentUser.displayName}"),
                  SizedBox(height: 20),
                  Padding(padding: const EdgeInsets.symmetric(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                            spacing: 6.0,
                            runSpacing: 6.0,
                            children: _selectedUserNames
                                .map((item) => _buildChip(item, Colors.greenAccent))
                                .toList()
                                .cast<Widget>()
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        onChanged: (text){
                          setState(() {
                            groupName=text;
                          });
                        },
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter group name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0)
                          ),
                          contentPadding: EdgeInsets.only(left: 25.0),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        onChanged: (val) {
                          initiateSearch(val);
                        },
                        decoration: InputDecoration(
                          hintText: 'search by user name',
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
                    color: _groupNameController.text.length==0 ? Colors.transparent: Colors.greenAccent,
                    child: Text(
                      "Create Group",
                      style: TextStyle(color: _groupNameController.text.length==0 ? Colors.transparent: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: (){
                      createCollectionGroup();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CurrentGroupsPage()));
                      // groupName= _groupNameController.text;
                      // _selectedUserNamesBool.clear();
                      // createGroup(groupName, _userNames);
                    },
                  )
                ],
              ),
            ),
          )
      ),
    );
  }

  Widget buildResultTile(data) {
    return ListTile(
      title: data['Name'],
    );
  }

  void _deleteSelected(String Label){
    setState(() {
      _selectedUserNames.remove(Label);
    });
    _selectedUserNames.remove(Label);
    _selectedUserNamesBool.update(Label, (value) => false);
    return;
  }

  

  Widget _buildChip(String label, Color color){
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(label[0].toUpperCase()),
      ),
      label: Text(
        label,
        style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
      ),
      onDeleted: () => _deleteSelected(label),
      backgroundColor: color,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }
  
  Future<void> createCollectionGroup() async{
    _selectedUserNames.insert(_selectedUserNames.length, _userName);
    Map<String,dynamic> mapgroups = {
      'groupname': _groupNameController.text,
      'members': _selectedUserNames,
    };
    try{
      await FirebaseFirestore.instance.collection("groupsData").doc(_groupNameController.text)
        .set(mapgroups);
      //await FirebaseFirestore.instance.collection("groupsData").add(mapgroups);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("group created")));
      setState(() {
        _selectedUserNames.clear();
        _selectedUserNamesBool.clear();

      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("failed to create croup $e")));
    }
  }

}


