import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocationtracker/Screens/home.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

Location location = Location();
var currentGroup;

class myMapPage extends StatefulWidget {
  myMapPage({this.groupName,this.groupMembers});
  final String? groupName;
  final List? groupMembers;

  @override
  _myMapPageState createState() => _myMapPageState();
}

class _myMapPageState extends State<myMapPage> {

  late Stream<List<DocumentSnapshot>> stream;
  bool hybridMap =true;
  late StreamSubscription subscription;
  bool mapToggle = false;
  var currentLocation;
  var currentLat;
  var currentLong;
  Set<Marker> _markers = {};
  GoogleMapController? mapController;
  bool focusMode = true;

  BehaviorSubject<double> radius = BehaviorSubject.seeded(100.0);
  late Stream<dynamic> query;
  void initState() {
    super.initState();
    Geolocator().getCurrentPosition().then((loc) {
      setState(() {
        currentLocation = loc;
        mapToggle = true;
        currentLat = loc.latitude;
        currentLong = loc.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    currentGroup = FirebaseFirestore.instance.collection("groupsData").where('groupname', isEqualTo: widget.groupName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
            icon: Icon(Icons.navigate_before,color: Colors.white,),
            onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
            }
        ),
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text("${widget.groupName} ${widget.groupMembers}",style: TextStyle(fontSize: 18,color: Colors.white)
              ,)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height - 160.0,
                  width: double.infinity,
                  child: mapToggle?
                  GoogleMap(
                    zoomGesturesEnabled: true,
                    trafficEnabled: true,
                    mapType: hybridMap==true? MapType.hybrid:MapType.normal,
                    zoomControlsEnabled: true,
                    onMapCreated: _onMapCreated,
                    markers: _markers,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLat,currentLong),
                      zoom: 17,
                    ),
                    myLocationEnabled: true,
                  ):
                  Center(child: Text("Loading..",style: TextStyle(fontSize: 20),),),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                    onPressed: (){
                      setState(() {
                        hybridMap==true? hybridMap=false:hybridMap=true;
                      });
                    }, icon: Icon(Icons.change_circle_outlined,size: 34,color: Colors.black,)
                ),
                Text("   "),
                Container(
                  width: 200,
                  child: Slider(
                    min : 1,
                    max: 5000,
                    divisions: 1000,
                    value: radius.value,
                    //value: _value,
                    label: 'Radius ${radius.value}km',
                    activeColor: Colors.tealAccent,
                    inactiveColor: Colors.blue.withOpacity(0.2),
                    //onChanged: (double value) => changed(value),
                    onChanged: _updateQuery,
                  ),
                ),
                FlatButton(
                  color: Colors.tealAccent,
                  onPressed: (){
                    setState(() {
                      focusMode==true? focusMode=false:focusMode=true;
                    });
                  },
                  child: focusMode==true? Text("Focus mode ON"):Text("Focus mode OFF"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
  double _value =2.0;
  String _label= "Adjust Radius";
  changed(value){
    setState(() {
      _value = value;
      _label = "${_value.toInt().toString()} kms";
      _markers.clear();
      radius.add(value);
    });
  }

  void _onMapCreated(GoogleMapController controller){
    _startQuery();
    location.onLocationChanged.listen((l){
      _updateQuery(radius.value);

      if(focusMode==true){
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: (LatLng(l.latitude!,l.longitude!))
                  ,zoom:13
              )),
        );
        GeoFirePoint myLocation = Geoflutterfire()
            .point(latitude: l.latitude, longitude:l.longitude);
        dbadd(myLocation);
      }

    });

    setState(() {
      mapController = controller;
    });

    stream.listen((List<DocumentSnapshot> documentList) {
      int len = documentList.length;
      _updateMarkers(documentList);
    });
  }

  void dbadd(GeoFirePoint _myLocation) {
    FirebaseFirestore.instance.collection("groupsData").doc(widget.groupName)
        .collection("locations").doc(FirebaseAuth.instance.currentUser.displayName)
        .set({'name': FirebaseAuth.instance.currentUser.displayName,'position': _myLocation.data});
  }

  _startQuery() async{

    var pos = await location.getLocation();
    double lat = pos.latitude;
    double long = pos.longitude;
    var ref = FirebaseFirestore.instance.collection("groupsData").doc(widget.groupName).collection('locations');
    GeoFirePoint center = Geoflutterfire().point(latitude: lat, longitude: long);

    subscription = radius.switchMap((rad){
      return Geoflutterfire().collection(collectionRef: ref).within(
        center: center,
        radius: rad,
        field: 'position',
        strictMode: true,
      );
    }).listen(_updateMarkers);

  }
  _updateQuery(value){
    setState(() {
      radius.add(value);
    });
  }
  _updateMarkers(List<DocumentSnapshot> documentList){
    _markers.clear();
    documentList.forEach((DocumentSnapshot document)  {

      final GeoPoint point = document['position']['geopoint'];
      _addMarker(point.latitude,point.longitude,document['name']);
    });
  }

  _addMarker(lat, long, name){
    _markers.add(
      Marker(markerId: MarkerId(name),infoWindow: InfoWindow(title:name ),
          position: LatLng(lat,long), icon: BitmapDescriptor.defaultMarker,

      ),
    );
  }
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

}
