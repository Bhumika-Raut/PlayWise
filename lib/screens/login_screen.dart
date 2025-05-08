import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: "testStudent@sheshya.in");
  final TextEditingController _otpController = TextEditingController(text: "123456");
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse("https://sheshya-backend-f4gndddgadfhc3fy.eastus-01.azurewebsites.net/loginByEmailOrPhone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "phone": "",
          "otp": _otpController.text,
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token']; // Extract token
        print("Login successful! Token: $token");
        // Navigate to next screen (we'll add this later)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: "OTP"),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}