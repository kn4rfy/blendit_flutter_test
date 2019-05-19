import 'package:flutter/material.dart';

class TripsView extends StatefulWidget {
	TripsView();

	@override
	TripsState createState() => TripsState();
}

class TripsState extends State<TripsView> {

	@override
	void initState() {
		super.initState();
	}

	@override
	void dispose() {
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Trips')),
			body: Column(
				children: <Widget>[
					Padding(
						padding: EdgeInsets.fromLTRB(48, 0, 0, 24),
						child: Container(
							child: Padding(
								padding: EdgeInsets.all(48),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment
										.start,
									mainAxisSize: MainAxisSize.min,
									children: <Widget>[
										Text(
											'Your Trips',
											style: TextStyle(
												fontSize: 32,
												fontWeight: FontWeight.bold,
												color: Color(0xFF0c63b6),
											),
										),
										Padding(
											padding: const EdgeInsets.only(
												top: 24),
											child: Row(
												children: <Widget>[
													Container(
														child: Padding(
															padding: EdgeInsets
																.all(8),
															child: Icon(
																Icons
																	.add_location,
																size: 20,
																color: Color(
																	0xFFFFFFFF),
															),
														),
														decoration: BoxDecoration(
															color: Color(
																0xFFfe8a7f),
															borderRadius: BorderRadius
																.circular(36)
														),
													),
													Padding(
														padding: const EdgeInsets
															.only(left: 16),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment
																.start,
															children: <Widget>[
																Text(
																	'TBLISI',
																	style: TextStyle(
																		fontSize: 18,
																		fontWeight: FontWeight
																			.bold,
																		color: Color(
																			0xFF0c63b6),
																	),
																),
																Padding(
																	padding: EdgeInsets.all(2),
																),
																Text(
																	'Current location',
																	style: TextStyle(
																		fontSize: 15,
																		color: Color(
																			0xFF0c63b6),
																	),
																),
															],
														),
													)
												],
											),
										)
									],
								),
							),
							decoration: BoxDecoration(
								color: Color(0xFFFFFFFF),
								borderRadius: BorderRadius.horizontal(
									left: Radius.circular(32))
							),
						),
					),
					Expanded(
						child: ListView(),
					),
					InkWell(
						onTap: () => {},
						child: Container(
							child: Padding(
								padding: EdgeInsets.all(48),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment
										.start,
									mainAxisSize: MainAxisSize.min,
									children: <Widget>[
										Padding(
											padding: EdgeInsets.only(bottom: 48, right: 150),
											child: Text(
												'Upcoming Trips',
												style: TextStyle(
													fontSize: 32,
													fontWeight: FontWeight.bold,
													color: Color(0xFF0c63b6),
												),
												textAlign: TextAlign.left
											),
										),
										Row(
											crossAxisAlignment: CrossAxisAlignment
												.end,
											mainAxisSize: MainAxisSize.min,
											children: <Widget>[
												Expanded(
													child: Text(
														'Reservations, Homes, Hotels, Things to Do...',
														style: TextStyle(
															color: Color(0xFF0c63b6),
														),
														textAlign: TextAlign.left
													),
												),
												Expanded(
													child: Align(
														alignment: FractionalOffset.bottomRight,
														child: Text(
															'SEE MORE',
															style: TextStyle(
																fontWeight: FontWeight.bold,
																color: Color(0xFFfe8a7f),
															),
														),
													),
												)
											],
										),
									],
								),
							),
						),
					),
				],
			),
		);
	}
}
