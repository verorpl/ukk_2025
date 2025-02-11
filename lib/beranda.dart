import 'package:flutter/material.dart';
import 'package:ukk_2025/penjualan.dart';
import 'login.dart';
import 'produk.dart';
import 'pelanggan.dart'; // Tambahkan import pelanggan

class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;

  const HomeScreen({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProductScreen(),    // Halaman Produk
    PelangganScreen(),  // Halaman Pelanggan
    CheckoutScreen(),   // Halaman Checkout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kasir",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Ubah teks menjadi putih
          ),
        ),
        backgroundColor: const Color(0xff3a57e8),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex], // Menampilkan halaman sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }
}
