import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'place.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Place place;

  PlaceDetailsScreen({required this.place});

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  Map<String, String> translations = {};
  String? selectedText;
  bool _showSearchIcon = false;

  Future<void> _translate(String text) async {
    final translation = await translator.translate(text, from: 'ar', to: 'en');
    setState(() {
      translations[text] = translation.text;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  /// ✅ دالة فتح ويكيبيديا بعد التعديل
  Future<void> _openWikipedia() async {
  final Uri url = Uri.parse(widget.place.url.trim());

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ الرابط غير صحيح أو غير مدعوم')),
    );
  }
}
  void _toggleSearchIcon() {
    setState(() {
      _showSearchIcon = !_showSearchIcon;
    });
  }

  Widget buildInteractiveText(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedText = (selectedText == text) ? null : text;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          if (selectedText == text)
            Row(
              children: [
                TextButton.icon(
                  icon: Icon(Icons.volume_up,color: const Color.fromARGB(255, 5, 81, 144),),
                  label: Text('اقرأ'),
                  onPressed: () => _speak(text),
                ),
                TextButton.icon(
                  icon: Icon(Icons.translate,color: const Color.fromARGB(255, 5, 81, 143),),
                  label: Text('ترجم'),
                  onPressed: () => _translate(text),
                ),
              ],
            ),
          if (translations.containsKey(text))
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                translations[text]!,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color.fromARGB(255, 31, 6, 97),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name,style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 2, 34, 103),
      ),
      backgroundColor: const Color.fromARGB(255, 211, 209, 211),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _toggleSearchIcon,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    place.image,
                    width: double.infinity,
                    height: 230,
                    fit: BoxFit.cover,
                  ),
                  if (_showSearchIcon)
                    Container(
                      width: double.infinity,
                      height: 230,
                      color: Colors.black.withOpacity(0.4),
                      child: Center(
                        child: IconButton(
                          iconSize: 64,icon: Icon(Icons.search, color: Colors.white),
                          onPressed: _openWikipedia,
                          tooltip: 'فتح ويكيبيديا',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInteractiveText(place.description),
                  Divider(),
                  Text(
                    'أفضل أوقات الزيارة',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  buildInteractiveText(
                      'أنسب وقت لزيارة ${place.name} هو من مايو إلى سبتمبر حيث يكون الجو معتدلًا ومناسبًا للسياحة.'),
                  Divider(),
                  Text(
                    'أهم الأماكن القريبة',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  buildInteractiveText(
                      'توجد أماكن مميزة بالقرب من ${place.name} مثل متاحف وأسواق وحدائق خلابة.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}