import 'dart:async';
import 'dart:convert';
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
				zoom: 12.0,
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
		});

		final PolylineId polylineId = PolylineId(
			directions['routes'][0]['summary']);

		getSnappedRoutes(points, polylineId);
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
						minMaxZoomPreference: MinMaxZoomPreference.unbounded,
						mapType: _currentMapType,
						rotateGesturesEnabled: true,
						scrollGesturesEnabled: true,
						tiltGesturesEnabled: true,
						zoomGesturesEnabled: true,
						myLocationEnabled: false,
						polylines: Set<Polyline>.of(_routes.values),
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
