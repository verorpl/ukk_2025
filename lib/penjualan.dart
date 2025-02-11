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
  List<Map<String, dynamic>> customers = [];
  Map<String, dynamic>? selectedCustomer;
  bool isLoading = true;
  bool isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCustomers();
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

  Future<void> _fetchCustomers() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        customers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Gagal mengambil data pelanggan: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add({
        'id': product['id'],
        'nama_produk': product['nama_produk'],
        'harga': product['harga'],
        'quantity': 1,
      });
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  double _calculateTotal() {
    return cart.fold(0, (total, item) => total + (item['harga'] * item['quantity']));
  }

  void _checkout() async {
  if (cart.isEmpty) {
    _showError('Keranjang belanja kosong!');
    return;
  }

  if (selectedCustomer == null) {
    _showError('Silakan pilih pelanggan terlebih dahulu!');
    _showCustomerSelection();
    return;
  }

  setState(() {
    isCheckingOut = true;
  });

  try {
    // Masukkan transaksi ke dalam tabel penjualan
    final transaksi = await supabase.from('penjualan').insert({
      'pelanggan_id': selectedCustomer!['pelanggan_id'], // Sesuaikan dengan kolom pelanggan_id pada tabel
      'total_harga': _calculateTotal(),
      'tanggal_penjualan': DateTime.now().toIso8601String(), // Gunakan format yang sesuai
    }).select('penjualan_id').single(); // Mengambil penjualan_id setelah insert

    // Masukkan detail transaksi ke dalam tabel detail_penjualan (asumsi nama tabel)
    for (var item in cart) {
      await supabase.from('detail_penjualan').insert({
        'penjualan_id': transaksi['penjualan_id'], // Menggunakan penjualan_id yang baru saja dibuat
        'produk_id': item['id'],
        'jumlah': item['quantity'],
        'subtotal': item['harga'] * item['quantity'],
      });
    }

    setState(() {
      cart.clear();
      selectedCustomer = null;
      isCheckingOut = false;
    });

    Navigator.pop(context);
    // Menampilkan struk setelah checkout berhasil
    _showReceipt(transaksi['penjualan_id'], _calculateTotal(), cart);
  } catch (e) {
    setState(() {
      isCheckingOut = false;
    });
    _showError('Gagal melakukan checkout: $e');
  }
}

  void _showReceipt(int transaksiId, double totalHarga, List<Map<String, dynamic>> purchasedItems) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Struk Pembelian', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Transaksi: $transaksiId', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...purchasedItems.map((item) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('${item['nama_produk']} x${item['quantity']} - Rp ${item['harga'] * item['quantity']}'),
                );
              }).toList(),
              Divider(),
              Text(
                'Total: Rp $totalHarga',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),  // Menutup struk
            child: Text('Tutup'),
          ),
        ],
      );
    },
  );
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCustomerSelection() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              customers.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return ListTile(
                            title: Text(customer['nama_pelanggan']),
                            onTap: () {
                              setState(() {
                                selectedCustomer = customer;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Keranjang Belanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              cart.isEmpty
                  ? Text('Keranjang kosong', style: TextStyle(color: Colors.grey))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Icon(Icons.shopping_cart, color: Colors.blueAccent),
                              title: Text(item['nama_produk']),
                              subtitle: Text('Rp ${item['harga']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    cart.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              SizedBox(height: 10),
              Divider(),

              // Tombol checkout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _showCustomerSelection,  // Pilih pelanggan
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text(selectedCustomer == null ? 'Pilih Pelanggan' : selectedCustomer!['nama_pelanggan']),
                  ),
                  ElevatedButton(
                    onPressed: isCheckingOut ? null : _checkout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: isCheckingOut ? CircularProgressIndicator(color: Colors.white) : Text('Checkout Sekarang'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Checkout Produk'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _showCart,
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _showCustomerSelection,  // Pilih pelanggan
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: Text(selectedCustomer == null ? 'Pilih Pelanggan' : selectedCustomer!['nama_pelanggan']),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(product['nama_produk']),
                            subtitle: Text('Rp ${product['harga']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              onPressed: () => _addToCart(product),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
