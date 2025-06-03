import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person),
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 8),
            Text('AI Chat'),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(12),
              children: [
                _chatBubble(isUser: false, message: 'Halo! Ada yang bisa saya bantu?'),
                _chatBubble(isUser: true, message: 'Ya, saya butuh info petcare.'),
                _chatBubble(isUser: false, message: 'Oke, berikut list petcare yang tersedia.'),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.green[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.yellow),
                  onPressed: () {
                    // Aksi kirim
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble({required bool isUser, required String message}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.yellow[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message),
      ),
    );
  }
}
