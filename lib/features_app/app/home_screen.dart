import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final bool firebaseConnected;
  final String? errorMessage;

  const HomeScreen({
    Key? key,
    required this.firebaseConnected,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Sử dụng post-frame callback để hiển thị SnackBar sau khi widget được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = widget.firebaseConnected
          ? "Firebase connected successfully!"
          : "Firebase connection failed: ${widget.errorMessage}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text("Home Screen"),
      ),
    );
  }
}
