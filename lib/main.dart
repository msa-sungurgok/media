// Uygulama Ana Giriş Noktası
// Açıklama: Flutter uygulaması bu main() fonksiyonundan başlar
// Supabase konfigürasyonu, tema ayarları ve ana ekran burada tanımlanır

import 'package:flutter/material.dart';

void main() {
  // TODO: Supabase'i başlat
  // TODO: Yerel veritabanı başlat
  // TODO: Tema ayarlarını yükle
  // TODO: Versiyon kontrol et
  
  runApp(const MediaStreamingApp());
}

class MediaStreamingApp extends StatelessWidget {
  const MediaStreamingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Media Platform',
      theme: ThemeData(
        // Açıklama: Aydınlık tema ayarları
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        // Açıklama: Karanlık tema ayarları (varsayılan)
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
      // TODO: Ana navigasyon yapısı ekle
    );
  }
}

/// Splash Screen - Uygulama yüklenirken gösterilir
/// Açıklama: Versiyon kontrol, Supabase bağlantı ve tema yüklemesi burada yapılır
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Uygulamayı başlat
  /// Açıklama: Tüm başlangıç işlemleri burada yapılır
  /// 1. Supabase bağlantısını kur
  /// 2. Yerel ayarları yükle
  /// 3. Versiyon kontrol et
  /// 4. Kullanıcı oturum durumunu kontrol et
  /// 5. Ana ekrana git
  Future<void> _initializeApp() async {
    // TODO: Supabase başlatma
    // TODO: Yerel veritabanı başlatma
    // TODO: Versiyon kontrolü
    // TODO: Kullanıcı oturum kontrolü
    
    // Geçici: 2 saniye sonra ana ekrana git
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Logo ekle
            const SizedBox(height: 20),
            const Text('Digital Media Platform'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
