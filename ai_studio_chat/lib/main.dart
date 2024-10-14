
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Chat Generator',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFEFEF), // Chat background
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: const Color(0xFF075E54),
          secondary: Colors.greenAccent,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Message> messages = [];
  final TextEditingController promptController = TextEditingController();

  Future<void> generateContent(String prompt) async {
    final apiKey = 'YOUR_API_KEY'; // Replace with your actual API key
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final response = await model.generateContent([Content.text(prompt)]);
    final timestamp = DateTime.now();

    setState(() {
      messages.add(Message(content: prompt, isUserMessage: true, timestamp: timestamp));
      messages.add(Message(content: response.text.toString(), isUserMessage: false, timestamp: timestamp));
    });
  }

  void copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void shareContent(String content) {
    Share.share(content);
  }

  void regenerateContent(int index) async {
    if (messages[index].isUserMessage) {
      final prompt = messages[index].content;
      await generateContent(prompt);
    }
  }

  void deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(width: 10),
            const Text('AI Chat' ,style: TextStyle(color: Colors.white),),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search,color: Colors.white,),
            onPressed: () {
              },
          ),
          IconButton(
            icon: const Icon(Icons.copyright_rounded,color: Colors.white),
            onPressed: () {
              // Show information about the app
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text('This is an AI Chat Generator app.'),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF075E54),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF), // Decent background color
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: message.isUserMessage ? const Color(0xFFD1E7DD) : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.content,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              DateFormat('hh:mm a').format(message.timestamp),
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16.0, color: Colors.grey),
                                  onPressed: () {
                                    copyToClipboard(message.content);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, size: 16.0, color: Colors.grey),
                                  onPressed: () {
                                    shareContent(message.content);
                                  },
                                ),
                                if (!message.isUserMessage)
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 16.0, color: Colors.grey),
                                    onPressed: () {
                                      regenerateContent(index);
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16.0, color: Colors.red),
                                  onPressed: () {
                                    deleteMessage(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promptController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: const Color(0xFFD1D1D1), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: const Color(0xFF075E54), width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    color: const Color(0xFF075E54),
                    onPressed: () {
                      final prompt = promptController.text;
                      if (prompt.isNotEmpty) {
                        generateContent(prompt);
                        promptController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String content;
  final bool isUserMessage;
  final DateTime timestamp;

  Message({required this.content, required this.isUserMessage, required this.timestamp});
}
