import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //geo locator
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }


  GoogleMapController? googleMapController;
  CameraPosition? cameraPosition;
  LatLng startLocation = LatLng(23.7806809, 90.407685);
  String location = "Select loaction...";

  MapType _currentMapType = MapType.normal;

  static const pickerWidth = 40.0;
  final isMapDragging = false.obs;

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Future<void> userCurrentLocation() async {
    Position position = await _determinePosition();
    // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    // Placemark place = placemarks[0];
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    googleMapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 20));
  }

  Future<void> fixedLocation() async {
    const newPosition = LatLng(23.7806809, 90.407685);
    googleMapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 20));
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("gMAP"),
          centerTitle: true,
        ),
        body: Stack(
            children:[

              GoogleMap(
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition( //map initial position
                  target: startLocation,
                  zoom: 15.0,
                ),
                mapType: _currentMapType,
                onMapCreated: (controller) {
                  setState(() {
                    googleMapController = controller;
                  });
                },

                //when map is dragging
                onCameraMove: (CameraPosition camPosition) {
                  cameraPosition = camPosition;
                },

                //when map drag stops
                onCameraIdle: () async {
                  List<Placemark> placemarks = await placemarkFromCoordinates(cameraPosition!.target.latitude, cameraPosition!.target.longitude);
                  Placemark place = placemarks[0];
                  setState(() { //get place name from lat and lang
                    location = "${place.street}, ${place.subLocality}, "
                        "${place.administrativeArea}, ${place.postalCode}";
                  });
                },
              ),

              //map marker here
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -(pickerWidth/2)),
                  child: Image.asset("assets/images/map_marker.png", width: pickerWidth,)
                ),
              ),

              const SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(12),
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                        onPressed: _changeMapType,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.map, size: 36, color: Colors.white,)
                    ),

                    const SizedBox(height: 12,),
                    FloatingActionButton(
                        onPressed: userCurrentLocation,
                        backgroundColor: Colors.indigoAccent,
                        child: const Icon(Icons.my_location, size: 36, color: Colors.white,)
                    ),

                    const SizedBox(height: 12,),
                    FloatingActionButton(
                        onPressed: fixedLocation,
                        backgroundColor: Colors.deepOrange,
                        child: const Icon(Icons.add_location, size: 36, color: Colors.white,)
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom:100,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width - 40,
                      child: Obx(()=>
                        ListTile(
                          leading: isMapDragging.value
                              ? CircularProgressIndicator()
                              : Image.asset("assets/images/map_marker.png", width: pickerWidth/1.5,),
                          title:Text(location, style: TextStyle(fontSize: 18),),
                          dense: true,
                        )
                      )
                    ),
                  ),
                )
              )
            ]
        )
    );
  }
}