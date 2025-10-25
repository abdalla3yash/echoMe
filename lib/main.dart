import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(const EchoMeApp());
}

class EchoMeApp extends StatelessWidget {
  const EchoMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EchoMe Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const EchoScreen(),
    );
  }
}

class EchoScreen extends StatefulWidget {
  const EchoScreen({super.key});

  @override
  State<EchoScreen> createState() => _EchoScreenState();
}

class _EchoScreenState extends State<EchoScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _userText = '';
  String _aiResponse = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (error) => debugPrint("Speech error: $error"),
        onStatus: (status) => debugPrint("Speech status: $status"),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() => _userText = result.recognizedWords);
          },
          localeId: "ar-EG", 
        );
      } else {
        debugPrint("Speech recognition not available");
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      await _generateResponse();
    }
  }

  Future<void> _generateResponse() async {
    if (_userText.isEmpty) {
      setState(() => _aiResponse = "قولّي حاجة وأنا هرد عليك.");
      return;
    }

    String reply = _mockAI(_userText);
    setState(() => _aiResponse = reply);

    await _tts.setLanguage("ar");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.9);
    await _tts.speak(reply);
  }

  String _mockAI(String input) {
    input = input.toLowerCase();

    if (input.contains("تعبان")) {
      return "خد بالك من نفسك، واضح إنك محتاج ترتاح شوية.";
    } else if (input.contains("كويس")) {
      return "جميل، استمر بنفس الطاقة دي يا بطل.";
    } else if (input.contains("زعلان")) {
      return "ما تزعلش، كل حاجة بتعدي، خليك قوي.";
    } else {
      return "ممم... شكلك بتفكر كتير، احكيلي أكتر.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "EchoMe ",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              AvatarGlow(
                glowColor: Colors.greenAccent,
                animate: _isListening,
                child: FloatingActionButton(
                  backgroundColor: Colors.greenAccent,
                  onPressed: _listen,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                " أنت قلت:",
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                _userText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                " النسخة قالت:",
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                _aiResponse,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
