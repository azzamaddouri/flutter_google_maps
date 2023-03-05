import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  List<LatLng> points = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Future<List<LatLng>> addKmlToMap() async {
    String kmlString = await rootBundle.loadString('assets/cable.kml');
    var kmlDocument = XmlDocument.parse(kmlString).rootElement;
    var placemarks = kmlDocument.findAllElements("Placemark");
    for (var placemark in placemarks) {
      final coordinates =
          placemark.findAllElements("coordinates").first.text.split(" ");
      for (var coordinate in coordinates) {
        final point = coordinate.toString().split(",");
        double latitude = double.parse(point[0].toString());
        double longitude = double.parse(point[1].toString());
        points.add(LatLng(latitude, longitude));
      }
    }
    return points;
  }

  @override
  void initState() {
    super.initState();
    addKmlToMap();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LatLng>>(
      future: addKmlToMap(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text('No data found');
        } else {
          for (var i = 0; i < snapshot.data!.length; i++) {
            _markers.add(Marker(
                markerId: MarkerId(i.toString()), position: snapshot.data![i]));
            _polylines.add(
              Polyline(
                polylineId: PolylineId(i.toString()),
                points: snapshot.data!,
                color: Colors.blue,
                width: 4,
              ),
            );
          }
          return GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: snapshot.data![1], zoom: 15),
              markers: _markers,
              polylines: _polylines,
              polygons: {
                Polygon(
                    polygonId: PolygonId("1"),
                    points: snapshot.data!,
                    fillColor: Color(0xFF006491).withOpacity(0.2),
                    strokeWidth: 5,
                    strokeColor: Colors.red),
              });
        }
      },
    );
  }
}
// If you wanna verify the result check this :  https://www.spotzi.com/en/about/help-center/how-to-import-a-kml-into-google-maps/