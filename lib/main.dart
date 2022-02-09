// ignore_for_file: prefer_final_fields, prefer_const_constructors, unused_field, unnecessary_new, prefer_collection_literals, unused_local_variable, curly_braces_in_flow_control_structures

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool pageLoading = false;
  bool zoomed = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getmarkers();

      test();
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  late GoogleMapController mapController; //contrller for Google map
  Set<Marker> markers = new Set(); //markers for google map
  Set<Marker> cmarkers = new Set();
  static LatLng showLocation = LatLng(27.7089427, 85.3086209);
  CameraPosition? dummydata;

  List<LatLng> locations = [
    LatLng(27.7099126, 85.3132563),
    LatLng(27.7139876, 85.314567),
    LatLng(27.7137735, 85.315626),
  ];
  List<GlobalKey> previewContainer = [];
  void test() {
    previewContainer
        .addAll(List.generate(markers.length, (index) => GlobalKey()));
  }

  Set<Marker> getmarkers() {
    //markers to place on map
    setState(() {
      markers.add(Marker(
        //add first marker
        markerId: MarkerId(1.toString()),
        position: LatLng(27.7099126, 85.3132563), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title First ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker(
        // add second marker
        markerId: MarkerId(2.toString()),
        position: LatLng(27.7139876, 85.314567), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Second ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker(
        //add third marker
        markerId: MarkerId(3.toString()),
        position: LatLng(27.7137735, 85.315626), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Third ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
      //add more markers here
    });
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        ListView.builder(
            itemCount: markers.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                key: previewContainer[index],
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.red,
                  child: Text('$index'),
                ),
              );
            }),
        GoogleMap(
          minMaxZoomPreference: MinMaxZoomPreference(3, 25),
          //Map widget from google_maps_flutter package
          zoomGesturesEnabled: true, //enable Zoom in, out on map
          initialCameraPosition: CameraPosition(
            //innital position in map
            target: showLocation, //initial position
            zoom: 15.0, //initial zoom level
          ),
          myLocationEnabled: true,
          zoomControlsEnabled: false,

          markers: zoomed ? cmarkers : markers, //markers to show on map
          mapType: MapType.normal, //map type
          onCameraIdle: () async {
            var zoomdata = await mapController.getZoomLevel();

            if (zoomdata > 16) {
              setState(() {
                zoomed = true;
              });
              await takeScreenShot();
            } else {
              setState(() {
                zoomed = false;
              });
            }

            // var data = await Utils.capture(_globalKey);
            // setState(() {
            //   bytes2 = data;
            // });

            // print('test');
            // print(await mapController.getZoomLevel());
            // mapController.takeSnapshot();
            // print(await mapController.getScreenCoordinate(dummydata!.target));
            // print(await mapController.getVisibleRegion());
            // mapController
            //     .showMarkerInfoWindow(MarkerId(showLocation.toString()));
          },

          onCameraMove: (data) async {
            setState(() {
              dummydata = data;
            });
          },
          onMapCreated: (controller) {
            //method called when map is created
            setState(() {
              mapController = controller;
            });
          },
        ),
      ]),
    );
  }

  takeScreenShot() async {
    List<Marker> dummy = [];
    int i = 0;
    for (var item in previewContainer) {
      dynamic boundary = item.currentContext!.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      Random random = new Random();
      int randomNumber = random.nextInt(100);

      Marker marker = new Marker(
        icon: BitmapDescriptor.fromBytes(
          pngBytes,
        ),
        markerId: MarkerId(randomNumber.toString()),
        position: locations[i],

        //  dummydata!.target,
        infoWindow: InfoWindow(title: 'test', snippet: 'hey he'),
      );
      dummy.add(marker);

      i++;
    }

    setState(() {
      cmarkers = dummy.toSet();
    });
  }
}
