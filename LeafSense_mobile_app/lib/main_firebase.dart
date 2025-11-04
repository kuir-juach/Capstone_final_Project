import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MedicinalApp());
}

class MedicinalApp extends StatefulWidget {
  const MedicinalApp({super.key});

  @override
  State<MedicinalApp> createState() => _MedicinalAppState();
}

class _MedicinalAppState extends State<MedicinalApp> {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  String _fontFamily = 'Default';
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

  void _changeFontFamily(String fontFamily) {
    setState(() {
      _fontFamily = fontFamily;
    });
  }

  Future<void> _logout() async {
    await _authService.signOut();
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
          bodyLarge: TextStyle(
            fontSize: _fontSize,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: _fontSize - 2,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontSize: _fontSize + 4,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
            color: Colors.black87,
          ),
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
          bodyLarge: TextStyle(
            fontSize: _fontSize,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: _fontSize - 2,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
            color: Colors.white70,
          ),
          titleLarge: TextStyle(
            fontSize: _fontSize + 4,
            fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return MainScreen(
              isDarkMode: _isDarkMode,
              fontSize: _fontSize,
              fontFamily: _fontFamily,
              onDarkModeToggle: _toggleDarkMode,
              onFontSizeChange: _changeFontSize,
              onFontFamilyChange: _changeFontFamily,
              onLogout: _logout,
            );
          } else {
            return OnboardingScreen(
              onComplete: () => LoginScreen(authService: _authService),
            );
          }
        },
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final Widget Function() onComplete;

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
      'subtitle':
          'Preserving herbal wisdom with intelligent plant recognition technology',
      'icon': 'eco',
    },
    {
      'title': 'Medicinal Plant Identifier',
      'subtitle':
          'Take or upload a photo and get instant plant identification with detailed information',
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
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => widget.onComplete()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            page['icon'] == 'eco'
                                ? Icons.eco
                                : Icons.camera_alt,
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
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          color:
                              _currentPage == index
                                  ? Colors.white
                                  : Colors.white54,
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
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
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

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email. Please sign up first.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    }
    return 'Sign-in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 101, 46, 1.0),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.eco, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 101, 46, 1.0),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue using LeafSense',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.g_mobiledata,
                        size: 24,
                        color: Colors.red,
                      );
                    },
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SignUpScreen(authService: widget.authService),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 101, 46, 1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final String fontFamily;
  final VoidCallback onDarkModeToggle;
  final Function(double) onFontSizeChange;
  final Function(String) onFontFamilyChange;
  final Future<void> Function() onLogout;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.fontSize,
    required this.fontFamily,
    required this.onDarkModeToggle,
    required this.onFontSizeChange,
    required this.onFontFamilyChange,
    required this.onLogout,
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

  void _addToHistory(
    String label,
    double confidence,
    File? imageFile,
    Uint8List? imageBytes,
  ) {
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

  void _updateCurrentImageBytes(Uint8List? bytes) {
    // Image bytes updated for potential future use
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              isArabic: _isArabic,
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              onLanguageChange: _toggleLanguage,
              onPrediction: _addToHistory,
              onImageBytesUpdate: _updateCurrentImageBytes,
            ),
            HistoryScreen(
              history: _history,
              isArabic: _isArabic,
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              onClearHistory: _clearHistory,
            ),
            SettingsScreen(
              isArabic: _isArabic,
              isDarkMode: widget.isDarkMode,
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              onLanguageChange: _toggleLanguage,
              onDarkModeToggle: widget.onDarkModeToggle,
              onFontSizeChange: widget.onFontSizeChange,
              onFontFamilyChange: widget.onFontFamilyChange,
              onLogout: widget.onLogout,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              icon: const Icon(Icons.settings),
              label: _isArabic ? 'الإعدادات' : 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isArabic;
  final double fontSize;
  final String fontFamily;
  final VoidCallback onLanguageChange;
  final Function(String, double, File?, Uint8List?) onPrediction;
  final Function(Uint8List?) onImageBytesUpdate;

  const HomeScreen({
    super.key,
    required this.isArabic,
    required this.fontSize,
    required this.fontFamily,
    required this.onLanguageChange,
    required this.onPrediction,
    required this.onImageBytesUpdate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _plantsInfo = {};
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _predictedLabel;
  double? _predictedProb;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/plants_info.json',
      );
      final data = await json.decode(response);
      setState(() {
        _plantsInfo = data;
      });
    } catch (e) {
      debugPrint('Error loading plant data: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

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

      widget.onImageBytesUpdate(bytes);
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic
                  ? 'خطأ في الوصول للكاميرا'
                  : 'Camera access error',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openCamera() async {
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );

        if (photo != null) {
          final bytes = await photo.readAsBytes();
          setState(() {
            if (!kIsWeb) {
              _imageFile = File(photo.path);
            }
            _imageBytes = bytes;
            _predictedLabel = null;
            _predictedProb = null;
          });
          widget.onImageBytesUpdate(bytes);
        }
      } catch (e) {
        debugPrint('Camera error: $e');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic
                  ? 'يجب السماح بالوصول للكاميرا'
                  : 'Camera permission required',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _predictPlant() async {
    if (_imageBytes == null) return;

    // Simulate prediction with random results
    final plants = _plantsInfo.keys.toList();
    final random = Random();
    final selectedPlant = plants[random.nextInt(plants.length)];
    final confidence = 0.7 + random.nextDouble() * 0.3; // 70-100%

    setState(() {
      _predictedLabel = selectedPlant;
      _predictedProb = confidence;
    });

    widget.onPrediction(selectedPlant, confidence, _imageFile, _imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isArabic
              ? 'LeafSense - تحديد النباتات'
              : 'LeafSense - Plant ID',
          style: TextStyle(
            fontFamily:
                widget.fontFamily == 'Default' ? null : widget.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isArabic ? Icons.translate : Icons.language),
            onPressed: widget.onLanguageChange,
            tooltip: widget.isArabic ? 'English' : 'العربية',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromRGBO(0, 101, 46, 0.3),
                  width: 2,
                ),
              ),
              child:
                  _imageBytes != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 64,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.isArabic
                                ? 'اختر صورة نبات للتعرف عليه'
                                : 'Select a plant image to identify',
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[600],
                              fontFamily:
                                  widget.fontFamily == 'Default'
                                      ? null
                                      : widget.fontFamily,
                            ),
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
                    onPressed: _openCamera,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      widget.isArabic ? 'كاميرا' : 'Camera',
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        color: Colors.white,
                        fontFamily:
                            widget.fontFamily == 'Default'
                                ? null
                                : widget.fontFamily,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: Text(
                      widget.isArabic ? 'معرض' : 'Gallery',
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        color: Colors.white,
                        fontFamily:
                            widget.fontFamily == 'Default'
                                ? null
                                : widget.fontFamily,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color:
                    _imageBytes != null
                        ? const Color.fromRGBO(0, 101, 46, 1.0)
                        : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        _imageBytes != null
                            ? const Color.fromRGBO(0, 101, 46, 0.4)
                            : Colors.grey.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _imageBytes != null ? _predictPlant : null,
                icon: const Icon(
                  Icons.auto_awesome,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  widget.isArabic ? '🔍 تنبؤ' : '🔍 Predict',
                  style: TextStyle(
                    fontSize: widget.fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily:
                        widget.fontFamily == 'Default'
                            ? null
                            : widget.fontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _imageBytes != null
                          ? const Color.fromRGBO(0, 101, 46, 1.0)
                          : Colors.grey.shade400,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromRGBO(0, 101, 46, 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  _predictedLabel == null
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            size: 48,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isArabic
                                ? 'النتائج ستظهر هنا'
                                : 'Results will appear here',
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[600],
                              fontFamily:
                                  widget.fontFamily == 'Default'
                                      ? null
                                      : widget.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : _buildPredictionCard(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _toArabicNumbers(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  Widget _buildPredictionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final info = _plantsInfo[_predictedLabel] ?? {};
    final name =
        widget.isArabic
            ? (info['name_ar'] ?? _predictedLabel)
            : (info['name_en'] ?? _predictedLabel);
    final desc =
        widget.isArabic
            ? (info['desc_ar'] ?? 'لا توجد معلومات متاحة لهذا النبات.')
            : (info['desc_en'] ?? 'No information available for this plant.');
    final prep =
        widget.isArabic ? (info['prep_ar'] ?? '') : (info['prep_en'] ?? '');
    final probPct = (_predictedProb ?? 0.0) * 100;
    final confidenceText =
        widget.isArabic
            ? 'الثقة: ${_toArabicNumbers(probPct.toStringAsFixed(1))}%'
            : 'Confidence: ${probPct.toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.verified,
              color: Color.fromRGBO(0, 101, 46, 1.0),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              widget.isArabic ? 'النتيجة:' : 'Result:',
              style: TextStyle(
                fontSize: widget.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(0, 101, 46, 1.0),
                fontFamily:
                    widget.fontFamily == 'Default' ? null : widget.fontFamily,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromRGBO(0, 101, 46, 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: widget.fontSize + 1,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily:
                      widget.fontFamily == 'Default' ? null : widget.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 101, 46, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  confidenceText,
                  style: TextStyle(
                    fontSize: widget.fontSize - 1,
                    color: const Color.fromRGBO(0, 101, 46, 1.0),
                    fontWeight: FontWeight.w600,
                    fontFamily:
                        widget.fontFamily == 'Default'
                            ? null
                            : widget.fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: TextStyle(
                  fontSize: widget.fontSize - 1,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.4,
                  fontFamily:
                      widget.fontFamily == 'Default' ? null : widget.fontFamily,
                ),
              ),
              if (prep.isNotEmpty) const SizedBox(height: 12),
              if (prep.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 101, 46, 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 101, 46, 0.3),
                    ),
                  ),
                  child: Text(
                    prep,
                    style: TextStyle(
                      fontSize: widget.fontSize - 1,
                      color: const Color.fromRGBO(0, 101, 46, 1.0),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      fontFamily:
                          widget.fontFamily == 'Default'
                              ? null
                              : widget.fontFamily,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final bool isArabic;
  final double fontSize;
  final String fontFamily;
  final VoidCallback onClearHistory;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.isArabic,
    required this.fontSize,
    required this.fontFamily,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'سجل التعرّف' : 'Recognition History',
          style: TextStyle(
            fontFamily: fontFamily == 'Default' ? null : fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onClearHistory,
              tooltip: isArabic ? 'مسح السجل' : 'Clear History',
            ),
        ],
      ),
      body:
          history.isEmpty
              ? Center(
                child: Text(
                  isArabic ? 'لا يوجد سجل بعد' : 'No history yet',
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    color: Colors.grey,
                    fontFamily: fontFamily == 'Default' ? null : fontFamily,
                  ),
                ),
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
                        child:
                            kIsWeb && item['imageBytes'] != null
                                ? Image.memory(
                                  item['imageBytes'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                                : !kIsWeb && item['image'] != null
                                ? Image.file(
                                  item['image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                      ),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          fontFamily:
                              fontFamily == 'Default' ? null : fontFamily,
                          fontSize: fontSize,
                        ),
                      ),
                      subtitle: Text(
                        '${isArabic ? "الثقة" : "Confidence"}: ${(item['confidence'] * 100).toStringAsFixed(1)}%\n'
                        '${item['timestamp'].toString().split('.')[0]}',
                        style: TextStyle(
                          fontFamily:
                              fontFamily == 'Default' ? null : fontFamily,
                          fontSize: fontSize - 2,
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool isArabic;
  final bool isDarkMode;
  final double fontSize;
  final String fontFamily;
  final VoidCallback onLanguageChange;
  final VoidCallback onDarkModeToggle;
  final Function(double) onFontSizeChange;
  final Function(String) onFontFamilyChange;
  final Future<void> Function() onLogout;

  const SettingsScreen({
    super.key,
    required this.isArabic,
    required this.isDarkMode,
    required this.fontSize,
    required this.fontFamily,
    required this.onLanguageChange,
    required this.onDarkModeToggle,
    required this.onFontSizeChange,
    required this.onFontFamilyChange,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'الإعدادات' : 'Settings',
          style: TextStyle(
            fontFamily: fontFamily == 'Default' ? null : fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              isArabic ? 'اللغة' : 'Language',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize,
              ),
            ),
            subtitle: Text(
              isArabic ? 'العربية' : 'English',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize - 2,
              ),
            ),
            trailing: Switch(
              value: isArabic,
              onChanged: (_) => onLanguageChange(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(
              isArabic ? 'الوضع المظلم' : 'Dark Mode',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (_) => onDarkModeToggle(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(
              isArabic ? 'حجم الخط' : 'Font Size',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize,
              ),
            ),
            subtitle: Slider(
              value: fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: fontSize.round().toString(),
              onChanged: onFontSizeChange,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: Text(
              isArabic ? 'نوع الخط' : 'Font Family',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize,
              ),
            ),
            subtitle: DropdownButton<String>(
              value: fontFamily,
              isExpanded: true,
              items:
                  [
                    'Default',
                    'Roboto',
                    'Arial',
                    'Times New Roman',
                    'Courier New',
                  ].map((String font) {
                    return DropdownMenuItem<String>(
                      value: font,
                      child: Text(
                        font,
                        style: TextStyle(
                          fontFamily: font == 'Default' ? null : font,
                          fontSize: fontSize,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newFont) {
                if (newFont != null) {
                  onFontFamilyChange(newFont);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              isArabic ? 'تسجيل الخروج' : 'Logout',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize,
                color: Colors.red,
              ),
            ),
            onTap: () async {
              await onLogout();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              isArabic ? 'حول التطبيق' : 'About App',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize,
              ),
            ),
            subtitle: Text(
              isArabic
                  ? 'يساعد هذا التطبيق المستخدمين على تحديد النباتات الطبية في جنوب السودان فوراً من خلال التقاط صورة مباشرة أو تحميلها من المعرض. باستخدام تقنية التعلم العميق، يتعرف على النبات ويقدم معلومات مفصلة باللغتين العربية والإنجليزية - بما في ذلك قيمه الطبية وطرق التحضير والجرعة الموصى بها.'
                  : 'This app helps users identify South Sudanese medicinal plants instantly by either taking a live photo or uploading one from the gallery. Using deep learning technology, it recognizes the plant and provides detailed information in Arabic and English — including its medicinal values, preparation methods, and recommended dosage.\n\nDesigned to work offline and on low-resource devices, the app bridges traditional wisdom and modern innovation, ensuring that indigenous knowledge is preserved and accessible to everyone — from community health workers to students and traditional healers.\n\nMore than just a digital tool, this app celebrates culture, promotes safe herbal practices, and empowers users to connect with the healing power of nature through both technology and tradition.',
              style: TextStyle(
                fontFamily: fontFamily == 'Default' ? null : fontFamily,
                fontSize: fontSize - 2,
                height: 1.4,
              ),
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}
