import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petcare_tubes/home_screen.dart';

class BookingScreen extends StatefulWidget {
  final String imageUrl;
  final String clinicName;
  final String location;
  final int clinicId;

  BookingScreen({
    required this.imageUrl,
    required this.clinicName,
    required this.location,
    required this.clinicId,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  List<String> timeSlots = [
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking"),
        backgroundColor: Color(0xFF72BF78),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Image.network(
              widget.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinicName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                    SizedBox(width: 4),
                    Text(widget.location),
                  ],
                ),
                SizedBox(height: 16),
                _buildDatePicker(),
                SizedBox(height: 16),
                _buildTimeSlots(),
                SizedBox(height: 20),
                _buildBookingButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Pilih Tanggal:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 30)),
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
          child: Text(
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pilih Waktu:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              timeSlots.map((time) {
                final isSelected = selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
    return Center(
      child: ElevatedButton(
        onPressed: selectedTime == null ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
          backgroundColor: Colors.green[700],
        ),
        child: Text("Booking"),
      ),
    );
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text("Konfirmasi Booking"),
            content: Text(
              "Yakin ingin booking di ${widget.clinicName} pada ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} jam $selectedTime?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _submitBooking();
                },
                child: Text("Yes"),
              ),
            ],
          ),
    );
  }

  Future<void> _submitBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      _showDialog("Gagal", "User belum login.");
      return;
    }

    final now = DateTime.now();
    final tanggalPemesanan =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final tanggalPemeriksaan =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final url = Uri.parse("https://apipetcare.my.id/api/pemesanan");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_user": userId,
        "id_klinik": widget.clinicId,
        "tanggal_pemesanan": tanggalPemesanan,
        "tanggal_pemeriksaan": tanggalPemeriksaan,
        "jam_pemeriksaan": selectedTime,
        "status": "pending",
        "alasan_reject": null,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSuccessDialog();
    } else {
      _showDialog(
        "Gagal",
        "Booking gagal. Coba lagi nanti.\n\n${response.body}",
      );
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('nama');
    final email = prefs.getString('email');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder:
                  (context) => HomeScreen(
                    nama: nama ?? 'User',
                    email: email ?? 'unknown@email.com',
                  ),
            ),
            (route) => false,
          );
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text(
                "Booking Berhasil!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
