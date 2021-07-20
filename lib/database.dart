import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> userSetup(String displayName) async{
  CollectionReference user = FirebaseFirestore.instance.collection("userData");
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = auth.currentUser.uid;
  String email = auth.currentUser.email;
  String name = displayName.substring(0,1).toUpperCase() + displayName.substring(1);
  //user.add({'Name': displayName, 'uid': uid, 'email': email});
  user.doc(uid).set({'searchKey': displayName.substring(0,1).toUpperCase(),'Name': name, 'uid': uid, 'email': email
  });
  return;
}

Future<void> createGroup(String groupName, List<String>userNames) async{
  CollectionReference group = FirebaseFirestore.instance.collection("groupsData");
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = auth.currentUser.uid;
  group.doc(uid).set({'Group name': groupName, 'Members': userNames});
  //group.add({'Group name': groupName, 'Members': userNames});
}