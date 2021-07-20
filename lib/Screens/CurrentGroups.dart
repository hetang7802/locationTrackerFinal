import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livelocationtracker/Screens/EditMembers.dart';
import 'package:livelocationtracker/Screens/MapPage.dart';
import 'package:livelocationtracker/Screens/searchUserName.dart';

class CurrentGroupsPage extends StatefulWidget {
  const CurrentGroupsPage({Key? key}) : super(key: key);

  @override
  _CurrentGroupsPageState createState() => _CurrentGroupsPageState();
}

String userName = FirebaseAuth.instance.currentUser.displayName;

class _CurrentGroupsPageState extends State<CurrentGroupsPage> {
  @override

  Stream<QuerySnapshot> cs = FirebaseFirestore.instance
      .collection('groupsData')
      .where('members', arrayContains: userName)
      .snapshots();

  List groups = [];
  var INT  ;
  var selectedGroup ;
  String selectedGroupId = "";
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.teal,
        title: Center(child: Text("Choose a group",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)),
      ),

       body: Container(
         height: MediaQuery.of(context).size.height,
         child: Column(
           children: [
             SingleChildScrollView(
               child: Container(
                 height: 615,
                 child: StreamBuilder<QuerySnapshot>(
                  stream: cs,
                  //stream: FirebaseFirestore.instance.collection('groupsData').snapshots(),

                  builder: (context,snapshot){
                    if(!snapshot.hasData){
                      return Center(
                          child: Text("no groups yet :(",style: TextStyle(fontSize: 20),));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        String itemTitle = snapshot.data!.docs[index]['groupname'];
                        var subTitle = snapshot.data!.docs[index]['members'];
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                selectedGroup=FirebaseFirestore.instance.collection("groupsData").where('groupname', isEqualTo: itemTitle);
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>myMapPage(groupName: itemTitle,groupMembers: subTitle,)));

                            },
                            child: Card(
                              child: ListTile(
                                title: Text(itemTitle,style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                                tileColor: Colors.greenAccent,
                                subtitle: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(subTitle.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.greenAccent[600]),
                                  )
                                ),
                                trailing: IconButton(icon:Icon(Icons.edit),color: Colors.grey[800],
                                  onPressed: (){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context)=>MemberEditPage(groupName: itemTitle,members: subTitle,)));
                                  },
                                ),
                              ),

                            ),
                          ),
                        );
                      },
                    );
                  },

                 ),
               ),
             ),

             Container(

               height: 65,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   FloatingActionButton(
                   backgroundColor: Colors.greenAccent[400],
                       onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchUserName()));
                       },
                       child: Icon(Icons.add,size: 34,color: Colors.grey[700],),
                    ),
                 ],
               ),
             ),
           ],
         ),
       ),

    );
  }
}
