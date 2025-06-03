import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:petcare_tubes/booking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_tubes/home_screen.dart';

class Petcare {
  final int id;
  final String name;
  final String location;
  final bool statusAktif;
  final String imageUrl;
  final String deskripsi;
  final String jam_buka;
  final String jam_tutup;

  Petcare({
    required this.id,
    required this.name,
    required this.location,
    required this.statusAktif,
    required this.imageUrl,
    required this.deskripsi,
    required this.jam_buka,
    required this.jam_tutup,
  });

  factory Petcare.fromJson(Map<String, dynamic> json) {
    return Petcare(
      id: json['id'],
      name: json['nama'] ?? '-',
      location: json['alamat'] ?? '-',
      statusAktif: json['status_aktif'] ?? false,
      imageUrl:
          json['imageurl'] ??
          'https://via.placeholder.com/100x100.png?text=No+Image',
      jam_buka: json['jam_buka'] ?? '08:00', // contoh default jam buka
      jam_tutup: json['jam_tutup'] ?? '17:00',
      deskripsi: json['deskripsi'] ?? '-',
    );
  }
}

class PetcareListScreen extends StatefulWidget {
  @override
  _PetcareListScreenState createState() => _PetcareListScreenState();
}

class _PetcareListScreenState extends State<PetcareListScreen> {
  List<Petcare> petcares = [];
  List<Petcare> filteredPetcares = [];
  bool isLoading = true;
  String errorMessage = '';

  String nama = 'User';
  String email = 'unknown@email.com';

  @override
  void initState() {
    super.initState();
    fetchPetcareData();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString('nama') ?? 'User';
      email = prefs.getString('email') ?? 'unknown@email.com';
    });
  }

  Future<void> fetchPetcareData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://apipetcare.my.id/api/klinik'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Petcare> loadedPetcares =
            jsonData.map((json) => Petcare.fromJson(json)).toList();

        setState(() {
          petcares = loadedPetcares;
          filteredPetcares = loadedPetcares;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data (code: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  void _filterPetcares(String query) {
    final queryLower = query.toLowerCase();
    final filteredList =
        petcares.where((petcare) {
          final nameLower = petcare.name.toLowerCase();
          final locationLower = petcare.location.toLowerCase();
          return nameLower.contains(queryLower) ||
              locationLower.contains(queryLower);
        }).toList();

    setState(() {
      filteredPetcares = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF72BF78),
        title: Text('List Pet Care'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(nama: nama, email: email),
              ),
              (route) => false,
            );
          },
        ),
        actions: [Icon(Icons.more_vert), SizedBox(width: 8)],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: _filterPetcares,
                      decoration: InputDecoration(
                        labelText: 'Search Petcare',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredPetcares.length,
                      itemBuilder: (context, index) {
                        final petcare = filteredPetcares[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PetcareDetailScreen(petcare: petcare),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Image.network(
                                      petcare.imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          petcare.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(petcare.location),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 12,
                                              color:
                                                  petcare.statusAktif
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              petcare.statusAktif
                                                  ? 'Online'
                                                  : 'Offline',
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          PetcareDetailScreen(
                                                            petcare: petcare,
                                                          ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green[700],
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              'Book an appointment',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
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
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

class PetcareDetailScreen extends StatelessWidget {
  final Petcare petcare;

  const PetcareDetailScreen({required this.petcare});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF72BF78),
        title: Text('Detail Pet Care'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            petcare.imageUrl,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported, size: 100),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petcare.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 12),
                Text(petcare.location, style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 14,
                      color: petcare.statusAktif ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      petcare.statusAktif ? 'Online' : 'Offline',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Deskripsi: ${petcare.deskripsi}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Jam Buka: ${petcare.jam_buka}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Jam Tutup: ${petcare.jam_tutup}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BookingScreen(
                          imageUrl: petcare.imageUrl,
                          clinicName: petcare.name,
                          location: petcare.location,
                          clinicId: petcare.id,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Book an appointment',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: PetcareListScreen()));
}
