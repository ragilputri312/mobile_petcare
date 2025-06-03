import 'package:flutter/material.dart';
import 'petcare_list_screen.dart';

class PetcareDetailScreen extends StatelessWidget {
  final Petcare petcare;

  PetcareDetailScreen({required this.petcare});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.network(
                petcare.imageUrl ??
                    'https://via.placeholder.com/400x240.png?text=No+Image',
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(
                    petcare.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18),
                      SizedBox(width: 4),
                      Text(petcare.location),
                      SizedBox(width: 12),
                      Row(
                        children: List.generate(
                          5,
                          (index) =>
                              Icon(Icons.star, size: 18, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tentang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Layanan yang Mungkin Ditawarkan\n\n'
                    'Sebagai klinik hewan, ${petcare.name} kemungkinan menyediakan layanan seperti:\n\n'
                    '- Konsultasi kesehatan hewan peliharaan (kucing, anjing, dll)\n'
                    '- Pemeriksaan dan pengobatan umum\n'
                    '- Vaksinasi dan sterilisasi\n'
                    '- Penitipan hewan (jika tersedia), toko kebutuhan, dan adopsi\n',
                    style: TextStyle(height: 1.4),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Review',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 4),
                            Text('5.0'),
                            Spacer(),
                            Text('1 Apr'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('"Pelayanan sangat ramah dan profesional!"'),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '- Alex',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Book an appointment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
