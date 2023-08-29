import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jukirparkirta/color.dart';
import 'package:jukirparkirta/ui/jukir/profile.dart';
import 'package:jukirparkirta/ui/jukir/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
// import 'package:http_parser/http_parser.dart';

class HomePageJukir extends StatefulWidget {
  @override
  _HomePageJukirState createState() => _HomePageJukirState();
}

class _HomePageJukirState extends State<HomePageJukir> {
  List<Map<String, dynamic>> parkingData = [];
  String _selectedStatus = 'Penuh';
  List<String> _statusOptions = ['Penuh', 'Terisi Sebagian', 'Kosong'];

  
  final ImagePicker _imagePicker = ImagePicker();
  late File _vehicleImage;
  // late String _token;

  bool _isLoading = false;


  late BitmapDescriptor parkIcon;
  late Uint8List customMarker;
  late BitmapDescriptor defaultIcon;
  late BitmapDescriptor myLocationIcon;

  loc.Location _location = loc.Location();
  LatLng _myLocation = LatLng(0, 0);
  Set<Marker> _myLocationMarker = {};
  late GoogleMapController _mapsController;
  List<dynamic>? _parkingLocations;
  List<dynamic>? _parkingUser;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadParkIcon();
    _fetchParkingLocations();
    _getUserLocation();
    fetchData();
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

  Future<void> _showParkingArrivePopup(Map<String, dynamic> data) async {
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
                  Text('ID Pelanggan: ${data['id_pelanggan']}'),
                  Text('Jenis Kendaraan: ${data['jenis_kendaraan']}'),
                  Text('Nomor Polisi: ${data['nopol']}'),
                  // Tambahkan informasi lain yang ingin ditampilkan
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true; // Tampilkan indikator loading
                    });
                    await _takeVehiclePhoto(data['id']); // Mengambil foto kendaraan
                    setState(() {
                      _isLoading = false; // Sembunyikan indikator loading setelah foto diunggah
                    });
                  },
                  icon: _isLoading ? CircularProgressIndicator() : Icon(Icons.camera),
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
    final pickedFile = await _imagePicker.getImage(source: ImageSource.camera);
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
          // Menampilkan popup berhasil
          setState(() {
            _isLoading = false; // Sembunyikan indikator loading
          });
          Navigator.of(context).pop(); // Tutup dialog
          _showSuccessPopup(parkingId); // Tampilkan popup sukses setelah mengunggah foto
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
      final userId = await getUserId();
      final locationId = await getLocationParkingId(userId);
      final dataList = await getParkingData(locationId);
      if (dataList.isNotEmpty) {
        data = dataList.firstWhere((entry) => entry['id'] == parkingId, orElse: () => Map<String, dynamic>.from({}));
      }
    } catch (error) {
      print('Error: $error');
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

  Future<void> fetchData() async {
    try {
      final userId = await getUserId();
      final locationId = await getLocationParkingId(userId);
      final data = await getParkingData(locationId);

      setState(() {
        _parkingUser = data;
      });
    } catch (error) {
      print('Error: $error');
    }
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
        (loc) => loc['relasi_jukir'] != null && loc['relasi_jukir'][0]['id_jukir'] == userId,
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

  Future<List<Map<String, dynamic>>> getParkingData(int locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://parkirta.com/api/retribusi/parking/check'),
      body: jsonEncode({
        'id_lokasi_parkir': locationId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parkings = data['data'];
      print('$parkings');
      return List<Map<String, dynamic>>.from(parkings);
    } else {
      throw Exception('Failed to fetch parking data');
    }
  }

  Future<void> _updateParkingStatus(String status) async {
    final url = Uri.parse('https://parkirta.com/api/retribusi/parking/status');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = await getUserId();
    final locationId = await getLocationParkingId(userId);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'id_lokasi_parkir': locationId, 
      'status': status,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Berhasil mengubah status
      print('Status berhasil diperbarui');
    } else {
      // Gagal mengubah status
      print('Gagal memperbarui status');
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
                  MaterialPageRoute(builder: (context) => ProfilePage()), // Navigasi ke halaman profil
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
            markers: _parkingUser != null
              ? Set<Marker>.from(_parkingUser!.map((location) => Marker(
                  markerId: MarkerId(location['id'].toString()),
                  position: LatLng(
                    double.parse(location['lat']),
                    double.parse(location['long']),
                  ),
                  icon: defaultIcon,
                  onTap: () {
                    _showParkingArrivePopup(location);
                  },
                ))).union(_myLocationMarker)
              : <Marker>{},
            polylines: _polylines ?? {},
            polygons: Set<Polygon>.from(_parkingLocations!.map((location) {
              List<String> areaLatLongStrings = location['area_latlong'].split('},{');
              List<LatLng> polygonCoordinates = areaLatLongStrings.map<LatLng>((areaLatLongString) {
                String latLngString = areaLatLongString.replaceAll('{', '').replaceAll('}', '');
                List<String> latLngList = latLngString.split(',');

                double lat = double.parse(latLngList[0].split(':')[1]);
                double lng = double.parse(latLngList[1].split(':')[1]);

                return LatLng(lat, lng);
              }).toList();

              return Polygon(
                polygonId: PolygonId(location['id'].toString()),
                points: polygonCoordinates,
                fillColor: Colors.blue.withOpacity(0.3),
                strokeColor: Colors.blue,
                strokeWidth: 2,
              );
            })),
          ),
          Positioned(
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          _updateParkingStatus(newValue); 
                        });
                      },
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _selectedStatus == status ? Red100 : Red500,
                            ),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Red500,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
          ),
        ],
      ),
    );
  }
}
