import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final List<String> codes = [];
  String _esp32MacAddress = 'Waiting...';
  String _statusMessage = '';

  final String esp32Ip = '192.168.4.1';

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

  Future<void> _sendCodeToESP32(String newCode) async {
    setState(() {
      _statusMessage = 'Sending code "$newCode"...';
    });
    try {
      final response = await http.post(
        Uri.parse('http://$esp32Ip/send'),
        body: {'message': newCode},
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = 'Code sent successfully: ${response.body}';
        });
      } else {
        setState(() {
          _statusMessage =
              'Error sending code: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'ESP32 connection error: $e';
      });
    }
  }

  Future<void> _getDataAndMacFromESP32() async {
    setState(() {
      _statusMessage = 'Fetching data and MAC from ESP32...';
    });
    try {
      final response = await http.get(Uri.parse('http://$esp32Ip/getdata'));

      if (response.statusCode == 200) {
        String fullResponse = response.body;
        List<String> parts = fullResponse.split(', ESP32 MAC: ');

        String dataPart = 'No data yet';
        String macPart = 'No MAC available';

        if (parts.isNotEmpty) {
          dataPart = parts[0];
        }
        if (parts.length > 1) {
          macPart = parts[1];
        }

        setState(() {
          _esp32MacAddress = macPart;
          _statusMessage =
              'Data and MAC fetched successfully. \n$dataPart, MAC Address: $macPart';
        });
      } else {
        setState(() {
          _statusMessage =
              'Error fetching data: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection error: $e';
      });
    }
  }

  void createCode() {
    setState(() {
      String newCode = randomString(6);
      codes.add(newCode);

      _sendCodeToESP32(newCode);
    });
    print("Create code: ${codes.last}");
  }

  void removeCode(int index) {
    setState(() {
      codes.removeAt(index);
    });
    print("Removed the code");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("IoT Application"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: createCode,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Create New Code',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _getDataAndMacFromESP32,
                icon: const Icon(Icons.refresh),
                label: const Text('Fetch Data'),
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ESP32 MAC: $_esp32MacAddress',
                style: const TextStyle(fontSize: 16, color: Colors.indigo),
              ),
              const SizedBox(height: 10),
              Text(
                'Status: $_statusMessage',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Divider(height: 30, thickness: 1),
              if (codes.isNotEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'List of Generated Codes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: codes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(9),
                              title: Text(
                                codes[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => removeCode(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
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
