import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'page.dart';
import 'map.dart';

class Directions extends Page {
	Directions() : super(const Icon(Icons.map), 'Directions');

	@override
	Widget build(BuildContext context) {
		return const DirectionsBody();
	}
}

class DirectionsBody extends StatefulWidget {
	const DirectionsBody();

	@override
	State<StatefulWidget> createState() => DirectionsBodyState();
}

class DirectionsBodyState extends State<DirectionsBody> {
	DirectionsBodyState();

	static final _googleMapsApiKey = 'AIzaSyBQeUuxhQ3JZKQntndS3_X-L1tIihZVvaI';
	Timer _debounce;
	bool _isLoading = false;
	List<Widget> _placesList = <Widget>[];
	TextEditingController _originController = TextEditingController();
	FocusNode _originFocus = FocusNode();
	String _origin = '';
	bool _isOriginFocused = false;
	TextEditingController _destinationController = TextEditingController();
	FocusNode _destinationFocus = FocusNode();
	String _destination = '';
	bool _isDestinationFocused = false;

	LatLngBounds _bounds;
	CameraPosition _cameraPosition;
	Map<PolylineId, Polyline> _routes = <PolylineId, Polyline>{};

	@override
	void initState() {
		super.initState();
		_originFocus.addListener(onOriginFocusChange);
		_destinationFocus.addListener(onDestinationFocusChange);
	}

	@override
	void dispose() {
		super.dispose();
	}

	void onOriginFocusChange() {
		setState(() {
			_isOriginFocused = _originFocus.hasFocus;
		});
	}

	void onDestinationFocusChange() {
		setState(() {
			_isDestinationFocused = _destinationFocus.hasFocus;
		});
	}

	void onChangeFromLocationInput(value) {
		if (_debounce?.isActive ?? false) _debounce.cancel();

		_debounce = Timer(const Duration(milliseconds: 300), () {
			getPlacesByAutocomplete(value, '_originController');
		});
	}

	void onChangeDestinationLocationInput(value) {
		if (_debounce?.isActive ?? false) _debounce.cancel();

		_debounce = Timer(const Duration(milliseconds: 300), () {
			getPlacesByAutocomplete(value, '_destinationController');
		});
	}

	void getPlacesByAutocomplete(value, fieldName) async {
		setState(() {
			_isLoading = true;
		});

		final response =
		await http.get(
			'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$_googleMapsApiKey');

		if (response.statusCode == 200) {
			generatePlacesList(response.body, fieldName);
		} else {
			setState(() {
				_isLoading = false;
			});
		}
	}

	void generatePlacesList(jsonData, fieldName) {
		Map<String, dynamic> places = json.decode(jsonData);
		List<dynamic> predictions = places["predictions"];

		List<Widget> placeList = <Widget>[];

		predictions.forEach((prediction) {
			debugPrint(prediction['description']);

			placeList.add(
				Padding(
					padding: const EdgeInsets.symmetric(
						vertical: 0, horizontal: 8),
					child: FlatButton(
						child: Text(prediction['description']),
						onPressed: () {
							if (fieldName == '_originController') {
								setState(() {
									_placesList = <Widget>[];
									_originController.text =
									prediction['description'];
									_origin = prediction['description'];
								});

								_originFocus.unfocus();
							} else {
								setState(() {
									_placesList = <Widget>[];
									_destinationController.text =
									prediction['description'];
									_destination = prediction['description'];
								});

								_destinationFocus.unfocus();
							}

							// getCoordinatesByGeocode(prediction['description'], fieldName);
						},
					),
				),
			);
		});

		setState(() {
			_placesList = placeList;
			_isLoading = false;
		});
	}

/*	void getCoordinatesByGeocode(value, fieldName) async {
		final response =
		await http.get(
			'https://maps.googleapis.com/maps/api/geocode/json?address=$value&key=$_googleMapsApiKey');

		if (response.statusCode == 200) {
			setCoordinates(response.body, fieldName);
		} else {
			if (fieldName == '_originController') {
				setState(() {
					_origin = value;
				});
			} else {
				setState(() {
					_destination = value;
				});
			}
		}
	}

	void setCoordinates(data, fieldName) {
		debugPrint('getCoordinatesByGeocode: $data');

		var coordinates = json.decode(data);

		var lat = coordinates['results'][0]['geometry']['location']['lat'];
		var lng = coordinates['results'][0]['geometry']['location']['lng'];

		if (fieldName == '_originController') {
			setState(() {
				_origin = '$lat,$lng';
			});
		} else {
			setState(() {
				_destination = '$lat,$lng';
			});
		}
	}*/

	void getDirections() async {
		setState(() {
			_isLoading = true;
		});

		var origin = _origin;
		var destination = _destination;

		final response =
		await http.get(
			'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$_googleMapsApiKey');

		setState(() {
			_isLoading = false;
		});

		if (response.statusCode == 200) {
			Navigator.push(
				context,
				MaterialPageRoute(
					builder: (context) => MapView(response.body)
				),
			);
		} else {
			ErrorWidget('Error! Please try again.');
		}
	}

//	void processDirectionsData(data) {
//		var directions = json.decode(data);
//
//		setState(() {
//			_bounds = LatLngBounds(
//				northeast: LatLng(
//					directions['routes'][0]['bounds']['northeast']['lat'],
//					directions['routes'][0]['bounds']['northeast']['lng']),
//				southwest: LatLng(
//					directions['routes'][0]['bounds']['southwest']['lat'],
//					directions['routes'][0]['bounds']['southwest']['lng']),
//			);
//
//			_cameraPosition = CameraPosition(
//				target: LatLng(
//					directions['routes'][0]['legs'][0]['start_location']['lat'],
//					directions['routes'][0]['legs'][0]['start_location']['lng']),
//				zoom: 12.0,
//			);
//		});
//
//		List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];
//		String points = '';
//
//		int counter = 0;
//
//		steps.forEach((step) {
//			var startLat = step['start_location']['lat'];
//			var startLng = step['start_location']['lng'];
//			var endLat = step['end_location']['lat'];
//			var endLng = step['end_location']['lng'];
//
//			if(counter == 0){
//				points += '$startLat,$startLng|$endLat,$endLng';
//			} else {
//				points += '|$endLat,$endLng';
//			}
//			counter ++;
//		});
//
//		final PolylineId polylineId = PolylineId(
//			directions['routes'][0]['summary']);
//
//		getSnappedRoutes(points, polylineId);
//	}
//
//	void getSnappedRoutes(path, id) async {
//		final response =
//		await http.get(
//			'https://roads.googleapis.com/v1/snapToRoads?path=$path&interpolate=true&key=$_googleMapsApiKey');
//
//		if (response.statusCode == 200) {
//			setPolylines(response.body, id);
//		} else {
////			_routes[id] = Polyline(
////				polylineId: id,
////				points: path,
////				color: Colors.blue,
////			);
//		}
//	}
//
//	void setPolylines(data, id) {
//		debugPrint('setPolylines $data');
//
//		var snappedRoutes = json.decode(data);
//
//		List<dynamic> snappedPoints = snappedRoutes['snappedPoints'];
//		List<LatLng> points = <LatLng>[];
//
//		snappedPoints.forEach((snappedPoint) {
//			points.add(LatLng(
//				snappedPoint['location']['latitude'], snappedPoint['location']['longitude']));
//		});
//
//		setState(() {
//			_routes[id] = Polyline(
//				polylineId: id,
//				points: points,
//				color: Colors.blue,
//			);
//			_isLoading = false;
//		});
//
//		Navigator.push(
//			context,
//			MaterialPageRoute(
//				builder: (context) => MapView(_bounds, _cameraPosition, _routes)
//			),
//		);
//	}

	@override
	Widget build(BuildContext context) {
		return Column(children: <Widget>[
			!_isOriginFocused && !_isDestinationFocused || _isOriginFocused ?
			Padding(
				padding: EdgeInsets.all(8),
				child: TextField(
					controller: _originController,
					autocorrect: false,
					onChanged: onChangeFromLocationInput,
					focusNode: _originFocus,
					decoration: InputDecoration(
						labelText: 'Starting point',
						hintText: "Search for starting point. Example: Narva, Estonia",
						border: OutlineInputBorder()
					),
				),
			) : Container(),
			!_isOriginFocused && !_isDestinationFocused || _isDestinationFocused
				?
			Padding(
				padding: EdgeInsets.all(8),
				child: TextField(
					controller: _destinationController,
					autocorrect: false,
					onChanged: onChangeDestinationLocationInput,
					focusNode: _destinationFocus,
					decoration: InputDecoration(
						labelText: 'Destination',
						hintText: "Example: Talinn, Estonia",
						border: OutlineInputBorder()
					),
				),
			)
				: Container(),
			_origin != '' && _destination != '' ? Padding(
				padding: const EdgeInsets.symmetric(
					vertical: 0, horizontal: 8),
				child: RaisedButton(
					child: Text('Get Directions'),
					onPressed: getDirections,
				),
			) : Container(),
			_isLoading ? RefreshProgressIndicator() : Expanded(
				child: ListView.builder
					(
					itemCount: _placesList.length,
					itemBuilder: (BuildContext context, int index) {
						return _placesList[index];
					},
				)
			),
		]);
	}
}

