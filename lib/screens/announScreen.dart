import 'package:disman/constants/websocketUrl.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class AnnouncementScreen extends StatefulWidget {
  AnnouncementScreen(this.nickname);

  final String nickname;

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(URL));

  //final TextEditingController controller = TextEditingController();

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
            LocationData pos = await _determinePosition();
            channel.sink.add(
                "${widget.nickname}: Lat: ${pos.latitude} Long: ${pos.longitude}");
            setState(() {
              isLoading = false;
            });
          }),
    );
  }

  Future<LocationData> _determinePosition() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

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
