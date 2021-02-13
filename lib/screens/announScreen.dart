import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/websocketUrl.dart';

class AnnouncementScreen extends StatefulWidget {
  AnnouncementScreen(this.nickname);

  final String nickname;

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  WebSocketChannel channel;
  var location;

  //final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse(URL));
    location = new Location();
    location.onLocationChanged.listen((LocationData currentLocation) {
      LocationData pos = currentLocation;
      channel.sink.add(
          "${widget.nickname}: Lat: ${pos.latitude} Long: ${pos.longitude}");
    });
  }

  bool isLoading = false;

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Announcement Page"),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data.toString(),
                      style: Theme.of(context).textTheme.headline4)
                  : CircularProgressIndicator();
            },
          ),
          // TextField(
          //   controller: controller,
          //   decoration:
          //       InputDecoration(labelText: "Enter your message here"),
          // )
        ],
      )),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });

            LocationData _location = await _determinePosition(context);
            if (_location == null)
              await showDialog<dynamic>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Hey ${widget.nickname}"),
                      content: Text(
                          "Please permit the location so we can help you !"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Ok"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
          }),
    );
  }

  Future<LocationData> _determinePosition(BuildContext ctx) async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      debugPrint("baby");
      if (!_serviceEnabled) {
        await showDialog<dynamic>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Hey ${widget.nickname}"),
                content:
                    Text("Please permit the location so we can help you !"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        await showDialog<dynamic>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Hey ${widget.nickname}"),
                content:
                    Text("Please permit the location so we can help you !"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        return null;
      }
    }
    /*await showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Hey ${widget.nickname}"),
                        content: Text("We are here to help you."),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Ok"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });*/

    _locationData = await location.getLocation();
    return _locationData;
  }

  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permantly denied, we cannot request permissions.');
  //   }

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission != LocationPermission.whileInUse &&
  //         permission != LocationPermission.always) {
  //       return Future.error(
  //           'Location permissions are denied (actual value: $permission).');
  //     }
  //   }

  //   return await Geolocator.getCurrentPosition();
  // }
}
