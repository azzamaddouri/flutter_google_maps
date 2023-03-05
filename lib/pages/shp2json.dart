import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
class Kml {
  ///FILE 1 OR 2
  Future<Map<PolylineId, Polyline>> loadKML(int numfile) async {
    print("============================LOAD KML==============================");
    final newPolylines = Map<PolylineId, Polyline>.from({});
    final file = await getJson(numfile);
    if (file == null) {
      return newPolylines;
    }

    final data = await parseKML(file).catchError((error) {
      print(error);
      return newPolylines;
    });
    data.forEach((placemarkml) {
      print(placemarkml.coordinates);
    });

    if (data != null) {
      data.forEach((element) {
        PolylineId polylineId = PolylineId(element.id);
        final newPolyline = Polyline(
          polylineId: polylineId,
          points: element.coordinates,
          jointType: JointType.round,
          width: 3,
          color: Colors.blue,
          consumeTapEvents: true,
          onTap: () {
            print('click');
          },
        );
        newPolylines[polylineId] = newPolyline;
      });
      return newPolylines;
    } else {
      return newPolylines;
    }
  }

  Future<String>? getJson(int file) {
    switch (file) {
      case 1:
        return rootBundle.loadString('assets/cable.kml');
        break;
      case 2:
        return rootBundle.loadString('assets/cable.kml');
        break;
      default:
        return null;
    }
  }










  

  Future<List<Placemarkml>> parseKML(String data) async {
    var doc = XmlDocument.parse(data).rootElement;
    if (doc.name.toString() != 'kml') {
      throw ("ERROR: the file is not a KML compatible file");
    }

    List<Placemarkml> resp = [];
    var elements = doc.findAllElements("Placemark");
    int cont = 0;
    elements.forEach((element) {
      cont++;
      String name = element.getElement('name')?.text ?? '';

      String altitudeMode = element
              .getElement('LookAt')
              ?.getElement('gx:altitudeMode')
              ?.text
              .toUpperCase()
              .trim() ??
          '';

      List<LatLng> points = [];
      final coordinates =
          element.findAllElements('coordinates').first.text.trim().split(' ');
      coordinates.forEach((element) {
        final dat = element.toString().split(",");
        double lat = double.parse(dat[1].toString());
        double lng = double.parse(dat[0].toString());
        points.add(LatLng(lat, lng));
      });
      resp.add(Placemarkml(
        id: "Placemark$cont",
        name: name,
        altitudeMode: altitudeMode,
        coordinates: points,
      ));
    });
    return resp;
  }
}

class Placemarkml {
  String id;
  String name;
  String altitudeMode;
  List<LatLng> coordinates;
  bool valid;
  Placemarkml(
      {required this.id,
      required this.name,
      required this.altitudeMode,
      required this.coordinates,
      this.valid = true});
}

class KMLMapWidget extends StatefulWidget {
  @override
  _KMLMapWidgetState createState() => _KMLMapWidgetState();
}

class _KMLMapWidgetState extends State<KMLMapWidget> {
  late GoogleMapController _mapController;
  Map<PolylineId, Polyline> _polylines = {};
  Kml kmm = Kml(); 
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _loadKMLData();
  }

  void _loadKMLData() async {
    Kml kml = Kml();
    Map<PolylineId, Polyline> polylines = await kml.loadKML(1);
    // change file number here
    setState(() {
      _polylines = polylines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(/* GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(),
    zoom: 12,
  )
), */
);
  }
}
