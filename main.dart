import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StudentListScreen(),
    );
  }
}

// Model Data Mahasiswa
class Student {
  String nim;
  String name;
  String studyProgram;
  String studentClass;

  Student({
    required this.nim,
    required this.name,
    required this.studyProgram,
    required this.studentClass,
  });
}

// Halaman Utama: Daftar & Pencarian Mahasiswa
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Data Awal Minimal 5 Mahasiswa (Tahap 1)
  final List<Student> _students = [
    Student(
      nim: '25781032',
      name: 'Ezra Trinada Ganesia',
      studyProgram: 'Informatika',
      studentClass: 'TI-3B',
    ),
    Student(
      nim: '25781030',
      name: 'Calista Bella',
      studyProgram: 'Informatika',
      studentClass: 'TI-3B',
    ),
    Student(
      nim: '26781031',
      name: 'Cakrawala',
      studyProgram: 'Sistem Informasi',
      studentClass: 'SI-2B',
    ),
    Student(
      nim: '27781033',
      name: 'Angkasa',
      studyProgram: 'Teknik Komputer',
      studentClass: 'TK-1A',
    ),
    Student(
      nim: '25781035',
      name: 'Raina',
      studyProgram: 'Informatika',
      studentClass: 'TI-3B',
    ),
  ];

  String _searchQuery = '';
  String _selectedProdi = 'Semua';

  final List<String> _prodiOptions = [
    'Semua',
    'Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];

  // Logic Pencarian & Filter (Tahap 7 & Tantangan)
  List<Student> get _filteredStudents {
    return _students.where((student) {
      final matchesQuery =
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.nim.contains(_searchQuery);
      final matchesProdi =
          _selectedProdi == 'Semua' || student.studyProgram == _selectedProdi;
      return matchesQuery && matchesProdi;
    }).toList();
  }

  void _addStudent(Student student) {
    setState(() {
      _students.add(student);
    });
  }

  void _updateStudent(int index, Student updatedStudent) {
    setState(() {
      _students[index] = updatedStudent;
    });
  }

  void _deleteStudent(Student student) {
    setState(() {
      _students.removeWhere((s) => s.nim == student.nim);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Baris Pencarian (Tahap 7)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari nama atau NIM...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Program Studi & Jumlah Mahasiswa (Tantangan 1 & 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedProdi,
                  items: _prodiOptions.map((String prodi) {
                    return DropdownMenuItem<String>(
                      value: prodi,
                      child: Text(prodi),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedProdi = newValue!;
                    });
                  },
                ),
                Text(
                  'Total Mahasiswa: ${_students.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Daftar Mahasiswa atau Empty State (Tahap 1 & Tantangan 3)
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data mahasiswa',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final student = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            '${student.nim} - ${student.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${student.studyProgram}\n${student.studentClass}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final originalIndex = _students.indexWhere(
                              (s) => s.nim == student.nim,
                            );
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailScreen(
                                  student: student,
                                  onDelete: () {
                                    _deleteStudent(student);
                                    Navigator.pop(context);
                                  },
                                  onUpdate: (updatedStudent) {
                                    _updateStudent(
                                      originalIndex,
                                      updatedStudent,
                                    );
                                  },
                                ),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Tombol Tambah Data (Tahap 2)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newStudent = await Navigator.push<Student>(
            context,
            MaterialPageRoute(builder: (context) => const StudentFormScreen()),
          );
          if (newStudent != null) {
            _addStudent(newStudent);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
    );
  }
}

// Halaman Detail Mahasiswa (Tahap 4, 5, 6)
class StudentDetailScreen extends StatefulWidget {
  final Student student;
  final VoidCallback onDelete;
  final Function(Student) onUpdate;

  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student currentStudent;

  @override
  void initState() {
    super.initState();
    currentStudent = widget.student;
  }

  // Dialog Konfirmasi Hapus (Tahap 6)
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onDelete();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('NIM', currentStudent.nim),
            const SizedBox(height: 12),
            _buildDetailItem('Nama', currentStudent.name),
            const SizedBox(height: 12),
            _buildDetailItem('Program Studi', currentStudent.studyProgram),
            const SizedBox(height: 12),
            _buildDetailItem('Kelas', currentStudent.studentClass),
            const Spacer(),
            Row(
              children: [
                // Tombol Edit (Tahap 5)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updatedStudent = await Navigator.push<Student>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentFormScreen(student: currentStudent),
                        ),
                      );
                      if (updatedStudent != null) {
                        setState(() {
                          currentStudent = updatedStudent;
                        });
                        widget.onUpdate(updatedStudent);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Hapus (Tahap 6)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Form Tambah & Edit Mahasiswa dengan Validasi (Tahap 2, 3, 5)
class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nimController;
  late TextEditingController _nameController;
  late TextEditingController _prodiController;
  late TextEditingController _classController;

  @override
  void initState() {
    super.initState();
    _nimController = TextEditingController(text: widget.student?.nim ?? '');
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _prodiController = TextEditingController(
      text: widget.student?.studyProgram ?? '',
    );
    _classController = TextEditingController(
      text: widget.student?.studentClass ?? '',
    );
  }

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _prodiController.dispose();
    _classController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newStudent = Student(
        nim: _nimController.text,
        name: _nameController.text,
        studyProgram: _prodiController.text,
        studentClass: _classController.text,
      );
      Navigator.pop(context, newStudent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Form Edit Mahasiswa' : 'Form Tambah Mahasiswa',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nimController,
                  decoration: const InputDecoration(labelText: 'NIM'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIM wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prodiController,
                  decoration: const InputDecoration(labelText: 'Program Studi'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Program Studi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kelas wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
