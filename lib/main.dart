import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// Path kütüphanesine takma ad (alias) verdik: 'p'
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Etkinlik Planlayıcı',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white70,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------
// 1. VERİTABANI YARDIMCISI (DATABASE HELPER)
// ---------------------------------------------------------
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planner_final_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Kullanıcılar Tablosu
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL
    )
    ''');

    // Etkinlikler Tablosu
    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      imagePath TEXT NOT NULL,
      eventDate TEXT NOT NULL,
      location TEXT NOT NULL
    )
    ''');
  }

  // --- CRUD İŞLEMLERİ ---
  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    return await db.insert('users', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, String newUsername, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'username': newUsername, 'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createEvent(Map<String, dynamic> event) async {
    final db = await instance.database;
    return await db.insert('events', event);
  }

  // YENİ EKLENEN SİLME FONKSİYONU
  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getEvents(int userId) async {
    final db = await instance.database;
    return await db.query('events', where: 'userId = ?', whereArgs: [userId]);
  }
}

// Global Değişkenler
int? currentUserId;
String? currentUserName;

// ---------------------------------------------------------
// 2. GİRİŞ VE KAYIT EKRANLARI
// ---------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final user = await DatabaseHelper.instance.loginUser(
      _usernameController.text,
      _passwordController.text,
    );

    if (user != null) {
      setState(() {
        currentUserId = user['id'] as int;
        currentUserName = user['username'] as String;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hatalı kullanıcı adı veya şifre!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("Etkinlik Planlayıcı", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Kullanıcı Adı", prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Parola", prefixIcon: Icon(Icons.lock)), obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: _login, child: const Text("Giriş Yap")),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text("Hesabın yok mu? Kayıt Ol"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) return;
    await DatabaseHelper.instance.registerUser(_usernameController.text, _passwordController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt Başarılı!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Kullanıcı Adı")),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Parola"), obscureText: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: _register, child: const Text("Kayıt Ol")),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. ANA SAYFA
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() async {
    if (currentUserId != null) {
      final data = await DatabaseHelper.instance.getEvents(currentUserId!);
      setState(() => _events = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Etkinliklerim")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(currentUserName ?? "Kullanıcı"),
              accountEmail: const Text("Aktif Oturum"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.indigo),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home), title: const Text('Anasayfa'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate), title: const Text('Etkinlik Ekle'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEventScreen()));
                _refreshEvents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings), title: const Text('Bilgileri Güncelle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateProfileScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Çıkış', style: TextStyle(color: Colors.red)),
              onTap: () {
                currentUserId = null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: _events.isEmpty
          ? const Center(child: Text("Henüz etkinlik yok.\nMenüden 'Etkinlik Ekle' diyerek başlayın."))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Hero(
                tag: 'eventImg_${event['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event['imagePath'],
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
              title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(event['eventDate']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Detay sayfasına gidiyoruz, dönüşte refresh yapıyoruz
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                );
                // Detay sayfasından döndükten sonra listeyi yenile (silme işlemi yapıldıysa diye)
                _refreshEvents();
              },
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. ETKİNLİK EKLEME
// ---------------------------------------------------------
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController();

  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  DateTime? _selectedDate;
  String? _previewUrl;

  void _updatePreview() {
    setState(() {
      _previewUrl = _imageController.text;
    });
  }

  void _pickLocationFromMap() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konum Seç"),
          content: GestureDetector(
            onTapUp: (details) {
              final random = Random();
              double lat = 36.0 + random.nextInt(6) + (details.localPosition.dy / 100);
              double lng = 26.0 + random.nextInt(19) + (details.localPosition.dx / 100);

              _latController.text = lat.toStringAsFixed(6);
              _lngController.text = lng.toStringAsFixed(6);

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum Alındı!")));
            },
            child: Container(
              width: 300,
              height: 300,
              color: Colors.blue[50],
              child: Stack(
                children: [
                  Center(child: Icon(Icons.map, size: 100, color: Colors.blue.withOpacity(0.3))),
                  const Center(child: Text("Haritada bir noktaya tıkla", style: TextStyle(color: Colors.black54))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveEvent() async {
    if (_titleController.text.isEmpty || _selectedDate == null || _latController.text.isEmpty || _imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    String locationString = "Lat: ${_latController.text}, Lng: ${_lngController.text}";

    final eventMap = {
      'userId': currentUserId,
      'title': _titleController.text,
      'content': _contentController.text,
      'imagePath': _imageController.text,
      'eventDate': DateFormat('dd/MM/yyyy').format(_selectedDate!),
      'location': locationString,
    };

    await DatabaseHelper.instance.createEvent(eventMap);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Etkinlik Kaydedildi!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Etkinlik")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Etkinlik Adı")),
            const SizedBox(height: 12),
            TextField(controller: _contentController, decoration: const InputDecoration(labelText: "Açıklama"), maxLines: 3),
            const SizedBox(height: 12),

            // --- URL GİRİŞ ALANI ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: "Resim Linki (URL) Yapıştır",
                      hintText: "https://...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _updatePreview,
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: "Resmi Önizle",
                )
              ],
            ),
            const SizedBox(height: 10),

            if (_previewUrl != null && _previewUrl!.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  _previewUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("Resim yüklenemedi.", style: TextStyle(color: Colors.red)));
                  },
                ),
              ),

            const SizedBox(height: 20),

            // --- HARİTA & KONUM ---
            const Text("Konum Bilgisi:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: TextField(controller: _latController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Enlem"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _lngController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Boylam"))),
              ],
            ),
            TextButton.icon(
              onPressed: _pickLocationFromMap,
              icon: const Icon(Icons.map),
              label: const Text("Haritadan Seç"),
            ),

            const SizedBox(height: 10),

            // --- TARİH ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? "Tarih Seçilmedi"
                      : "Tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(2030));
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: const Text("Tarih Seç"),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: const Text("KAYDET"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. ETKİNLİK DETAYI (SİLME BUTONLU)
// ---------------------------------------------------------
class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Etkinliği Sil"),
        content: const Text("Bu etkinliği silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Dialog'u kapat
              await DatabaseHelper.instance.deleteEvent(event['id']);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Etkinlik silindi.")));
                Navigator.pop(context); // Detay sayfasını kapat ve listeye dön
              }
            },
            child: const Text("SİL", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              // --- SİLME BUTONU BURADA ---
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white54),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                  tooltip: "Etkinliği Sil",
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event['title'], style: const TextStyle(shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
              background: Hero(
                tag: 'eventImg_${event['id']}',
                child: Image.network(
                  event['imagePath'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.white)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(event['eventDate'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Konum:\n${event['location']}", style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                  ),
                  const Divider(height: 30),
                  const Text("Etkinlik Detayı", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(event['content'], style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 6. PROFİL GÜNCELLEME
// ---------------------------------------------------------
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});
  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userController.text = currentUserName ?? "";
  }

  void _update() async {
    if (currentUserId == null) return;
    await DatabaseHelper.instance.updateUser(currentUserId!, _userController.text, _passController.text);
    setState(() => currentUserName = _userController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgiler Güncellendi!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bilgileri Güncelle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 20),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Yeni Kullanıcı Adı")),
            const SizedBox(height: 12),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Yeni Şifre")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _update, child: const Text("GÜNCELLE")),
          ],
        ),
      ),
    );
  }
}