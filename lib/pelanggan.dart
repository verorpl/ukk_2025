import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganScreen extends StatefulWidget {
  @override
  _PelangganScreenState createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelangganList = [];
  TextEditingController _searchController = TextEditingController();
List<Map<String, dynamic>> filteredPelangganList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
  }

  Future<void> _fetchPelanggan() async {
  try {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      pelangganList = List<Map<String, dynamic>>.from(response);
      filteredPelangganList = pelangganList; // Inisialisasi daftar yang difilter
      isLoading = false;
    });
  } catch (e) {
    _showError('An error occurred: $e');
  }
}

  Future<void> _addPelanggan(String namaPelanggan, String alamat, String nomorTelepon) async {
  try {
    // Cek apakah pelanggan sudah ada berdasarkan nama atau nomor telepon
    final existingPelanggan = await supabase
        .from('pelanggan')
        .select()
        .or('nama_pelanggan.eq.$namaPelanggan,nomor_telepon.eq.$nomorTelepon');

    if (existingPelanggan.isNotEmpty) {
      _showError('Pelanggan dengan nama atau nomor telepon ini sudah ada!');
      return;
    }

    // Jika tidak ada duplikasi, tambahkan pelanggan baru
    await supabase.from('pelanggan').insert({
      'nama_pelanggan': namaPelanggan,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
    });

    _fetchPelanggan(); // Refresh daftar pelanggan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pelanggan berhasil ditambahkan')),
    );
  } catch (e) {
    _showError('Gagal menambahkan pelanggan: $e');
  }
}


  Future<void> _updatePelanggan(int id, String namaPelanggan, String alamat, String nomorTelepon) async {
    try {
      await supabase.from('pelanggan').update({
        'nama_pelanggan': namaPelanggan,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).eq('pelanggan_id', id);
      _fetchPelanggan(); // Refresh data pelanggan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

void _confirmDeletePelanggan(int id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog sebelum menghapus
              _deletePelanggan(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Future<void> _deletePelanggan(int id) async {
  try {
    await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
    _fetchPelanggan(); // Refresh data pelanggan
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelanggan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _filterPelanggan(String query) {
  setState(() {
    filteredPelangganList = pelangganList.where((pelanggan) {
      final nama = pelanggan['nama_pelanggan']?.toLowerCase() ?? '';
      final alamat = pelanggan['alamat']?.toLowerCase() ?? '';
      final nomor = pelanggan['nomor_telepon']?.toLowerCase() ?? '';
      return nama.contains(query.toLowerCase()) ||
             alamat.contains(query.toLowerCase()) ||
             nomor.contains(query.toLowerCase());
    }).toList();
  });
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddPelangganDialog() {
  final TextEditingController namaPelangganController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController nomorTeleponController = TextEditingController();

  String? namaError, alamatError, nomorTeleponError;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Pelanggan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaPelangganController,
                    decoration: InputDecoration(
                      labelText: 'Nama Pelanggan',
                      errorText: namaError, // Menampilkan error dalam warna merah
                    ),
                  ),
                  TextField(
                    controller: alamatController,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      errorText: alamatError,
                    ),
                  ),
                  TextField(
                    controller: nomorTeleponController,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      errorText: nomorTeleponError,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  final String namaPelanggan = namaPelangganController.text.trim();
                  final String alamat = alamatController.text.trim();
                  final String nomorTelepon = nomorTeleponController.text.trim();

                  setState(() {
                    namaError = namaPelanggan.isEmpty ? 'Nama pelanggan harus diisi' : null;
                    alamatError = alamat.isEmpty ? 'Alamat harus diisi' : null;
                    nomorTeleponError = nomorTelepon.isEmpty
                        ? 'Nomor telepon harus diisi'
                        : (!RegExp(r'^[0-9]+$').hasMatch(nomorTelepon)
                            ? 'Nomor telepon harus berupa angka'
                            : (nomorTelepon.length < 10 ? 'Nomor telepon minimal 10 digit' : null));
                  });

                  // Jika ada error, hentikan proses
                  if (namaError != null || alamatError != null || nomorTeleponError != null) {
                    return;
                  }

                  // **CEK DUPLIKASI PELANGGAN**
                  final existingPelanggan = await supabase
                      .from('pelanggan')
                      .select()
                      .or('nama_pelanggan.eq.$namaPelanggan,nomor_telepon.eq.$nomorTelepon');

                  if (existingPelanggan.isNotEmpty) {
                    setState(() {
                      namaError = 'Pelanggan dengan nama ini sudah ada';
                      nomorTeleponError = 'Nomor telepon sudah digunakan';
                    });
                    return;
                  }

                  // **TAMBAH PELANGGAN KE DATABASE**
                  await _addPelanggan(namaPelanggan, alamat, nomorTelepon);
                  Navigator.of(context).pop(); // Tutup dialog setelah sukses
                },
                child: const Text('Tambah'),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _showEditPelangganDialog(int id, String namaPelanggan, String alamat, String nomorTelepon) {
    final TextEditingController namaPelangganController = TextEditingController(text: namaPelanggan);
    final TextEditingController alamatController = TextEditingController(text: alamat);
    final TextEditingController nomorTeleponController = TextEditingController(text: nomorTelepon);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Pelanggan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaPelangganController,
                  decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                ),
                TextField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                TextField(
                  controller: nomorTeleponController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final String updatedNamaPelanggan = namaPelangganController.text;
                final String updatedAlamat = alamatController.text;
                final String updatedNomorTelepon = nomorTeleponController.text;

                if (updatedNamaPelanggan.isNotEmpty && updatedAlamat.isNotEmpty && updatedNomorTelepon.isNotEmpty) {
                  _updatePelanggan(id, updatedNamaPelanggan, updatedAlamat, updatedNomorTelepon);
                  Navigator.of(context).pop(); // Tutup dialog
                } else {
                  _showError('Mohon isi data dengan benar.');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPelangganTable() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Nama Pelanggan')),
        DataColumn(label: Text('Alamat')),
        DataColumn(label: Text('Nomor Telepon')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: filteredPelangganList.map((pelanggan) {
        return DataRow(
          cells: [
            DataCell(Text(pelanggan['pelanggan_id'].toString())),
            DataCell(Text(pelanggan['nama_pelanggan'] ?? 'Unknown')),
            DataCell(Text(pelanggan['alamat'] ?? 'Unknown')),
            DataCell(Text(pelanggan['nomor_telepon'] ?? 'Unknown')),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditPelangganDialog(
                      pelanggan['pelanggan_id'],
                      pelanggan['nama_pelanggan'],
                      pelanggan['alamat'],
                      pelanggan['nomor_telepon'],
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDeletePelanggan(pelanggan['pelanggan_id']);
                  },
                ),
              ],
            )),
          ],
        );
      }).toList(),
    ),
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : pelangganList.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada pelanggan.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari Pelanggan',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: _filterPelanggan,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildPelangganTable(),
                    ),
                  ),
                ],
              ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddPelangganDialog,
      child: const Icon(Icons.add),
    ),
  );
}
}