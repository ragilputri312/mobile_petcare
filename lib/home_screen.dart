import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:petcare_tubes/login_screen.dart';
import 'package:petcare_tubes/petcare_list_screen.dart';
import 'package:petcare_tubes/booking_screen.dart';
import 'package:petcare_tubes/profile_page.dart';
import 'chat_screen.dart'; // halaman chatbot kamu
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Mulai dari login dulu
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String nama;
  final String email;

  const HomeScreen({super.key, required this.nama, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final String imageUrl =
      "https://img.pikbest.com/png-images/20250309/cute-pig-cartoon_11584200.png!w700wp";

  final List<Widget> _screens = [
    HomeContent(),
    PetcareListScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? _buildAppBar() : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 231, 232, 231),
                child: Icon(Icons.chat),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen()),
                  );
                },
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFD3EE98),
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.nama,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          Text(
            widget.email,
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }
}

class Klinik {
  final int id;
  final String nama;
  final String deskripsi;
  final String alamat;
  final String? imageUrl;
  final String? rating;

  Klinik({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.alamat,
    this.imageUrl,
    this.rating,
  });

  factory Klinik.fromJson(Map<String, dynamic> json) {
    return Klinik(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      alamat: json['alamat'],
      imageUrl: json['imageurl'],
      rating: json['rating']?.toString(),
    );
  }
}

Future<List<Klinik>> fetchKlinik() async {
  final response = await http.get(
    Uri.parse('https://apipetcare.my.id/api/klinik'),
  );

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((json) => Klinik.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load klinik');
  }
}

class PurchaseHistoryItem {
  final String title;
  final String date;
  final String time;
  final String status;
  final String imageUrl;

  PurchaseHistoryItem({
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.imageUrl,
  });

  factory PurchaseHistoryItem.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryItem(
      title: json['klinik']['nama'] ?? 'Unknown Service',
      date: json['tanggal_pemeriksaan'] ?? 'Unknown Date',
      time: json['jam_pemeriksaan'] ?? 'Unknown Time',
      status: json['status'] ?? 'Unknown Status',
      imageUrl:
          json['klinik']['imageurl'] ??
          'https://img.icons8.com/fluency/96/clinic.png',
    );
  }
}

Future<List<PurchaseHistoryItem>> fetchPurchaseHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');

  final response = await http.get(
    Uri.parse('https://apipetcare.my.id/api/pemesanan/user/$userId'),
  );

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((json) => PurchaseHistoryItem.fromJson(json)).toList();
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception('Gagal memuat histori pemesanan');
  }
}

class HomeContent extends StatelessWidget {
  final String imageUrl =
      "https://img.pikbest.com/png-images/20250309/cute-pig-cartoon_11584200.png!w700wp";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          SizedBox(height: 16),
          _buildPromoBanner(),
          SizedBox(height: 16),
          _buildSectionTitle("Rekomendasi Pengguna"),
          SizedBox(height: 8),
          _buildRecommendationList(),
          _buildSeeMoreButton(context),
          _buildSectionTitle("Histori Pembelian"), // Judul baru
          SizedBox(height: 8),
          _buildPurchaseHistoryList(), // Widget untuk histori pembelian
          SizedBox(height: 16), // Spasi setelah histori pembelian
          _buildArticleCard(
            "Dampak Kebakaran Los Angeles: Pentingnya Persiapan Evakuasi untuk Hewan Peliharaan",
          ),
          _buildArticleCard(
            "Termasuk Hewan yang Daya Ingatnya Kuat, Seberapa Hebat Ingatan Anjing?",
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search...",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        // Gunakan Row untuk menampung beberapa banner
        children: <Widget>[
          // Banner pertama
          Container(
            height: 150,
            width: 300, // Contoh lebar tetap untuk setiap banner
            margin: EdgeInsets.symmetric(horizontal: 8.0), // Spasi antar banner
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Banner kedua
          Container(
            height: 150,
            width: 300,
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Banner Ketiga
          Container(
            height: 150,
            width: 300, // Contoh lebar tetap untuk setiap banner
            margin: EdgeInsets.symmetric(horizontal: 8.0), // Spasi antar banner
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Tambahkan banner lain sesuai kebutuhan
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecommendationList() {
    return FutureBuilder<List<Klinik>>(
      future: fetchKlinik(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Gagal memuat data");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("Tidak ada rekomendasi tersedia");
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  snapshot.data!.map((klinik) {
                    final defaultImage =
                        'https://img.icons8.com/fluency/96/clinic.png';
                    final imageUrl =
                        (klinik.imageUrl == null || klinik.imageUrl!.isEmpty)
                            ? defaultImage
                            : klinik.imageUrl!;

                    return RecommendationCard(
                      imageUrl: imageUrl,
                      title: klinik.nama,
                      rating:
                          klinik.rating ??
                          '0.0', // atau ganti default rating sesuai kebutuhan
                    );
                  }).toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PetcareListScreen()),
          );
        },
        child: Text("See More >"),
      ),
    );
  }

  Widget _buildArticleCard(String title) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget baru untuk menampilkan daftar histori pembelian - Pindahkan ke sini (di dalam class HomeContent)
  Widget _buildPurchaseHistoryList() {
    return FutureBuilder<List<PurchaseHistoryItem>>(
      future: fetchPurchaseHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Gagal memuat histori pembelian");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("Belum ada histori pembelian");
        } else {
          return Column(
            children:
                snapshot.data!.map((item) {
                  return PurchaseHistoryCard(
                    title: item.title,
                    date: item.date,
                    time: item.time,
                    status: item.status,
                    imageUrl: item.imageUrl,
                  );
                }).toList(),
          );
        }
      },
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String rating;

  RecommendationCard({
    required this.imageUrl,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ini adalah 'kotak' untuk gambar
          Container(
            height: 120, // Tinggi tetap untuk gambar
            width: double.infinity, // Lebar sesuai dengan lebar kartu
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: Colors.white, width: 5), // Tambahan ini
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover, // Gambar akan mengisi 'kotak'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text(rating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget baru untuk setiap item histori pembelian
class PurchaseHistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String status;
  final String imageUrl;

  PurchaseHistoryCard({
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '$date, $time',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
