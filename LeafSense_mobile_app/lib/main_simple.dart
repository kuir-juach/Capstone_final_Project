import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/splash_screen.dart';
import 'screens/feedback_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicinalApp());
}

class MedicinalApp extends StatefulWidget {
  const MedicinalApp({super.key});

  @override
  State<MedicinalApp> createState() => _MedicinalAppState();
}

class _MedicinalAppState extends State<MedicinalApp> {
  bool _isDarkMode = false;
  bool _showSplash = true;
  double _fontSize = 16.0;
  static const Color customGreen = Color.fromRGBO(0, 101, 46, 1.0);

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _changeFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: customGreen,
        scaffoldBackgroundColor: Colors.lightGreen[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: customGreen,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(color: Colors.white, elevation: 2),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: _fontSize),
          bodyMedium: TextStyle(fontSize: _fontSize - 2),
          titleLarge: TextStyle(fontSize: _fontSize + 4),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: customGreen,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: customGreen,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardTheme(color: Color(0xFF1E1E1E), elevation: 4),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: _fontSize, color: Colors.white),
          bodyMedium: TextStyle(fontSize: _fontSize - 2, color: Colors.white70),
          titleLarge: TextStyle(fontSize: _fontSize + 4, color: Colors.white),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showSplash
          ? SplashScreen(onComplete: _onSplashComplete)
          : MainScreen(
              isDarkMode: _isDarkMode,
              fontSize: _fontSize,
              onDarkModeToggle: _toggleDarkMode,
              onFontSizeChange: _changeFontSize,
            ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final VoidCallback onDarkModeToggle;
  final Function(double) onFontSizeChange;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onDarkModeToggle,
    required this.onFontSizeChange,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isArabic = false;
  final List<Map<String, dynamic>> _history = [];

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
  }

  void _addToHistory(String label, double confidence, File? imageFile, Uint8List? imageBytes) {
    setState(() {
      _history.insert(0, {
        'label': label,
        'confidence': confidence,
        'image': imageFile,
        'imageBytes': imageBytes,
        'timestamp': DateTime.now(),
      });
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            isArabic: _isArabic,
            onLanguageChange: _toggleLanguage,
            onPrediction: _addToHistory,
          ),
          HistoryScreen(
            history: _history,
            isArabic: _isArabic,
            onClearHistory: _clearHistory,
          ),
          const FeedbackScreen(),
          SettingsScreen(
            isArabic: _isArabic,
            isDarkMode: widget.isDarkMode,
            fontSize: widget.fontSize,
            onLanguageChange: _toggleLanguage,
            onDarkModeToggle: widget.onDarkModeToggle,
            onFontSizeChange: widget.onFontSizeChange,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _isArabic ? 'الرئيسية' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: _isArabic ? 'السجل' : 'History',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.feedback),
            label: _isArabic ? 'التعليقات' : 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: _isArabic ? 'الإعدادات' : 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageChange;
  final Function(String, double, File?, Uint8List?) onPrediction;

  const HomeScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageChange,
    required this.onPrediction,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _predictedLabel;
  double? _predictedProb;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        if (!kIsWeb) {
          _imageFile = File(picked.path);
        }
        _imageBytes = bytes;
        _predictedLabel = null;
        _predictedProb = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'خطأ في الوصول للكاميرا' : 'Camera access error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _predictPlant() async {
    if (_imageBytes == null) return;

    // Simulate prediction with your plant data
    final plants = ['Aloe Vera', 'Moringa', 'Neem', 'Hibiscus', 'Baobab'];
    final random = Random();
    final selectedPlant = plants[random.nextInt(plants.length)];
    final confidence = 0.7 + random.nextDouble() * 0.3;

    setState(() {
      _predictedLabel = selectedPlant;
      _predictedProb = confidence;
    });

    widget.onPrediction(selectedPlant, confidence, _imageFile, _imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isArabic ? 'LeafSense - تحديد النباتات' : 'LeafSense - Plant ID'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isArabic ? Icons.translate : Icons.language),
            onPressed: widget.onLanguageChange,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color.fromRGBO(0, 101, 46, 0.3)),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          widget.isArabic ? 'اختر صورة نبات للتعرف عليه' : 'Select a plant image to identify',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(widget.isArabic ? 'كاميرا' : 'Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: Text(widget.isArabic ? 'معرض' : 'Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _imageBytes != null ? _predictPlant : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                ),
                child: Text(widget.isArabic ? 'تنبؤ' : 'Predict'),
              ),
            ),
            const SizedBox(height: 16),
            if (_predictedLabel != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isArabic ? 'النتيجة:' : 'Result:',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_predictedLabel!),
                      Text('Confidence: ${(_predictedProb! * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final bool isArabic;
  final VoidCallback onClearHistory;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.isArabic,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجل التعرّف' : 'Recognition History'),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onClearHistory,
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Text(isArabic ? 'لا يوجد سجل بعد' : 'No history yet'),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item['imageBytes'] != null
                          ? Image.memory(item['imageBytes'], width: 60, height: 60, fit: BoxFit.cover)
                          : Container(width: 60, height: 60, color: Colors.grey[300]),
                    ),
                    title: Text(item['label']),
                    subtitle: Text('Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%'),
                  ),
                );
              },
            ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;
  final double fontSize;
  final VoidCallback onLanguageChange;
  final VoidCallback onDarkModeToggle;
  final Function(double) onFontSizeChange;

  const SettingsScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.fontSize,
    required this.onLanguageChange,
    required this.onDarkModeToggle,
    required this.onFontSizeChange,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isArabic ? 'الإعدادات' : 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(widget.isArabic ? 'اللغة' : 'Language'),
            trailing: Switch(
              value: widget.isArabic,
              onChanged: (_) => widget.onLanguageChange(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(widget.isArabic ? 'الوضع المظلم' : 'Dark Mode'),
            trailing: Switch(
              value: widget.isDarkMode,
              onChanged: (_) => widget.onDarkModeToggle(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(widget.isArabic ? 'حجم الخط' : 'Font Size'),
            subtitle: Slider(
              value: widget.fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: widget.fontSize.round().toString(),
              onChanged: widget.onFontSizeChange,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: Text(widget.isArabic ? 'قيم التطبيق' : 'Rate App'),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) => 
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStars = index + 1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.isArabic ? 'شكراً! تقييمك:' : 'Thanks! Your rating:'} $_selectedStars ${widget.isArabic ? 'نجوم' : 'stars'}')),
                    );
                  },
                  child: Icon(
                    Icons.star,
                    color: index < _selectedStars ? Colors.amber : Colors.grey,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(widget.isArabic ? 'حول التطبيق' : 'About App'),
            subtitle: Text(
              widget.isArabic
                  ? 'يساعد هذا التطبيق المستخدمين على تحديد النباتات الطبية في جنوب السودان فوراً من خلال التقاط صورة مباشرة أو تحميلها من المعرض. باستخدام تقنية التعلم العميق، يتعرف على النبات ويقدم معلومات مفصلة باللغتين العربية والإنجليزية - بما في ذلك قيمه الطبية وطرق التحضير والجرعة الموصى بها.'
                  : 'This app helps users identify South Sudanese medicinal plants instantly by either taking a live photo or uploading one from the gallery. Using deep learning technology, it recognizes the plant and provides detailed information in Arabic and English — including its medicinal values, preparation methods, and recommended dosage.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}