import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jukirparkirta/bloc/home_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_location_response.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:jukirparkirta/ui/jukir/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:jukirparkirta/widget/loading_dialog.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:typed_data';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class RumahPageJukir extends StatefulWidget {
  @override
  _RumahPageJukirState createState() => _RumahPageJukirState();
}

class _RumahPageJukirState extends State<RumahPageJukir> {
  bool _isLoading = true;
  final _loadingDialog = LoadingDialog();

  late BitmapDescriptor parkIcon;
  late Uint8List customMarker;
  late BitmapDescriptor defaultIcon;
  late BitmapDescriptor myLocationIcon;

  loc.Location _location = loc.Location();
  LatLng _myLocation = LatLng(0, 0);
  Set<Marker> _myLocationMarker = {};
  late GoogleMapController _mapsController;
  List<ParkingLocation> _parkingLocations = [];
  Set<Polyline> _polylines = {};

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _loadParkIcon();
    _getUserLocation();
    super.initState();
  }

  @override
  void dispose() {
    _mapsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(listener: (context, state) async {
      if (state is LoadingState) {
        state.show ? _loadingDialog.show(context) : _loadingDialog.hide();
      } else if (state is SuccessGetParkingLocationState) {
        setState(() {
          _parkingLocations = state.data;
        });
      } else if (state is ErrorState) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: state.error,
          ),
        );
      }
    }, child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      // _context = context;
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
              initialCameraPosition: const CameraPosition(
                target: LatLng(-5.143648100120257,
                    119.48282708990482), // Ganti dengan posisi awal peta
                zoom: 20.0,
              ),
              markers:
                  Set<Marker>.from(_parkingLocations!.map((location) => Marker(
                        markerId: MarkerId(location.id.toString()),
                        position: LatLng(
                          double.parse(location.lat),
                          double.parse(location.long),
                        ),
                        icon: defaultIcon,
                      ))).union(_myLocationMarker),
              polylines: _polylines ?? {},
            ),
          ],
        ),
      );
    }));
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
      _myLocationMarker = <Marker>{
        Marker(
          markerId: MarkerId('my_location'),
          position: _myLocation,
          icon: myLocationIcon,
          infoWindow: InfoWindow(title: 'My Location'),
        ),
      };
    });

    // Tambahkan pembaruan lokasi saat posisi berubah
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _myLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _myLocationMarker = <Marker>{
          Marker(
            markerId: MarkerId('my_location'),
            position: _myLocation,
            icon: myLocationIcon,
            infoWindow: InfoWindow(title: 'My Location'),
          ),
        };
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
}
