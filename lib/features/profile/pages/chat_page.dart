import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String storeName;

  const ChatPage({super.key, required this.storeName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": controller.text,
        "isUser": true,
      });

      // 🔥 auto reply seller
      messages.add({
        "text": "Terima kasih sudah menghubungi ${widget.storeName}",
        "isUser": false,
      });
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.storeName)),

      body: Column(
        children: [
          // 💬 CHAT LIST
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg["isUser"]
                          ? Colors.orange
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"]
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✏️ INPUT
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}