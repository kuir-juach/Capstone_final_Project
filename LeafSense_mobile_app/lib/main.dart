import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/experts_service.dart';
import 'services/prediction_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDFzXdDNRtXADsYWz24wk9CU4wVYKFypoY",
        authDomain: "leafsense-2b318.firebaseapp.com",
        projectId: "leafsense-2b318",
        storageBucket: "leafsense-2b318.firebasestorage.app",
        messagingSenderId: "153629330083",
        appId: "1:153629330083:web:ddd3db9e7dd039513d4d16",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
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
  bool _showOnboarding = true;
  bool _isLoggedIn = false;
  double _fontSize = 16.0;
  final AuthService _authService = AuthService();
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

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  void initState() {
    super.initState();
    ExpertsService.addExperts();
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
          : _showOnboarding
              ? OnboardingScreen(onComplete: _onOnboardingComplete)
              : _isLoggedIn
                  ? MainScreen(
                      isDarkMode: _isDarkMode,
                      fontSize: _fontSize,
                      onDarkModeToggle: _toggleDarkMode,
                      onFontSizeChange: _changeFontSize,
                    )
                  : LoginScreen(
                      authService: _authService,
                      onLoginSuccess: _onLoginSuccess,
                    ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to LeafSense',
      'subtitle': 'Preserving herbal wisdom with intelligent plant recognition technology',
      'icon': 'eco',
    },
    {
      'title': 'Medicinal Plant Identifier',
      'subtitle': 'Take or upload a photo and get instant plant identification with detailed information',
      'icon': 'camera_alt',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            page['icon'] == 'eco' ? Icons.eco : Icons.camera_alt,
                            size: 60,
                            color: const Color.fromRGBO(0, 101, 46, 1.0),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 101, 46, 1.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
  bool _isLoading = false;
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

    setState(() {
      _isLoading = true;
      _predictedLabel = null;
      _predictedProb = null;
    });

    try {
      final result = await PredictionService.predictPlant(_imageBytes!);
      
      final plantName = result['predicted_class'] ?? 'Unknown';
      final confidence = (result['confidence'] ?? 0.0).toDouble();
      
      setState(() {
        _predictedLabel = plantName;
        _predictedProb = confidence;
        _isLoading = false;
      });
      
      widget.onPrediction(plantName, confidence, _imageFile, _imageBytes);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
          ),
        );
      }
      print('Flutter prediction error: $e');
    }
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
                onPressed: _imageBytes != null && !_isLoading ? _predictPlant : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.isArabic ? 'تنبؤ' : 'Predict'),
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
            leading: const Icon(Icons.person),
            title: Text(widget.isArabic ? 'الملف الشخصي' : 'Profile'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_online),
            title: Text(widget.isArabic ? 'حجز جلسة' : 'Book Session'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BookingScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(widget.isArabic ? 'جلساتي' : 'My Bookings'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(widget.isArabic ? 'تسجيل الخروج' : 'Sign Out'),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MedicinalApp()),
                  (route) => false,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(widget.isArabic ? 'حول التطبيق' : 'About App'),
            subtitle: Text(
              widget.isArabic
                  ? 'يساعد هذا التطبيق المستخدمين على تحديد النباتات الطبية في جنوب السودان فوراً من خلال التقاط صورة مباشرة أو تحميلها من المعرض. باستخدام تقنية التعلم العميق، يتعرف على النبات ويقدم معلومات مفصلة باللغتين العربية والإنجليزية - بما في ذلك قيمه الطبية وطرق التحضير والجرعة الموصى بها.'
                  : 'This app helps users identify South Sudanese medicinal plants instantly by either taking a live photo or uploading one from the gallery. Using deep learning technology, it recognizes the plant and provides detailed information in Arabic and English — including its medicinal values, preparation methods, and recommended dosage.\n\nDesigned to work offline and on low-resource devices, the app bridges traditional wisdom and modern innovation, ensuring that indigenous knowledge is preserved and accessible to everyone — from community health workers to students and traditional healers.\n\nMore than just a digital tool, this app celebrates culture, promotes safe herbal practices, and empowers users to connect with the healing power of nature through both technology and tradition.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}