import "package:flutter/material.dart";
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final List<String> code = [];
  void btnClick() {
    print("Click button");
  }

  String randomString(int length) {
    const String _chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(rnd.nextInt(_chars.length)),
      ),
    );
  }

  void CreateCode() {
    setState(() {
      code.add(randomString(6));
    });
    print("Create code: ${code.last}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text("IoT Application")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: CreateCode,
                  icon: Icon(Icons.add),
                  label: Text(
                    'Click to generate',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              ),
              if (code.isNotEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Code', style: TextStyle(fontSize: 18)),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: code.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(child: Text(
                            code[index],
                            style: TextStyle(fontSize: 18, color: Colors.indigo),
                          ))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
