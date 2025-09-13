import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Native Counter Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel(
    'com.example.native_counter_app/counter',
  );
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission().then((_) => _startService());

    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  }

  Future<void> _startService() async {
    try {
      await platform.invokeMethod('startService');
      _getCounter();
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'updateCounter':
        setState(() {
          _counter = call.arguments as int;
        });
        break;
      default:
        throw MissingPluginException();
    }
  }

  Future<void> _getCounter() async {
    int value;
    try {
      value = await platform.invokeMethod('getValue');
    } on PlatformException catch (e) {
      value = 0;
      print("Failed to get value: '${e.message}'.");
    }
    setState(() {
      _counter = value;
    });
  }

  Future<void> _incrementCounter() async {
    try {
      await platform.invokeMethod('increment');
    } on PlatformException catch (e) {
      print("Failed to increment: '${e.message}'.");
    }
  }

  Future<void> _decrementCounter() async {
    try {
      await platform.invokeMethod('decrement');
    } on PlatformException catch (e) {
      print("Failed to decrement: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Counter value from native side:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _decrementCounter,
                  child: const Text('Decrement'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCounter,
              child: const Text('Refresh Value'),
            ),
          ],
        ),
      ),
    );
  }
}
