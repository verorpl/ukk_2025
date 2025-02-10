import 'package:flutter/material.dart';
import 'beranda.dart';

final Map<String, String> dummyData = {
  'vero': '123',
};

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _usernameError = '';
  String _passwordError = '';

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _usernameError = '';
      _passwordError = '';
    });

    // Validate empty fields
    if (username.isEmpty && password.isEmpty) {
      setState(() {
        _usernameError = 'Username tidak boleh kosong';
        _passwordError = 'Password tidak boleh kosong';
      });
      return;
    } else if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username tidak boleh kosong';
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password tidak boleh kosong';
      });
      return;
    }

    if (dummyData.containsKey(username) && dummyData[username] == password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: 1, username: username),
        ),
      );
    } else {
      setState(() {
        if (!dummyData.containsKey(username)) {
          _usernameError = 'Username salah';
        } 
        if (dummyData[username] != password) {
          _passwordError = 'Password salah';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo or Image
                Image.network(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoSL4WHG5Ypv4e4W58d5Gt4PnBEM_kZQDDhAKjZAOYLBy6V1karPn2SMil6DFkjUUeX7M&usqp=CAU",
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Color(0xff3a57e8),
                  ),
                ),
                const SizedBox(height: 40),

                // Username Field
                TextField(
                  controller: _usernameController,
                  obscureText: false,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Masukkan Username",
                    hintStyle: const TextStyle(
                      color: Color(0xff9f9d9d),
                    ),
                    filled: true,
                    fillColor: const Color(0xffe0e0e0),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _usernameError.isNotEmpty ? _usernameError : null,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Masukkan Password",
                    hintStyle: const TextStyle(
                      color: Color(0xff9f9d9d),
                    ),
                    filled: true,
                    fillColor: const Color(0xffe0e0e0),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _passwordError.isNotEmpty ? _passwordError : null,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                MaterialButton(
                  onPressed: _login,
                  color: Color(0xff3a57e8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  textColor: Colors.white,
                  height: 50,
                  minWidth: MediaQuery.of(context).size.width,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
