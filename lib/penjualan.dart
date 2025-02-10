import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await supabase.from('produk').select();
      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      _showError('Error fetching products: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = cart.indexWhere((item) => item['id'] == product['id']);

      if (index != -1) {
        cart[index]['quantity'] += 1;
      } else {
        cart.add({
          'id': product['id'],
          'nama_produk': product['nama_produk'],
          'harga': product['harga'],
          'quantity': 1,
        });
      }
    });
  }

  void _removeFromCart(int id) {
    setState(() {
      final index = cart.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        if (cart[index]['quantity'] > 1) {
          cart[index]['quantity'] -= 1;
        } else {
          cart.removeAt(index); // Hapus produk jika jumlah tinggal 1
        }
      }
    });
  }

  double _calculateTotal() {
    return cart.fold(0, (total, item) => total + (item['harga'] * item['quantity']));
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) {
      _showError('Keranjang belanja kosong!');
      return;
    }
    try {
      final transaksi = await supabase.from('transaksi').insert({
        'total_harga': _calculateTotal(),
        'tanggal': DateTime.now().toIso8601String(),
      }).select('id').single();

      for (var item in cart) {
        await supabase.from('detail_transaksi').insert({
          'transaksi_id': transaksi['id'],
          'produk_id': item['id'],
          'jumlah': item['quantity'],
          'subtotal': item['harga'] * item['quantity'],
        });
      }

      setState(() {
        cart.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi berhasil!')),
      );
    } catch (e) {
      _showError('Gagal melakukan checkout: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout Produk')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product['nama_produk']),
                        subtitle: Text('Rp ${product['harga']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _addToCart(product),
                          child: Text('Tambah'),
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item['nama_produk']),
                        subtitle: Text('Rp ${item['harga']} x ${item['quantity']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeFromCart(item['id']),
                            ),
                            Text('${item['quantity']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => _addToCart(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Total: Rp ${_calculateTotal()}'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _checkout,
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
