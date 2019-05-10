import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'map.dart';
import 'page.dart';

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

