import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'URL Shortener',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UrlShortenerPage(),
    );
  }
}

class UrlShortenerPage extends StatefulWidget {
  const UrlShortenerPage({super.key});

  @override
  _UrlShortenerPageState createState() => _UrlShortenerPageState();
}

class _UrlShortenerPageState extends State<UrlShortenerPage> {
  final _urlController = TextEditingController();
  String _shortenedUrl = '';
  bool _loading = false;
  String _errorMessage = '';

  Future<void> _shortenUrl() async {
    final url = _urlController.text;
    if (url.isEmpty) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/url/shorten'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'originalUrl': url}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _shortenedUrl = responseData['shortUrl'];
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _shortenedUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Shortener'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _shortenUrl,
                    child: const Text('Shorten URL'),
                  ),
            const SizedBox(height: 16),
            if (_shortenedUrl.isNotEmpty) ...[
              const Text(
                'Shortened URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _shortenedUrl,
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _copyToClipboard,
                child: const Text('Copy to Clipboard'),
              ),
            ],
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
