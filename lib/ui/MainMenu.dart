import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location/model/UserLocation.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  //Map
  double long = 0.0;
  double lat = 0.0;
  double rotation = 0.0;
  Completer<GoogleMapController> _controller = Completer();

  //Marker
  Set<Marker> markers = Set();

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static CameraPosition _kLake = CameraPosition(
      //bearing: 192.8334901395799,
      target: LatLng(0.0, 0.0),
      //tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    Firestore.instance.collection('users').document('rangga').snapshots().listen((onData) {
      setState(() {
        lat = double.parse(onData.data["lat"]);
        long = double.parse(onData.data["long"]);
        rotation = double.parse(onData.data["rotation"]);

        _kLake = CameraPosition(
            //bearing: 192.8334901395799,
            target: LatLng(long, lat),
            //tilt: 59.440717697143555,
            zoom: 19
        );

        _goToTheLake();

        _addMarker();
      });
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //Location
    var userLocation = Provider.of<UserLocation>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location by Rangga Saputra"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        markers: markers,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future _addMarker() async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/images/car.png', 50);

    InfoWindow infoWindow = InfoWindow(
        title: "Lokasi : Belum di kasi nama"
    );

    Marker marker = Marker(
      markerId: MarkerId(markers.length.toString()),
      infoWindow: infoWindow,
      position: LatLng(
        long,
        lat
      ),
      //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      rotation: rotation,
    );

    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }
}