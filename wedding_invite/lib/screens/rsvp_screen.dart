import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

class RsvpPopup extends StatefulWidget {
  @override
  _RsvpPopupState createState() => _RsvpPopupState();
}

class _RsvpPopupState extends State<RsvpPopup> {
  final nameController = TextEditingController();
  int guestCount = 1;
  bool attending = true;
  bool isLoading = false;

  Future<void> submitRSVP() async {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter your name")),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    String baseUrl = "https://wedding-event-dn6h.onrender.com";

    final response = await http
        .post(
          Uri.parse("$baseUrl/rsvp"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": nameController.text,
            "attending": attending,
            "guests": guestCount,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submitted 💍")),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.body}")),
      );
    }
  } catch (e) {
    print("ERROR: $e");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Server error")),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF6B7A57).withOpacity(0.5), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline, color: Color(0xFF6B7A57), size: 40),
                SizedBox(height: 10),
                Text(
                  "Guest List",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                    fontFamily: 'serif',
                    color: Color(0xFF6B7A57),
                  ),
                ),
                SizedBox(height: 25),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF6B7A57)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF6B7A57), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.group_add_outlined, color: Color(0xFF6B7A57)),
                            SizedBox(width: 8),
                            Expanded( // Allows text to scale down or clip elegantly rather than pushing the layout
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text("Number of Guests", style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(), // Removes default 48px min-width bounds
                            icon: Icon(Icons.remove_circle_outline, color: guestCount > 1 ? Color(0xFF6B7A57) : Colors.grey),
                            onPressed: () {
                              if (guestCount > 1) {
                                setState(() => guestCount--);
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '$guestCount',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B7A57)),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(), // Removes default bounds
                            icon: Icon(Icons.add_circle_outline, color: Color(0xFF6B7A57)),
                            onPressed: () {
                              setState(() => guestCount++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("Attending?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF6B7A57))),
                      ),
                      Switch(
                        activeColor: Colors.white,
                        activeTrackColor: Color(0xFF6B7A57),
                        inactiveThumbColor: Colors.grey.shade400,
                        inactiveTrackColor: Colors.grey.shade200,
                        value: attending,
                        onChanged: (value) {
                          setState(() {
                            attending = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitRSVP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6B7A57),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Color(0xFF6B7A57), strokeWidth: 2),
                          )
                        : Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}