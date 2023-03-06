import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoJsonWidget extends StatefulWidget {
  const GeoJsonWidget({Key? key}) : super(key: key);

  @override
  _GeoJsonWidgetState createState() => _GeoJsonWidgetState();
}

class _GeoJsonWidgetState extends State<GeoJsonWidget> {
  List<LatLng> points = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Future<List<LatLng>> fetchGeoJsonData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/geojson'));
    final geojson = jsonDecode(response.body);
    for (final feature in geojson['features']) {
      final geometry = feature['geometry'];
      if (geometry['type'] == 'Point') {
        double latitude = double.parse(geometry['coordinates'][0].toString());
        double longitude = double.parse(geometry['coordinates'][1].toString());
        points.add(LatLng(latitude, longitude));
      }
    }
    print(points);
    return points;
  }

  @override
  void initState() {
    super.initState();
    fetchGeoJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LatLng>>(
      future: fetchGeoJsonData(),
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
              initialCameraPosition: CameraPosition(target: snapshot.data![1]),
              /*  markers: _markers, */
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
