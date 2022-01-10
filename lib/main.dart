import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:translator/translator.dart';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:splashscreen/splashscreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'மருந்தறி',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 8,
      navigateAfterSeconds: new Home(),
      title: new Text('மருந்தறி',textScaleFactor: 2,),
      image: new Image.asset('assets/StartImage.jpeg'),
      loadingText: Text("உங்கள் மாத்திரைகளை அறிந்துகொள்ளுங்கள்"),
      photoSize: 100.0,
      loaderColor: Colors.brown,
    );
  }
}

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}


bool _scancheck = false;
String _text = '';
var decodedData;
String tamTransliterations = '';
var translation;
final translator = GoogleTranslator();
String fintext = '';

var details = {'paracetamol':'பெயர்: பாராசிட்டமால். \nமருந்தளவு:650 மி.கி. \nபரிந்துரைக்கப்பட்டது: பெரியவருகளுக்கு மட்டும். காய்ச்சல் மற்றும் தலைவலிக்கு ஏற்றது. \n12 வயதுக்குட்பட்ட குழந்தைகளுக்கு மாத்திரை பயன்படுத்த குடாது. ஒவ்வொரு டோஸுக்கும் இடையில் 4 முதல் 6 மணிநேர இடைவெளியை கடைபிடிக்க வேண்டும், மேலும் ஒரு நாளைக்கு 4 மாத்திரைகளுக்கு மேல் எடுக்கக்கூடாது.',
  'cetrizine':'பெயர்: செடிரிசின். \nமருந்தளவு: 5 மி.கி. \nபரிந்துரைக்கப்பட்டது:  ஒவ்வாமைக்கு இரவு நேரத்தில் எடுத்துக் கொள்ளுங்கள். \nஉணவுடன் அல்லது உணவு இல்லாமலும் எடுத்துக் கொள்ளலாம். மேலும் 24 மணி நேரத்தில் 10 மில்லி கிராமிற்கு மேல் எடுக்கக்கூடாது. \n6 மாதங்களுக்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம்.',
  'meftal':'பெயர்: மெஃப்டல் ஸ்பாக்கள். \nமருந்தளவு: 500 மி.கி. \nபரிந்துரைக்கப்பட்டது: வயிற்று வலிக்கு ஏற்றது. \nமாதவிடாய் வலி மற்றும் பிடிப்புகளின் அறிகுறிகளை நீக்குகிறது. உணவுடன் எடுத்துக் கொள்ளுமாறு பரிந்துரைக்கப்படுகிறது. \n6 மாதங்களுக்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.',
  'azithromycintablets':'பெயர்: அசித்ரோமைசின். \nமருந்தளவு: 500 மிகி \nநுண்ணுயிர்க்கொல்லி மாத்திரையாகும். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம். 5 மாதங்கள் தவிர அதற்கு மேற்பட்ட குழந்தைகள், பெரியவருகள் எடுத்துக்கொள்ளலாம்.',
  'vominorm':'பெயர்: வொமிநொர்ம். \nபரிந்துரைக்கப்பட்டது: வாந்தி உணர்வை குணப்படுத்த ஏற்றது. \n13 வயதிற்கு கீழ் உள்ள குழந்தைகளை தவிர மீதி எல்லா வயதினரும் எடுத்துக்கொள்ளலாம். கர்ப்பிணிப் பெண்கள் மருத்துவரின் ஆலோசனைக்குப் பிறகு எடுத்துக்கொள்ளலாம்.'};

class _HomeState extends State<Home> {

  File? _image;



  _imgFromCamera() async {
    File image = (await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    ));

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = (await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    ));

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('புகைப்பட தொகுப்பு'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('ஒளிப்படக்கருவி (கேமரா)'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  _converter() {
    String test = _text.toLowerCase();
    if (test.contains('paracetamol')){
      return details['paracetamol'];
    }
    else if (test.contains('cetrizine')){
      return details['cetrizine'];
    }
    else if (test.contains('meftal')){
      return details['meftal'];
    }
    else if (test.contains('vominorm')){
      return details['vominorm'];
    }
    else if (test.contains('azithromycintablets')){
      return details['azithromycintablets'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('மருந்தறி'),),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 32,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(
                    _image as File,
                    width: 400,
                    height: 400,
                    fit: BoxFit.fitHeight,
                  ),
                )
                    : Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50)),
                    width: 400,
                    height: 400,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("படத்தை தேர்ந்தெடுக்கவும்"),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(

        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        onPressed: () async {
          setState(() {
            _scancheck = true;
          });
          _text =
          await FlutterTesseractOcr.extractText(_image!.path);
          setState(() {
            _scancheck = false;
          });
          print(_text);
          fintext = _converter();
          Navigator.push(context, MaterialPageRoute(builder: (context) => output()), );
        },
        label: Text('மொழிபெயர்'),
      ),
    );
  }
}
class output extends StatefulWidget {
  @override
  _outputState createState() => _outputState();
}
class _outputState extends State<output> {

  FlutterTts Tts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('மருந்தறி'),
          backgroundColor: Colors.brown),
      body: Container(

        alignment: Alignment.center,

        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(child: Text(fintext, textAlign: TextAlign.center,)),
            FlatButton(
              color: Colors.brown,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Home()));
              },
              child: Text('பின் செல்'),
            ),
            FlatButton(
              color: Colors.brown,
              textColor: Colors.white,
              onPressed: () async {
                var isGoodLanguage = await Tts.isLanguageAvailable("ta");
                print(isGoodLanguage);
                await Tts.setLanguage("ta");
                Tts.speak(fintext);
                setState(() {

                });
              },
              child: Text('குரல் மூலம் மொழிபெயர்க்க'),
            ),
          ],
        ),
      ),
    );
  }
}