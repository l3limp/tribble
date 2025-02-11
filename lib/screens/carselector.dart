import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tribble/blocs/auth_bloc.dart';
import 'package:tribble/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tribble/services/auth_service.dart';

class Car {
  String type, price, image;
  Car({this.type, this.price, this.image});
}

class HomeScreen extends StatefulWidget {
  @override
  Carselector createState() => Carselector();
}

class Carselector extends State<HomeScreen> {
  StreamSubscription<User> loginStateSubscription;
  GoogleMapController _controller;
  int num = 1;
  final authService = AuthService();

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

  @override
  List<Car> cars = [
    Car(type: "Bike", price: "69", image: "bike.png"),
    Car(type: "Sedan", price: "150", image: "standard.png"),
    Car(type: "MiniVan", price: "420", image: "minivan.png"),
    Car(type: "SUV", price: "300", image: "suv.png"),
    Car(type: "Luxury", price: "700", image: "luxury.png"),
    Car(type: "Sports", price: "600", image: "sports.png"),
  ];

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    LatLng coordinates = ModalRoute.of(context).settings.arguments;
    Set<Marker> _createMarker() {
      return {
        Marker(
          markerId: MarkerId("marker"),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(title: 'Your Pickup Location'),
        ),
      };
    }

    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      drawer: Drawer(
          child: ListView(
            children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: StreamBuilder<User>(
                stream: authBloc.currentUser,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/devsoc.png'), fit: BoxFit.fitHeight), color: Colors.white),);
                  print(snapshot.data.photoURL);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(snapshot.data.displayName,
                          style: TextStyle(fontSize: 25.0, color: Colors.black)),
                      SizedBox(
                        height: 7.0,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            snapshot.data.photoURL.replaceFirst('s96', 's400')),
                        radius: 40.0,
                      ),
                      SizedBox(
                        height: 7.0,
                      ),
                      Text(snapshot.data.email,
                          style: TextStyle(fontSize: 10.0, color: Colors.black)),                    ],
                  );
                }),
          ),
              ListTile(
                leading: Icon(Icons.directions_car_rounded),
                title: Text('My Bookings'),
                onTap: () {
                  Navigator.pushNamed(context, '/rentData');
                },
              ),
              Divider(thickness: 1,),
              ListTile(
                leading: Icon(Icons.place_outlined),
                title: Text('Change Pickup Location'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              Divider(thickness: 1,),
              ListTile(
                title: Text('Toggle Map Theme'),
                leading: Icon(Icons.map),
                onTap: () {
                  String map_type = "night";
                  if (num % 2 == 0) {
                    map_type = "night";
                  } else {
                    map_type = "retro";
                  }
                  setState(() {
                    num += 1;
                    getJson('assets/map_styles/$map_type.json').then(setMapStyle);
                  });
                  Navigator.pop(context);
                }),
              Divider(thickness: 1,),
              ListTile(
                leading: Icon(Icons.airplanemode_active),
                title: Text('Book a flight'),
                onTap: () {
                  Navigator.pushNamed(context, '/confirm');
                },
              ),
              Divider(thickness: 1),
              ListTile(
                leading: Icon(Icons.chevron_left),
                title: Text('Go Back'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              Divider(thickness: 1),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {
                authService.logout();
                Navigator.pushNamed(context, '/login');
              },
            ),
        ],
      )),
      body: SafeArea(
        child: StreamBuilder<User>(
          stream: authBloc.currentUser,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            print(snapshot.data.photoURL);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                    child: InkWell(
                      onTap: () => _scaffoldKey.currentState.openDrawer(),
                      child: Container(
                        height: 60.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[800],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu,
                              size: 35,
                              color: Colors.white,
                            ),
                            Spacer(),
                            Text(
                              "${GlobalConfiguration().get("location")}",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    )),
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        compassEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              coordinates.latitude, coordinates.longitude),
                          zoom: 14,
                          tilt: 30,
                          bearing: 20,
                        ),
                        markers: _createMarker(),
                        onMapCreated: mapCreated,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 250.0,
                              child: AnimationLimiter(
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: cars.length,
                                    itemBuilder: (context, index) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        duration: Duration(milliseconds: 600),
                                        child: SlideAnimation(
                                          horizontalOffset:
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                          child: FadeInAnimation(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/timeselect');
                                                GlobalConfiguration()
                                                    .updateValue("type",
                                                        cars[index].type);
                                                GlobalConfiguration()
                                                    .updateValue("price",
                                                        cars[index].price);
                                                GlobalConfiguration()
                                                    .updateValue("image",
                                                        cars[index].image);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0.0, 10.0, 17.0, 17.0),
                                                width: 200,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  color: Colors.white,
                                                ),
                                                child: Stack(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  children: [
                                                    Positioned(
                                                      bottom: 10.0,
                                                      child: Container(
                                                        height: 100.0,
                                                        width: 150.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black12,
                                                              offset: Offset(
                                                                  7.0, 7.0),
                                                            ),
                                                          ],
                                                          color:
                                                              Colors.grey[100],
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  30.0,
                                                                  20.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "${cars[index].type}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  letterSpacing:
                                                                      1.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      color: Colors.black
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 15.0,
                                                              ),
                                                              Text(
                                                                "₹${cars[index].price}/hr",
                                                                style: TextStyle(
                                                                    fontSize: 21.0,
                                                                    letterSpacing: 1.0,
                                                                    fontWeight:
                                                                        FontWeight.w400,
                                                                    color: Colors.black
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Image(
                                                      height: 110.0,
                                                      width: 200.0,
                                                      image: AssetImage(
                                                          'assets/${cars[index].image}'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
      getJson('assets/map_styles/night.json').then(setMapStyle);
    });
  }

  Future<String> getJson(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }
}
