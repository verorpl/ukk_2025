import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    searchController.addListener(() {
      _searchProducts(searchController.text);
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final List<dynamic> response = await supabase.from('produk').select();
      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _searchProducts(String query) {
    setState(() {
      filteredProducts = query.isEmpty
          ? products
          : products
              .where((product) =>
                  product['nama_produk'].toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> _deleteProduct(int id) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Konfirmasi Hapus'),
      content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Tutup dialog
            try {
              await supabase.from('produk').delete().eq('produk_id', id);
              _fetchProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Produk berhasil dihapus'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              _showError('Terjadi kesalahan: $e');
            }
          },
          child: Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    final namaProdukController = TextEditingController(text: product['nama_produk']);
    final hargaController = TextEditingController(text: product['harga'].toString());
    final stokController = TextEditingController(text: product['stok'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final namaProduk = namaProdukController.text.trim();
                final hargaText = hargaController.text.trim();
                final stokText = stokController.text.trim();

                if (namaProduk.isNotEmpty &&
                    double.tryParse(hargaText) != null &&
                    int.tryParse(stokText) != null) {
                  await supabase.from('produk').update({
                    'nama_produk': namaProduk,
                    'harga': double.parse(hargaText),
                    'stok': int.parse(stokText),
                  }).eq('produk_id', product['produk_id']);

                  _fetchProducts();
                  Navigator.of(context).pop();
                } else {
                  _showError('Masukkan data yang valid!');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
              ? const Center(child: Text('Produk tidak ditemukan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          product['nama_produk'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Harga: Rp ${product['harga']} | Stok: ${product['stok']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditProductDialog(product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product['produk_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    final namaProdukController = TextEditingController();
    final hargaController = TextEditingController();
    final stokController = TextEditingController();

    final ValueNotifier<String?> namaError = ValueNotifier(null);
    final ValueNotifier<String?> hargaError = ValueNotifier(null);
    final ValueNotifier<String?> stokError = ValueNotifier(null);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<String?>(
                    valueListenable: namaError,
                    builder: (context, error, child) {
                      return TextField(
                        controller: namaProdukController,
                        decoration: InputDecoration(
                          labelText: 'Nama Produk',
                          errorText: error,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: hargaError,
                    builder: (context, error, child) {
                      return TextField(
                        controller: hargaController,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                          errorText: error,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                        keyboardType: TextInputType.number,
                      );
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: stokError,
                    builder: (context, error, child) {
                      return TextField(
                        controller: stokController,
                        decoration: InputDecoration(
                          labelText: 'Stok',
                          errorText: error,
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                        keyboardType: TextInputType.number,
                      );
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final namaProduk = namaProdukController.text.trim();
                final hargaText = hargaController.text.trim();
                final stokText = stokController.text.trim();

                bool isValid = true;

                // Validasi Nama Produk (Tidak Boleh Kosong)
                if (namaProduk.isEmpty) {
                  namaError.value = 'Nama produk tidak boleh kosong!';
                  isValid = false;
                } else {
                  namaError.value = null;
                }

                // Validasi Harga (Harus Angka & Tidak Boleh Kosong)
                final harga = double.tryParse(hargaText);
                if (hargaText.isEmpty) {
                  hargaError.value = 'Harga tidak boleh kosong!';
                  isValid = false;
                } else if (harga == null) {
                  hargaError.value = 'Harga harus berupa angka!';
                  isValid = false;
                } else {
                  hargaError.value = null;
                }

                // Validasi Stok (Harus Angka & Tidak Boleh Kosong)
                final stok = int.tryParse(stokText);
                if (stokText.isEmpty) {
                  stokError.value = 'Stok tidak boleh kosong!';
                  isValid = false;
                } else if (stok == null) {
                  stokError.value = 'Stok harus berupa angka!';
                  isValid = false;
                } else {
                  stokError.value = null;
                }

                if (!isValid) return;

                try {
                  // Cek apakah produk dengan nama yang sama sudah ada
                  final existingProduct = await supabase
                      .from('produk')
                      .select()
                      .eq('nama_produk', namaProduk)
                      .maybeSingle();

                  if (existingProduct != null) {
                    namaError.value = 'Produk dengan nama "$namaProduk" sudah ada!';
                    return;
                  }

                  // Jika tidak ada, tambahkan produk baru
                  await supabase.from('produk').insert({
                    'nama_produk': namaProduk,
                    'harga': harga,
                    'stok': stok,
                  });

                  _fetchProducts();
                  Navigator.of(context).pop();
                } catch (e) {
                  _showError('Terjadi kesalahan: $e');
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  },
  child: const Icon(Icons.add),
),



    );
  }
}
