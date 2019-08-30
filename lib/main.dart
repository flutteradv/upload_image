import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "upload image",
      home: UploadImage(),
    );
  }
}

class UploadImage extends StatefulWidget {
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  static const String urlEndpoint = 'http://192.168.43.34:3000/image';
  String status = '';
  Future<File> future;
  File tmpFile;
  String base64Image;
  String errMessage = 'Error Uploading Image';
  void chooseImage() async {
    setState(() {
      future = ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 1000,maxHeight: 1000);
    });
    setStatus('');
  }

  void setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  Widget showImage() {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.hasData) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(tmpFile.readAsBytesSync());
          return Flexible(
            child: Image.file(
              tmpFile,
              fit: BoxFit.cover,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error,
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return Center(
            child: Text(
              "No Image have Selected",
              textAlign: TextAlign.center,
            ),
          );
        }
      },
    );
  }

  void uploadImage() {
    setStatus('Uploading Image');
    if (tmpFile == null) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    uploadFile(fileName);
  }

  void uploadFile(String fileName) {
    http.post(urlEndpoint,body: {
      'image': base64Image,
      'name': fileName
    }).then((result){
      setStatus(result.statusCode == 200 ? result.body:errMessage);
    }).catchError((err){
      setStatus(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlineButton(
              onPressed: chooseImage,
              child: Text("Choose Image"),
            ),
            SizedBox(
              height: 20,
            ),
            showImage(),
            SizedBox(
              height: 20,
            ),
            OutlineButton(
              onPressed: uploadImage,
              child: Text("Upload Image"),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            )
          ],
        ),
      ),
    );
  }
}
