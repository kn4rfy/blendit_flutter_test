import 'package:flutter/material.dart';

class TripsView extends StatefulWidget {
  TripsView();

  @override
  TripsState createState() => TripsState();
}

class TripsState extends State<TripsView> {
  List<Widget> _tripsList = <Widget>[
	  Padding(
		  padding: const EdgeInsets.all(20),
		  child: Container(
			  width: 225,
			  child: Padding(
				  padding: const EdgeInsets.all(24),
				  child: Column(
					  crossAxisAlignment: CrossAxisAlignment.end,
					  children: <Widget>[
						  Row(
							  children: <Widget>[
								  Expanded(
									  child: Text(
										  '06',
										  style: TextStyle(
											  fontSize: 20,
											  fontWeight: FontWeight.w900,
											  color: Color(0xFFfe8a7f),
										  ),
									  ),
								  ),
								  Icon(
									  Icons.more_horiz,
									  size: 30,
									  color: Color(0xFFfe8a7f),
								  ),
							  ],
						  ),
						  Text(
								  'April 22-30',
								  style: TextStyle(
									  fontSize: 18,
									  color: Color(0xFF0c63b6),
								  ),
						  ),
						  SizedBox(height: 20),
						  Column(
							  crossAxisAlignment: CrossAxisAlignment.end,
							  children: <Widget>[
								  Text(
									  'Trip from Kutaisi',
									  style: TextStyle(
										  fontSize: 16,
										  fontWeight: FontWeight.bold,
										  color: Color(0xFF0c63b6),
									  ),
								  ),
								  SizedBox(height: 4),
								  Text(
									  'to Barcelona',
									  style: TextStyle(
										  fontSize: 16,
										  fontWeight: FontWeight.bold,
										  color: Color(0xFF0c63b6),
									  ),
								  ),
							  ],
						  ),
					  ],
				  ),
			  ),
			  decoration: BoxDecoration(
				  color: Color(0xFFFFFFFF),
				  borderRadius: BorderRadius.all(Radius.circular(32))),
		  ),
	  ),
  ];

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
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'MENU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0c63b6),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.menu,
                        size: 32,
                        color: Color(0xFF0c63b6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
	          _Trips(),
            Expanded(
                child: Container(
                  child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: _tripsList.length,
              itemBuilder: (BuildContext context, int index) {
                  return _tripsList[index];
              },
            ),
                )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: 0.6,
                        child: Text('Upcoming Trips',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0c63b6),
                            ),
                            textAlign: TextAlign.left),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: FractionalOffset.bottomLeft,
                              child: Text(
                                  'Reservations, Homes, Hotels, Things to Do...',
                                  style: TextStyle(
                                    color: Color(0xFF0c63b6),
                                  ),
                                  textAlign: TextAlign.left),
                            ),
                          ),
                          Expanded(
                            flex: 3,
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Trips extends StatelessWidget {
	const _Trips({
		Key key,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(left: 40, top: 20),
			child: Container(
				child: Padding(
					padding: EdgeInsets.all(40),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							Text(
								'Your Trips',
								style: TextStyle(
									fontSize: 32,
									fontWeight: FontWeight.w900,
									color: Color(0xFF0c63b6),
								),
							),
							Padding(
								padding: const EdgeInsets.only(top: 24),
								child: Row(
									children: <Widget>[
										Container(
											child: Padding(
												padding: EdgeInsets.all(8),
												child: Icon(
													Icons.add_location,
													size: 20,
													color: Color(0xFFFFFFFF),
												),
											),
											decoration: BoxDecoration(
												color: Color(0xFFfe8a7f),
												borderRadius: BorderRadius.circular(36)),
										),
										Padding(
											padding: const EdgeInsets.only(left: 16),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: <Widget>[
													Text(
														'TBLISI',
														style: TextStyle(
															fontSize: 18,
															fontWeight: FontWeight.bold,
															color: Color(0xFF0c63b6),
														),
													),
													Padding(
														padding: EdgeInsets.all(2),
													),
													Text(
														'Current location',
														style: TextStyle(
															fontSize: 15,
															color: Color(0xFF0c63b6),
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
					borderRadius:
					BorderRadius.horizontal(left: Radius.circular(32))),
			),
		);
	}
}

