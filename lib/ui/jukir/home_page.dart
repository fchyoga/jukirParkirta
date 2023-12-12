import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jukirparkirta/bloc/auth_bloc.dart';
import 'package:jukirparkirta/bloc/home_bloc.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_check_response.dart';
import 'package:jukirparkirta/data/message/response/parking/parking_location_response.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jukirparkirta/utils/contsant/app_colors.dart';
import 'package:jukirparkirta/utils/contsant/parking_status.dart';
import 'package:jukirparkirta/utils/contsant/user_const.dart';
import 'package:jukirparkirta/widget/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import 'package:sp_util/sp_util.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePageJukir extends StatefulWidget {
  @override
  _HomePageJukirState createState() => _HomePageJukirState();
}

class _HomePageJukirState extends State<HomePageJukir> {
  late BuildContext _context;
  List<Map<String, dynamic>> parkingData = [];
  String _selectedStatus = 'Penuh';
  List<String> _statusOptions = ['Penuh', 'Terisi Sebagian', 'Kosong'];
  final _loadingDialog = LoadingDialog();
  int? locationId = SpUtil.getInt(LOCATION_ID);
  int? userId = SpUtil.getInt(USER_ID);
  String? userStatus = SpUtil.getString(USER_STATUS);

  Map<String, dynamic> userData = {};

  final ImagePicker _imagePicker = ImagePicker();
  late File _vehicleImage;
  // late String _token;

  bool _isLoading = false;

  late BitmapDescriptor parkIcon;
  late Uint8List customMarker;
  late BitmapDescriptor defaultIcon;
  late BitmapDescriptor myLocationIcon;

  loc.Location _location = loc.Location();
  LatLng? _myLocation;
  Set<Marker> _myLocationMarker = {};
  GoogleMapController? _mapsController;
  List<ParkingLocation> _parkingLocations = [];
  List<Marker> _parkingMarker = [];
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
    fetchUserData();
    super.initState();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body)['data'];
      });
    } else {
      print(response.body);
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  void dispose() {
    _mapsController?.dispose();
    super.dispose();
  }

  Future<Uint8List> _getBytesFromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<void> _loadParkIcon() async {
    parkIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 100),
      'assets/images/park_green.png',
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

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    loc.LocationData? locationData;
    perm.PermissionStatus permissionStatus;

    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle if location service is not enabled
        return;
      }
    }

    permissionStatus = await perm.Permission.locationWhenInUse.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await perm.Permission.locationWhenInUse.request();
      if (permissionStatus.isDenied) {
        // Handle if location permission is not granted
        return;
      }
    }

    // Tambahkan pembaruan lokasi saat posisi berubah
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _myLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _myLocationMarker = <Marker>{
          Marker(
            markerId: const MarkerId('my_location'),
            position: _myLocation!,
            icon: myLocationIcon,
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        };
      });
    });

    locationData = await location.getLocation();
    if (_myLocation == null) return;
    setState(() {
      _myLocation = locationData != null
          ? LatLng(locationData.latitude!, locationData.longitude!)
          : const LatLng(0, 0);
      _myLocationMarker = <Marker>{
        Marker(
          markerId: const MarkerId('my_location'),
          position: _myLocation!,
          icon: myLocationIcon,
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      };
    });

    _mapsController
        ?.animateCamera(CameraUpdate.newLatLngZoom(_myLocation!, 20));
  }

  // void _startLocationUpdates() {
  //   _location.onLocationChanged.listen((loc.LocationData currentLocation) {
  //     setState(() {
  //       _myLocation = LatLng(
  //         currentLocation.latitude!,
  //         currentLocation.longitude!,
  //       );
  //       _myLocationMarker = <Marker>{
  //         Marker(
  //           markerId: MarkerId('my_location'),
  //           position: _myLocation!,
  //           icon: myLocationIcon,
  //           infoWindow: InfoWindow(title: 'My Location'),
  //         ),
  //       };
  //     });
  //   });
  // }

  void _onMapCreated(GoogleMapController controller) {
    _mapsController = controller;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_mapsController != null && _myLocation != null) {
        setState(() {
          _myLocationMarker = <Marker>{
            Marker(
              markerId: const MarkerId('my_location'),
              position: _myLocation!,
              icon: myLocationIcon,
              infoWindow: InfoWindow(title: 'My Location'),
            ),
          };
        });
      }
    });
  }

  Future<void> _showParkingArrivePopup(ParkingUser data) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Parkir Arrive'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID Pelanggan: ${data.idPelanggan}'),
                  Text('Jenis Kendaraan: ${data.jenisKendaraan}'),
                  Text('Nomor Polisi: ${data.nopol}'),
                  Text(
                      'Waktu Parkir: ${DateFormat("dd MMM yy HH:mm").format(data.createdAt)}'),
                  // Tambahkan informasi lain yang ingin ditampilkan
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true; // Tampilkan indikator loading
                    });
                    await _takeVehiclePhoto(
                        data.id); // Mengambil foto kendaraan
                    setState(() {
                      _isLoading =
                          false; // Sembunyikan indikator loading setelah foto diunggah
                    });
                  },
                  icon: _isLoading
                      ? CircularProgressIndicator()
                      : Icon(Icons.camera),
                  label: Text(_isLoading ? 'Loading...' : 'Foto Kendaraan'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                  child: Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _takeVehiclePhoto(int parkingId) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _vehicleImage = File(pickedFile.path);
      });

      // Membuat request multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://parkirta.com/api/retribusi/upload/foto_kendaraan'),
      );

      // Menambahkan header bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Menambahkan field 'parking_id' ke request
      request.fields['id_retribusi_parkir'] = parkingId.toString();

      // Menambahkan file gambar ke request
      request.files.add(await http.MultipartFile.fromPath(
        'foto_kendaraan',
        _vehicleImage.path,
      ));

      try {
        // Mengirim request ke API
        final response = await request.send();

        // Membaca responsenya
        final responseString = await response.stream.bytesToString();
        final responseData = json.decode(responseString);

        // Menangani responsenya
        if (response.statusCode == 200) {
          final data = jsonDecode(responseString);
          updateMarker(parkingId);
          // Menampilkan popup berhasil
          setState(() {
            _isLoading = false; // Sembunyikan indikator loading
          });
          Navigator.of(context).pop(); // Tutup dialog
          _showSuccessPopup(
              parkingId); // Tampilkan popup sukses setelah mengunggah foto
        } else {
          // Menampilkan popup gagal
          _showErrorPopup('Gagal mengunggah foto kendaraan');
        }
      } catch (error) {
        // Menampilkan popup gagal
        _showErrorPopup('Terjadi kesalahan saat mengunggah foto kendaraan');
      }
    }
  }

  void _showSuccessPopup(int parkingId) async {
    Map<String, dynamic>? data;

    try {
      final idUser = await getUserId();
      final dataList = await getParkingData(idUser);
      if (dataList.isNotEmpty) {
        data = dataList.firstWhere((entry) => entry['id'] == parkingId,
            orElse: () => Map<String, dynamic>.from({}));
      }
    } catch (error, stackTrace) {
      debugPrintStack(label: 'Error: $error', stackTrace: stackTrace);
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Berhasil'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Foto kendaraan berhasil diunggah.'),
              SizedBox(height: 10),
              if (data != null) ...[
                Text('ID Pelanggan: ${data['id_pelanggan']}'),
                Text('Jenis Kendaraan: ${data['jenis_kendaraan']}'),
                Text('Nomor Polisi: ${data['nopol']}'),
                Text('Biaya Parkir: ${data['biaya_parkir']['biaya_parkir']}'),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorPopup(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data']['id'];
      return id;
    } else {
      throw Exception('Failed to fetch user ID');
    }
  }

  Future<int> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/profile/detail'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data']['id_lokasi_parkir'];
      return id;
    } else {
      throw Exception('Failed to fetch user ID');
    }
  }

  Future<int> getLocationParkingId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://parkirta.com/api/master/lokasi_parkir'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final locations = data['data'];
      final location = locations.firstWhere(
        (loc) => loc['id'] == userId,
        orElse: () => null,
      );

      if (location != null) {
        final locationId = location['id'];
        return locationId;
      } else {
        throw Exception('No matching location found');
      }
    } else {
      throw Exception('Failed to fetch location parking ID');
    }
  }

  Future<List<Map<String, dynamic>>> getParkingData(int idUser) async {
    final token = SpUtil.getString(API_TOKEN);

    final response = await http.post(
      Uri.parse('https://parkirta.com/api/retribusi/parking/check/jukir'),
      body: jsonEncode({
        'id_jukir': idUser,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parkings = data['data'];
      print('parking $parkings');
      return List<Map<String, dynamic>>.from(parkings);
    } else {
      throw Exception('Failed to fetch parking data');
    }
  }

  void setParkingMarker(List<ParkingUser> data) {
    debugPrint("parking user ${data.length}  ${_parkingMarker.length}");
    var markers = data
        .map((e) => Marker(
              markerId: MarkerId(e.id.toString()),
              position: LatLng(
                double.parse(e.lat),
                double.parse(e.long),
              ),
              icon: e.statusParkir == ParkingStatus.menungguJukir.name
                  ? defaultIcon
                  : parkIcon,
              onTap: () {
                if (e.statusParkir == ParkingStatus.menungguJukir.name)
                  _showParkingArrivePopup(e);
              },
            ))
        .toList();
    _parkingMarker = markers;
    setState(() {
      debugPrint(
          "parking marker ${data.map((e) => "${e.statusParkir} ${e.lat},${e.long}. ")}");
    });
  }

  void updateMarker(int id) {
    var index = _parkingMarker
        .lastIndexWhere((e) => e.markerId == MarkerId(id.toString()));
    _parkingMarker.add(Marker(
        markerId: MarkerId(id.toString()),
        icon: parkIcon,
        position: _parkingMarker[index].position));
    _parkingMarker.removeAt(index);
    setState(() {});
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
      } else if (state is SuccessGetParkingUserState) {
        debugPrint("parking user ${state.data.map((e) => e.toJson())}");
        var activeParking = state.data
            .where((e) => e.statusParkir != ParkingStatus.telahKeluar.name)
            .toList();

        debugPrint("activeParking ${activeParking.map((e) => e.toJson())}");
        if (activeParking.isNotEmpty) setParkingMarker(activeParking);
      } else if (state is SessionExpiredState) {
        showTopSnackBar(
            Overlay.of(_context),
            CustomSnackBar.error(
              message: "Sesi anda telah habis. Silakan login kembali",
            ));
        _context.read<AuthenticationBloc>().authenticationExpiredEvent();
        Navigator.pushNamedAndRemoveUntil(_context, "/", (route) => false);
      } else if (state is ErrorState) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: state.error,
          ),
        );
      }
    }, child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      _context = context;
      return Scaffold(
        backgroundColor: Gray100,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Red500,
          toolbarHeight: 84,
          titleSpacing: 0,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Image.asset(
                  'assets/images/logo-parkirta2.png',
                  height: 40,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                      width: 0.5, color: Colors.white.withOpacity(0.5))),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
                icon: SvgPicture.asset("assets/images/ic_notification.svg",
                    width: 14),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage()), // Navigasi ke halaman profil
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Colors.transparent, // Sesuaikan sesuai kebutuhan
                  backgroundImage: userData['foto_jukir'] != null
                      ? NetworkImage(
                          'https://parkirta.com/storage/uploads/foto/${userData['foto_jukir']}',
                        ) as ImageProvider<
                          Object> // Memberikan tipe ImageProvider<Object>
                      : AssetImage('assets/images/profile.png'),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
            child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-5.143648100120257,
                    119.48282708990482), // Ganti dengan posisi awal peta
                zoom: 20.0,
              ),
              zoomControlsEnabled: false,
              markers:
                  Set<Marker>.from(_parkingMarker).union(_myLocationMarker),
              polylines: _polylines,
              polygons: Set<Polygon>.from(_parkingLocations
                  .where((e) => e.areaLatlong != null)
                  .toList()
                  .map((location) {
                List<String> areaLatLongStrings =
                    location.areaLatlong!.split('},{');
                List<LatLng> polygonCoordinates =
                    areaLatLongStrings.map<LatLng>((areaLatLongString) {
                  String latLngString =
                      areaLatLongString.replaceAll('{', '').replaceAll('}', '');
                  List<String> latLngList = latLngString.split(',');

                  double lat = double.parse(latLngList[0].split(':')[1]);
                  double lng = double.parse(latLngList[1].split(':')[1]);

                  return LatLng(lat, lng);
                }).toList();

                return Polygon(
                  polygonId: PolygonId(location.id.toString()),
                  points: polygonCoordinates,
                  fillColor: Colors.blue.withOpacity(0.3),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                );
              })),
            ),
            Positioned(
                top: 16.0,
                right: 16.0,
                child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.01),
                          blurRadius: 5,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 7),
                        ),
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.09),
                          blurRadius: 3,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.10),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location_outlined,
                      color: AppColors.textPassive,
                    ),
                  ),
                  onTap: () {
                    if (_myLocation != null) {
                      _mapsController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_myLocation!, 20));
                    } else {
                      _getUserLocation();
                    }
                  },
                )),
            userStatus == "Aktif"
                ? Positioned(
                    bottom: 64,
                    left: 30,
                    right: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Status Lokasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Red900,
                              ),
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue!;
                                  context
                                      .read<HomeBloc>()
                                      .updateParkingStatus(newValue);
                                });
                              },
                              items: _statusOptions.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: _selectedStatus == status
                                          ? Red100
                                          : Red500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Red500,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              icon: Icon(Icons.arrow_drop_down, color: Red100),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        )),
      );
    }));
  }
}
