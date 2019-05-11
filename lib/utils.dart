import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

// Helper function to decode encoded polyline because google web api only returns encoded polyline and not array of coordinates
decodePolyline(String str) {
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

	return coordinates;
}

getLineCenter(points) {
	var totalDistance = getPolylineLength(points);
	var midpoint = getCenterCoordinate(points, totalDistance);
	return midpoint;
}

getPolylineLength(List<LatLng> points) {
	double distance = 0;

	for (var i = 0; i < points.length - 1; i++) {
		distance += calculateDistance(
			points[i].latitude, points[i].longitude, points[i + 1].latitude,
			points[i + 1].longitude);
	}

	return distance;
}

getCenterCoordinate(List<LatLng> points, totalDistance) {
	double midDistance = totalDistance / 2;
	double distance = 0;
	double subDistance = 0;
	var i;

	for (i = 0; i < points.length - 1; i++) {
		subDistance = calculateDistance(
			points[i].latitude, points[i].longitude, points[i + 1].latitude,
			points[i + 1].longitude);

		if ((subDistance + distance) < midDistance)
			distance += subDistance;
		else
			break;
	}

	subDistance = midDistance - distance;
	var bearing = calculateBearing(
		points[i].latitude, points[i].longitude, points[i + 1].latitude,
		points[i + 1].longitude);
	return calculateCoordinate(
		points[i].latitude, points[i].longitude, bearing, subDistance);
}

// LEGEND:
//
// Degrees to radians:
// $value * pi / 180
//
// Radians to degrees:
// $value * 180 / pi
//
// Earth's diameter in Km. = 12742

calculateDistance(startLat, startLng, endLat, endLng) {
	return 12742 *
		asin(sqrt(0.5 -
			cos((endLat - startLat) * pi / 180) / 2 +
			cos(startLat * pi / 180) *
				cos(endLat * pi / 180) *
				(1 - cos((endLng - startLng) * pi / 180)) /
				2));
}

calculateBearing(startLat, startLng, endLat, endLng) {
	return ((atan2(sin((endLng - startLng) * pi / 180) * cos(endLat * pi / 180),
		cos(startLat * pi / 180) * sin(endLat * pi / 180) -
			sin(startLat * pi / 180) * cos(endLat * pi / 180) *
				cos((endLng - startLng) * pi / 180)) * 180 / pi) + 360) % 360;
}

calculateCoordinate(originLat, originLng, bearing, arcLength) {
	var resultLat = asin(sin(originLat * pi / 180) * cos(arcLength / 12742) +
		cos(originLat * pi / 180) * sin(arcLength / 12742) *
			cos(bearing * pi / 180));
	var resultLng = (originLng * pi / 180) + atan2(
		sin(bearing * pi / 180) * sin(arcLength / 12742) *
			cos(originLat * pi / 180),
		cos(arcLength / 12742) - sin(originLat * pi / 180) * sin(resultLat));

	return new LatLng(resultLat * 180 / pi, resultLng * 180 / pi);
}