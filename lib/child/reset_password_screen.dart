import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text,
        );
        Fluttertoast.showToast(msg: "Password reset email sent");
        Navigator.pop(context); // Navigate back to login screen
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to send password reset email");
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
       
      
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bgimage.jpeg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.srcOver,
            ),
          ),
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Consistent padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0, // Adjust font size as desired
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 50),
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 100,
              ),
              SizedBox(height: 20.0), // Consistent spacing
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0), // Consistent spacing
                    ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Reset Password',
                        style: TextStyle(fontSize: 18.0, color: Colors.white), // Adjust font size as desired
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: Size(double.infinity, 50.0), // Set minimum size
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
