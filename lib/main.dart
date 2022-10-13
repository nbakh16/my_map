// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(),
//     );
//   }
// }
//
// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }
//
// class MapSampleState extends State<MapSample>{

//
//   static const double _defaultLat = 23.7341747;
//   static const double _defaultLng = 90.3905615;
//   static const CameraPosition _defaultLocation =
//   CameraPosition(target: LatLng(_defaultLat, _defaultLng), zoom: 12);
//   late final GoogleMapController _googleMapController;
//
//   MapType _currentMapType = MapType.normal;
//   final Set<Marker> _markers = {};
//
//   void _changeMapType() {
//     setState(() {
//       _currentMapType = _currentMapType == MapType.normal
//           ? MapType.satellite
//           : MapType.normal;
//     });
//   }
//
//   Future<void> userCurrentLocation() async {
//     Position position = await _determinePosition();
//     List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//     Placemark place = placemarks[0];
//     LatLng userLocation = LatLng(position.latitude, position.longitude);
//     _googleMapController.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 20));
//     setState(() {
//       final marker = Marker(
//         markerId: MarkerId('userLocation'),
//         position: userLocation,
//         infoWindow: InfoWindow(
//             title: '${place.name}, ${place.postalCode}',
//             snippet: 'Your Location'
//         ),
//       );
//       _markers..clear()..add(marker);
//     });
//   }
//
//   Future<void> _moveToNewLocation() async {
//     const newPosition = LatLng(23.7806809, 90.407685);
//     _googleMapController.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));
//     setState(() {
//       const marker = Marker(
//         markerId: MarkerId('newLocation'),
//         position: newPosition,
//         infoWindow: InfoWindow(
//             title: 'New Place Marker',
//             snippet: 'second marker'
//         ),
//       );
//       _markers..clear()..add(marker);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("gMAP"),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: <Widget>[
//           GoogleMap(
//             onMapCreated: (controller) => _googleMapController = controller,
//             mapType: _currentMapType,
//             initialCameraPosition: _defaultLocation,
//             markers: _markers,
//           ),
//           Container(
//             padding: EdgeInsets.all(12),
//             alignment: Alignment.topRight,
//             child: Column(
//               children: <Widget>[
//                 FloatingActionButton(
//                   onPressed: _changeMapType,
//                   backgroundColor: Colors.green,
//                   child: Text("Change Map Type", style: TextStyle(color: Colors.white),)
//                 ),
//
//                 const SizedBox(height: 20,),
//                 FloatingActionButton(
//                     onPressed: userCurrentLocation,
//                     backgroundColor: Colors.amber,
//                     child: Icon(Icons.my_location, size: 36)
//                 ),
//
//                 const SizedBox(height: 20,),
//                 FloatingActionButton(
//                     onPressed: _moveToNewLocation,
//                     backgroundColor: Colors.blue,
//                     child: Icon(Icons.add_location_alt_sharp, size: 36)
//                 ),
//               ],
//             ),
//           )
//         ]
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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


  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  LatLng startLocation = LatLng(23.7806809, 90.407685);
  String location = "";

  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};

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
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 20));
    // setState(() {
    //   final marker = Marker(
    //     markerId: MarkerId('userLocation'),
    //     position: userLocation,
    //     infoWindow: InfoWindow(
    //         title: '${place.name}, ${place.postalCode}',
    //         snippet: 'Your Location'
    //     ),
    //   );
    //   _markers..clear()..add(marker);
    // });
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
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },

                //when map is dragging
                onCameraMove: (CameraPosition cameraPositiona) {
                  cameraPosition = cameraPositiona;
                },

                //when map drag stops
                onCameraIdle: () async {
                  // Position position = await _determinePosition();
                  // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
                  // LatLng userLocation = LatLng(position.latitude, position.longitude);
                  // mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 20));
                  List<Placemark> placemarks = await placemarkFromCoordinates(cameraPosition!.target.latitude, cameraPosition!.target.longitude);
                  Placemark place = placemarks[0];
                  setState(() { //get place name from lat and lang
                    // location = placemarks.first.administrativeArea.toString() + ", " +  placemarks.first.street.toString();
                    location = "${place.street}, ${place.subLocality}, ${place.administrativeArea}, ${place.postalCode}";
                  });
                },
              ),

              //map marker here
              Center(
                child: Image.asset("assets/images/picker.png", width: 40,),
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
                        child: Text("Change Map Type", style: TextStyle(color: Colors.white),)
                    ),

                    const SizedBox(height: 20,),
                    FloatingActionButton(
                        onPressed: userCurrentLocation,
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.my_location, size: 36)
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
                          child: ListTile(
                            leading: Image.asset("assets/images/picker.png", width: 25,),
                            title:Text(location, style: TextStyle(fontSize: 18),),
                            dense: true,
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