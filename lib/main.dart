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
  String currentCode = "";
  String esp32MacAddress = 'Waiting';
  String statusMessage = '';

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

  Future<void> sendCodeToESP32(String newCode) async {
    setState(() {
      statusMessage = 'Sending code $newCode';
    });
    try {
      final response = await http.post(
        Uri.parse('http://$esp32Ip/send'),
        body: {'message': newCode},
      );

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = 'Code sent successfully: \n${response.body}';
        });
      } else {
        setState(() {
          statusMessage =
              'Error sending code: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'ESP32 connection error: $e';
      });
    }
  }

  Future<void> _getDataAndMacFromESP32() async {
    setState(() {
      statusMessage = 'Fetching data and MAC from ESP32';
    });
    try {
      final response = await http.get(Uri.parse('http://$esp32Ip/getdata'));

      if (response.statusCode == 200) {
        String fullResponse = response.body;
        List<String> parts = fullResponse.split(',ESP32 MAC: ');

        String dataPart = 'No data yet';
        String macPart = 'No MAC available';

        if (parts.isNotEmpty) {
          dataPart = parts[0];
        }
        if (parts.length > 1) {
          macPart = parts[1];
        }

        setState(() {
          if (parts.length > 1) {
            esp32MacAddress = macPart;
            statusMessage =
                'Fetched successfully. \n$dataPart\nMAC Address: $macPart';
          } else {
            statusMessage = 'Fetched successfully\n $dataPart';
          }
        });
      } else {
        setState(() {
          statusMessage =
              'Error fetching data: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Connection error: $e';
      });
    }
  }

  void createCode() {
    setState(() {
      String newCode = randomString(6);
      currentCode = newCode;

      sendCodeToESP32(newCode);
    });
    print("Create code: ${currentCode}");
  }

  void removeCode() async {
    setState(() {
      currentCode = "";
      esp32MacAddress = "";
    });
    await sendCodeToESP32("");
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
              ElevatedButton.icon(
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
                'ESP32 MAC: $esp32MacAddress',
                style: const TextStyle(fontSize: 16, color: Colors.indigo),
              ),
              const SizedBox(height: 10),
              Text(
                'Status: $statusMessage',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Divider(height: 30, thickness: 1),
              if (currentCode != "")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Generated Code',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 0),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.all(9),
                              title: Text(
                                currentCode,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: removeCode,
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
