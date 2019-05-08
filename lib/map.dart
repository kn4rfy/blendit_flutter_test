import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
	static final _googleMapsApiKey = 'AIzaSyBQeUuxhQ3JZKQntndS3_X-L1tIihZVvaI';

	MapState(this.data);

	LatLngBounds _bounds;
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

	void processDirectionsData(data) {
		var directions = json.decode(data);

		setState(() {
			_bounds = LatLngBounds(
				northeast: LatLng(
					directions['routes'][0]['bounds']['northeast']['lat'],
					directions['routes'][0]['bounds']['northeast']['lng']),
				southwest: LatLng(
					directions['routes'][0]['bounds']['southwest']['lat'],
					directions['routes'][0]['bounds']['southwest']['lng']),
			);

			_cameraPosition = CameraPosition(
				target: LatLng(
					directions['routes'][0]['legs'][0]['start_location']['lat'],
					directions['routes'][0]['legs'][0]['start_location']['lng']),
				zoom: 7.0,
			);
		});

		List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];
		String points = '';

		int counter = 0;

		steps.forEach((step) {
			var startLat = step['start_location']['lat'];
			var startLng = step['start_location']['lng'];
			var endLat = step['end_location']['lat'];
			var endLng = step['end_location']['lng'];

			if (counter == 0) {
				points += '$startLat,$startLng|$endLat,$endLng';
			} else {
				points += '|$endLat,$endLng';
			}
			counter ++;
			
			decodePolyline(step['polyline']['points']);
		});

		final PolylineId polylineId = PolylineId(
			directions['routes'][0]['summary']);

		//getSnappedRoutes(points, polylineId);
	}

	void getSnappedRoutes(path, id) async {
		final response =
		await http.get(
			'https://roads.googleapis.com/v1/snapToRoads?path=$path&interpolate=true&key=$_googleMapsApiKey');

		if (response.statusCode == 200) {
			setPolylines(response.body, id);
		} else {
			ErrorWidget('Error! Please try again.');
		}
	}

	void setPolylines(data, id) {
		debugPrint('setPolylines $data');

		var snappedRoutes = json.decode(data);

		List<dynamic> snappedPoints = snappedRoutes['snappedPoints'];
		List<LatLng> points = <LatLng>[];

		snappedPoints.forEach((snappedPoint) {
			points.add(LatLng(
				snappedPoint['location']['latitude'],
				snappedPoint['location']['longitude']));
		});

		setState(() {
			_routes[id] = Polyline(
				polylineId: id,
				points: points,
				color: Colors.blue,
			);
		});
	}

	void setMarkers() {
		final MarkerId markerId = MarkerId('0');

		final Marker marker = Marker(
			markerId: markerId,
			position: _cameraPosition.target,
			infoWindow: InfoWindow(title: 'Place', snippet: '*'),
		);

		setState(() {
			_markers[markerId] = marker;
		});
	}

	decodePolyline(String str) {
		var index = 0;
		var	lat = 0;
		var	lng = 0;
			List<dynamic> coordinates = <String>[];
		var	shift = 0;
		var	result = 0;
		var	byte;
		var	latitudeChange;
		var	longitudeChange;
		var	factor = pow(10, 5);

		// Coordinates have variable length when encoded, so just keep
		// track of whether we've hit the end of the string. In each
		// loop iteration, a single coordinate is decoded.
		while (index < str.length) {

			// Reset shift, result, and byte
			byte = null;
			shift = 0;
			result = 0;

			do {
				byte = str.codeUnitAt(index++) - 63;
				result |= (byte & 0x1f) << shift;
				shift += 5;
			} while (byte >= 0x20);

			debugPrint('setPolylines $result');

			latitudeChange = ((result & 1) ? ~(result >> 1) : (result >> 1));

			shift = result = 0;

			do {
				byte = str.codeUnitAt(index++) - 63;
				result |= (byte & 0x1f) << shift;
				shift += 5;
			} while (byte >= 0x20);

			longitudeChange = ((result & 1) ? ~(result >> 1) : (result >> 1));

			lat += latitudeChange;
			lng += longitudeChange;

			coordinates.add(LatLng(lat / factor, lng / factor));
		}

		return coordinates;
	}

	@override
	Widget build(BuildContext context) {
		return
			Scaffold(
				appBar: AppBar(title: Text('Map')),
				body: Stack(children: <Widget>[
					GoogleMap(
						onMapCreated: onMapCreated,
						initialCameraPosition: _cameraPosition,
						compassEnabled: true,
						cameraTargetBounds: CameraTargetBounds(_bounds),
						minMaxZoomPreference: MinMaxZoomPreference(7.0, null),
						mapType: _currentMapType,
						rotateGesturesEnabled: true,
						scrollGesturesEnabled: true,
						tiltGesturesEnabled: true,
						zoomGesturesEnabled: true,
						myLocationEnabled: false,
						polylines: Set<Polyline>.of(_routes.values),
						markers: Set<Marker>.of(_markers.values),
					),
					Padding(
						padding: const EdgeInsets.all(16.0),
						child: Align(
							alignment: Alignment.bottomRight,
							child: FloatingActionButton(
								onPressed: _onMapTypeButtonPressed,
								materialTapTargetSize: MaterialTapTargetSize
									.padded,
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
}
