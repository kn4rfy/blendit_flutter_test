import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	Completer<GoogleMapController> _controller = Completer();

	static const LatLng _center = const LatLng(59.3471, 26.3593);
	final Set<Marker> _markers = {};
	MapType _currentMapType = MapType.normal;
	LatLng _lastMapPosition = _center;

	void _onMapCreated(GoogleMapController controller) {
		_controller.complete(controller);
	}

	void _onMapTypeButtonPressed() {
		setState(() {
			_currentMapType = _currentMapType == MapType.normal
				? MapType.satellite
				: MapType.normal;
		});
	}

	void _onCameraMove(CameraPosition position) {
		_lastMapPosition = position.target;
	}

	void _onAddMarkerButtonPressed() {
		setState(() {
			_markers.add(Marker(
				// This marker id can be anything that uniquely identifies each marker.
				markerId: MarkerId(_lastMapPosition.toString()),
				position: _lastMapPosition,
				infoWindow: InfoWindow(
					title: 'Really cool place',
					snippet: '5 Star Rating',
				),
				icon: BitmapDescriptor.defaultMarker,
			));
		});
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			home: Scaffold(
				appBar: AppBar(
					title: Text('Maps Sample App'),
					backgroundColor: Colors.green[700],
				),
				body: Stack(
					children: <Widget>[
						GoogleMap(
							onMapCreated: _onMapCreated,
							initialCameraPosition: CameraPosition(
								target: _center,
								zoom: 7.2,
							),
							mapType: _currentMapType,
							markers: _markers,
							onCameraMove: _onCameraMove,
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
						Align(
							alignment: Alignment.topRight,
							child: Column(
								children: <Widget>[
									SizedBox(height: 16.0),
									FloatingActionButton(
										onPressed: _onAddMarkerButtonPressed,
										materialTapTargetSize: MaterialTapTargetSize
											.padded,
										backgroundColor: Colors.green,
										child: const Icon(
											Icons.add_location, size: 36.0),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}