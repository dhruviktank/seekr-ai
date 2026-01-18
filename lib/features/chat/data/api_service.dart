import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.16:8000"; // Use your IP, not localhost for physical devices

  Future<Map<String, dynamic>> summonAI(String message) async {
    // 1. Get the current user's Firebase ID Token
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");
    
    String? token = await user.getIdToken();

    // 2. Send the POST request to FastAPI
    final response = await http.post(
      Uri.parse("$baseUrl/chat/summon"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Satisfies Task 2 & 5 requirements
      },
      body: jsonEncode({"prompt": message}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("The Void is silent: ${response.statusCode}");
    }
  }
}