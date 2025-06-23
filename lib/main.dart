import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(); // Charge les variables d’environnement depuis .env
  runApp(const OnlyFlickApp());
}

class OnlyFlickApp extends StatelessWidget {
  const OnlyFlickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlyFlick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiUrl = dotenv.env['API_URL'] ?? 'Non défini';

    return Scaffold(
      appBar: AppBar(
        title: const Text('OnlyFlick Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenue sur OnlyFlick 👋'),
            const SizedBox(height: 16),
            Text('API utilisée : $apiUrl'),
          ],
        ),
      ),
    );
  }
}
