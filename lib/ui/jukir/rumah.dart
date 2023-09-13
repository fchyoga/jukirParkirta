import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:jukirparkirta/ui/jukir/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class RumahPageJukir extends StatefulWidget {
  @override
  _RumahPageJukirState createState() => _RumahPageJukirState();
}

class _RumahPageJukirState extends State<RumahPageJukir> {

  bool _isLoading = true;

  late BitmapDescriptor parkIcon;
  late Uint8List customMarker;
  late BitmapDescriptor defaultIcon;
  late BitmapDescriptor myLocationIcon;

  loc.Location _location = loc.Location();
  LatLng _myLocation = LatLng(0, 0);
  Set<Marker> _myLocationMarker = {};
  late GoogleMapController _mapsController;
  List<dynamic>? _parkingLocations;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadParkIcon();
    _fetchParkingLocations();
    _getUserLocation();
  }

  @override
  void dispose() {
    _mapsController.dispose();
    super.dispose();
  }

  Future<Uint8List> _getBytesFromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  void _loadParkIcon() async {
    parkIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 100),
      'assets/images/park.png',
    );

    final Uint8List defaultIconBytes =
        await _getBytesFromAsset('assets/images/park.png');
    final Uint8List myLocationIconBytes =
        await _getBytesFromAsset('assets/images/yourloc.png');
    defaultIcon = BitmapDescriptor.fromBytes(defaultIconBytes);
    myLocationIcon = BitmapDescriptor.fromBytes(myLocationIconBytes);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserLocation() async {
    loc.LocationData? _locationData;
    perm.PermissionStatus _permissionStatus;

    loc.Location location = loc.Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Handle if location service is not enabled
        return;
      }
    }

    _permissionStatus = await perm.Permission.locationWhenInUse.status;
    if (_permissionStatus.isDenied) {
      _permissionStatus = await perm.Permission.locationWhenInUse.request();
      if (_permissionStatus.isDenied) {
        // Handle if location permission is not granted
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _myLocation = _locationData != null
          ? LatLng(_locationData.latitude!, _locationData.longitude!)
          : LatLng(0, 0);
      _myLocationMarker = Set<Marker>.from([
        Marker(
          markerId: MarkerId('my_location'),
          position: _myLocation,
          icon: myLocationIcon,
          infoWindow: InfoWindow(title: 'My Location'),
        ),
      ]);
    });

    // Tambahkan pembaruan lokasi saat posisi berubah
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _myLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _myLocationMarker = Set<Marker>.from([
          Marker(
            markerId: MarkerId('my_location'),
            position: _myLocation,
            icon: myLocationIcon,
            infoWindow: InfoWindow(title: 'My Location'),
          ),
        ]);
      });
    });

    _mapsController.animateCamera(CameraUpdate.newLatLng(_myLocation));
  }

  void _startLocationUpdates() {
    _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _myLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _myLocationMarker = Set<Marker>.from([
          Marker(
            markerId: MarkerId('my_location'),
            position: _myLocation,
            icon: myLocationIcon,
            infoWindow: InfoWindow(title: 'My Location'),
          ),
        ]);
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapsController = controller;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _myLocationMarker = Set<Marker>.from([
          Marker(
            markerId: MarkerId('my_location'),
            position: _myLocation,
            icon: myLocationIcon,
            infoWindow: InfoWindow(title: 'My Location'),
          ),
        ]);
      });
    });
  }

  Future<void> _fetchParkingLocations() async {
    try {
      List<dynamic> locations = await getLocations();
      if (mounted) {
        setState(() {
          _parkingLocations = locations;
        });
      }
    } catch (error) {
      // Handle error fetching parking locations
      print('Error fetching parking locations: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Gray100,
      appBar: AppBar(
        backgroundColor: Red500,
        toolbarHeight: 84,
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Image.asset(
                'assets/images/logo-parkirta2.png',
                height: 40,
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.png'),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(-5.143648100120257, 119.48282708990482), // Ganti dengan posisi awal peta
              zoom: 20.0,
            ),
            markers: _parkingLocations != null
              ? Set<Marker>.from(_parkingLocations!.map((location) => Marker(
                  markerId: MarkerId(location['id'].toString()),
                  position: LatLng(
                    double.parse(location['lat']),
                    double.parse(location['long']),
                  ),
                  icon: defaultIcon,
                ))).union(_myLocationMarker)
              : <Marker>{},
            polylines: _polylines ?? {},
          ),
        ],
      ),
    );
  }
}
