import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
				zoom: 16.0,
			);
		});

		List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];

		int counter = 0;

		steps.forEach((step) {
			decodePolyline(step['polyline']['points'], counter);
			counter++;
		});

		setMarkers();
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

	// Helper function to decode encoded polyline because google web api only returns encoded polyline and not array of coordinates
	void decodePolyline(String str, counter) {
		var index = 0;
		var lat = 0;
		var lng = 0;
		List<LatLng> coordinates = <LatLng>[];
		var shift = 0;
		var result = 0;
		var byte;
		var latitudeChange;
		var longitudeChange;
		var factor = pow(10, 5);

		// Coordinates have variable length when encoded, so just keep
		// track of whether we've hit the end of the string. In each
		// loop iteration, a single coordinate is decoded.
		while (index < str.length) {
			// Reset shift, result, and byte
			byte = null;
			shift = 0;
			result = 0;
			int bitwiseResult;

			do {
				byte = str.codeUnitAt(index++) - 63;
				result |= (byte & 0x1f) << shift;
				shift += 5;
			} while (byte >= 0x20);

			bitwiseResult = (result & 1);

			latitudeChange =
			(bitwiseResult == 1 ? ~(result >> 1) : (result >> 1));

			shift = result = bitwiseResult = 0;

			do {
				byte = str.codeUnitAt(index++) - 63;
				result |= (byte & 0x1f) << shift;
				shift += 5;
			} while (byte >= 0x20);

			bitwiseResult = (result & 1);

			longitudeChange =
			(bitwiseResult == 1 ? ~(result >> 1) : (result >> 1));

			lat += latitudeChange;
			lng += longitudeChange;

			coordinates.add(LatLng(lat / factor, lng / factor));
		}

		setState(() {
			_routes[PolylineId('$counter')] = Polyline(
				polylineId: PolylineId('$counter'),
				points: coordinates,
				color: Colors.blue,
				width: 5,
				startCap: Cap.roundCap,
				endCap: Cap.roundCap,
				jointType: JointType.round);
		});
	}

	getDistance(startLat, startLng, endLat, endLng) {
		var distance = 12742 *
			asin(sqrt(0.5 -
				cos((endLat - startLat) * pi / 180) / 2 +
				cos(startLat * pi / 180) *
					cos(endLat * pi / 180) *
					(1 - cos((endLng - startLng) * pi / 180)) /
					2));

		return distance;
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
}
