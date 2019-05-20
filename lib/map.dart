import 'dart:async';
import 'dart:convert';

import 'package:blendit_flutter_test/utils.dart' as Utils;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapView extends StatefulWidget {
  final data;

  MapView(this.data);

  @override
  MapState createState() => MapState(data);
}

class MapState extends State<MapView> {
  final data;
  static final _facebookAccessToken =
      '846459692372864|_sg9J80iHsK2QFygsYaTLd-0gDY';

  MapState(this.data);

  CameraPosition _cameraPosition;
  MapType _currentMapType = MapType.normal;
  Map<PolylineId, Polyline> _routes = <PolylineId, Polyline>{};
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();

    processDirectionsData(data);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  // this is where we process the return of getDirections() in directions.dart
  void processDirectionsData(data) {
    var directions = json.decode(data);

    List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];
    List<LatLng> coordinates = <LatLng>[];

    int counter = 0;

    steps.forEach((step) {
      coordinates.addAll(Utils.decodePolyline(step['polyline']['points']));
      counter++;
    });

    setState(() {
      _routes[PolylineId('$counter')] = Polyline(
          polylineId: PolylineId('$counter'),
          points: coordinates,
          color: Colors.blue,
          jointType: JointType.round);
    });

    LatLng center = Utils.getLineCenter(coordinates);

    setState(() {
      _markers[MarkerId('start')] = Marker(
        markerId: MarkerId('start'),
        position: LatLng(coordinates[0].latitude, coordinates[0].longitude),
        infoWindow: InfoWindow(title: 'Start', snippet: 'Start of route'),
        icon: BitmapDescriptor.defaultMarkerWithHue(210.0),
      );
      _markers[MarkerId('center')] = Marker(
        markerId: MarkerId('center'),
        position: center,
        infoWindow: InfoWindow(title: 'Center', snippet: 'Center of route'),
        icon: BitmapDescriptor.defaultMarkerWithHue(210.0),
      );
      _markers[MarkerId('end')] = Marker(
        markerId: MarkerId('end'),
        position: LatLng(coordinates[coordinates.length - 1].latitude,
            coordinates[coordinates.length - 1].longitude),
        infoWindow: InfoWindow(title: 'End', snippet: 'End of route'),
        icon: BitmapDescriptor.defaultMarkerWithHue(210.0),
      );
      _cameraPosition = CameraPosition(
        target: center,
      );
    });

    getRestaurants(center.latitude, center.longitude);
  }

  // Use facebook web place search api for getting restaurants in a specific location
  void getRestaurants(latitude, longitude) async {
    final response = await http.get(
        'https://graph.facebook.com/search?type=place&center=$latitude,$longitude&distance=20000&categories=["FOOD_BEVERAGE"]&fields=name,location,engagement&access_token=$_facebookAccessToken');

    if (response.statusCode == 200) {
      setMarkers(response.body);
    }
  }

  void setMarkers(data) {
    var results = json.decode(data);
    List<dynamic> restaurants = results['data'];

    int counter = 0;

    for (counter = 0; counter < 9; counter++) {
      final MarkerId markerId = MarkerId('$counter');

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(restaurants[counter]['location']['latitude'],
            restaurants[counter]['location']['longitude']),
        infoWindow: InfoWindow(
            title: restaurants[counter]['name'],
            snippet: restaurants[counter]['engagement']['social_sentence']),
      );

      setState(() {
        _markers[markerId] = marker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: Stack(children: <Widget>[
        GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: _cameraPosition,
          compassEnabled: true,
          minMaxZoomPreference: MinMaxZoomPreference(7.0, null),
          mapType: _currentMapType,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          myLocationEnabled: false,
          polylines: Set<Polyline>.of(_routes.values),
          markers: Set<Marker>.of(_markers.values),
          onCameraMove: updateCameraPosition,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _onMapTypeButtonPressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.green,
              child: const Icon(Icons.map, size: 36.0),
            ),
          ),
        ),
      ]),
    );
  }

  Completer<GoogleMapController> _googleMapControllerCompleter = Completer();

  void onMapCreated(GoogleMapController controller) {
    _googleMapControllerCompleter.complete(controller);
  }

  void updateCameraPosition(CameraPosition position) {
    setState(() {
      _cameraPosition = position;
    });
  }
}
