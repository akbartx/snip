import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:dart_style/dart_style.dart';
import '../code_example.dart';
import 'package:flutter/services.dart'; // Import for Clipboard

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _selectedLanguage = 'dart';
  String? _gistUrl; // To store the generated Gist URL

  final customTheme = {
    'root': TextStyle(backgroundColor: Colors.black87, color: Colors.white),
    'keyword': TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
    'literal': TextStyle(color: Colors.orange),
    'section': TextStyle(color: Colors.blue),
    'attribute': TextStyle(color: Colors.blueAccent),
    'symbol': TextStyle(color: Colors.yellow),
    'bullet': TextStyle(color: Colors.orange),
    'string': TextStyle(color: Colors.green),
    'built_in': TextStyle(color: Colors.redAccent),
    'meta': TextStyle(color: Colors.grey),
    'deletion': TextStyle(color: Colors.redAccent, backgroundColor: Colors.black),
    'addition': TextStyle(color: Colors.greenAccent, backgroundColor: Colors.black),
    'comment': TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
    'tag': TextStyle(color: Colors.blueAccent),  // Tag names in HTML/XML
    'name': TextStyle(color: Colors.yellow),  // Attribute names in HTML/XML
    'attr': TextStyle(color: Colors.orange),  // Attribute values in HTML/XML
  };

  // Simpan token akses pribadi Anda di sini untuk demonstrasi.
  // Pastikan untuk mengganti ini dengan metode penyimpanan yang lebih aman.
  final String githubAccessToken = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snip'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                maxLines: 10,
                style: TextStyle(color: Colors.white),
                onChanged: (text) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Paste code disini',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                    _controller.text = CodeExamples.examples[_selectedLanguage] ?? '';
                  });
                },
                items: CodeExamples.languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _takeScreenshot,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text('Convert to Image'),
                ),
                ElevatedButton(
                  onPressed: _downloadScreenshot,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text('Download Image'),
                ),
                ElevatedButton(
                  onPressed: _shareLink,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text('Share Link'),
                ),
                ElevatedButton(
                  onPressed: _formatCode,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: Text('Format Code'),
                ),
              ],
            ),
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: HighlightView(
                    _controller.text,
                    language: _selectedLanguage,
                    theme: customTheme,
                    padding: EdgeInsets.all(12),
                    textStyle: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            if (_gistUrl != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Share this link:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_gistUrl != null) {
                          Clipboard.setData(ClipboardData(text: _gistUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Link copied to clipboard!')),
                          );
                        }
                      },
                      child: Text(
                        _gistUrl!,
                        style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
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

  void _takeScreenshot() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Screenshot captured successfully!'),
        ),
      );
    }
  }

  void _downloadScreenshot() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      final blob = html.Blob([image]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "code_snippet.png")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  void _shareLink() async {
    final gistUrl = await _createGist(_controller.text);
    if (gistUrl != null) {
      setState(() {
        _gistUrl = gistUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share this link: $gistUrl'),
        ),
      );
    }
  }

  Future<String?> _createGist(String content) async {
    final url = Uri.parse('https://api.github.com/gists');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $githubAccessToken',
      },
      body: jsonEncode({
        "description": "Code snippet",
        "public": true,
        "files": {
          "snippet.txt": {
            "content": content,
          }
        }
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['html_url'];
    } else {
      print('Failed to create gist: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  void _formatCode() async {
    String formattedCode = _controller.text;
    try {
      if (_selectedLanguage == 'dart') {
        final formatter = DartFormatter();
        formattedCode = formatter.format(_controller.text);
      } else {
        formattedCode = await _formatCodeWithApi(_controller.text, _selectedLanguage);
      }
      setState(() {
        _controller.text = formattedCode;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to format code: $e')),
      );
    }
  }

  Future<String> _formatCodeWithApi(String code, String language) async {
    final url = Uri.parse('https://prettier.io/playground'); // URL of a code formatting API
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': code,
        'parser': language,
        'options': {}
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['formatted'];
    } else {
      throw Exception('Failed to format code');
    }
  }
}
