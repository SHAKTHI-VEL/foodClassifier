import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  late File _image;
  List ? _output;
  final ImagePicker imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel();
  }

  detectimage(File image) async {
    print(image);
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 18,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5,
        );
  if(prediction!.isEmpty){
    setState(() {
      _output=null;
      loading=true;
    });
    return null;
  }
    setState(() {
      _output = prediction;
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickimage_camera() async {
     XFile? image = await imagepicker.pickImage(source: ImageSource.camera);
    print(image!.path);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimage_gallery() async {
    XFile ? image = await imagepicker.pickImage(source: ImageSource.gallery);
    print(image!.path);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fruit Classifier',
          
        ),
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
          children: [
            Container(
              height: 150,
              width: 150,
              padding: EdgeInsets.all(10),
              child: Image.asset('assets/fruits.png'),
            ),
            Container(
                child: Text('Fruit Detector',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))),
            SizedBox(height: 50),
            Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        
                        child: Text('Capture',
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          pickimage_camera();
                        }),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      
                        child: Text('Gallery',
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          pickimage_gallery();
                        }),
                  ),
                ],
              ),
            ),
            loading != true
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          // width: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Image.file(_image),
                        ),
                        _output != null
                            ? Text(
                                (_output![0]['label']).toString().substring(2),
                                style: TextStyle(fontSize: 18))
                            : Text(''),
                        _output != null
                            ? Text(
                                'Confidence: ' +
                                    (_output![0]['confidence']).toString(),
                                style: TextStyle(fontSize: 18))
                            : Text('')
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}