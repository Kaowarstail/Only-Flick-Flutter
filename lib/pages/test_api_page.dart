import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/like_service.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _result = 'Ready to test API...';
  bool _loading = false;

  Future<void> _testContentsApi() async {
    setState(() {
      _loading = true;
      _result = 'Loading contents...';
    });

    try {
      final response = await ApiService.get('/contents');
      setState(() {
        _result = 'Success! Loaded ${response['contents']?.length ?? 0} contents';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testLikeApi() async {
    setState(() {
      _loading = true;
      _result = 'Testing like functionality...';
    });

    try {
      // Test toggle like on content ID 1 with a test user ID
      final result = await LikeService.toggleLike(1, "test-user-123");
      setState(() {
        _result = 'Like toggle success! Liked: $result';
      });
    } catch (e) {
      setState(() {
        _result = 'Like test error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testContentsApi,
              child: _loading 
                ? const CircularProgressIndicator() 
                : const Text('Test Contents API'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _testLikeApi,
              child: _loading 
                ? const CircularProgressIndicator() 
                : const Text('Test Like API (CORS)'),
            ),
            const SizedBox(height: 20),
            Text(
              'Result:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_result),
            ),
          ],
        ),
      ),
    );
  }
}
