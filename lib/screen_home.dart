import 'dart:io';
import 'package:gallery_app/custom_widgets.dart';
import 'package:gallery_app/gallery.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:ext_storage/ext_storage.dart';
// import 'package:external_path/external_path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  dynamic _imagePath;
  var box = Hive.box<Gallery>('gallery');
  File? directoryFile;
  var externaldir;
  String? externaldirPath;

  makeStorage() async {
    externaldir = await getExternalStorageDirectory();
    String newPath = "";
    print(externaldir);
    List<String> directoryList = externaldir!.path.split('/');
    for (int i = 1; i < directoryList.length; i++) {
      String tempPath = directoryList[i];
      if (directoryList[i] != 'Android') {
        newPath += "/" + tempPath;
      } else {
        break;
      }
    }
    newPath += "/Gallery App";
    print(newPath);
    externaldir = Directory(newPath);
    externaldirPath = externaldir.path;
    print(externaldirPath);
    if (!await externaldir.exists()) {
      await externaldir.create(recursive: true);
    }
  }

  Future getImage() async {
    _image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (_image != null) {
      final path = basename(_image!.path);
      directoryFile = await File(_image!.path).copy('$externaldirPath/$path');
      setState(() {
        _imagePath = directoryFile!.path;
        box.add(Gallery(imagePath: _imagePath));
      });
    }
    print('$_imagePath');
    return null;
  }

  getPermission() async {
    var checkStatus = await Permission.camera.status;
    if (checkStatus.isGranted) {
      getPermissionStorage();
    } else if (checkStatus.isDenied) {
      await Permission.camera.request();
      if (checkStatus.isGranted) {
        getPermissionStorage();
      }
    } else {
      SnackBar(
        content: Text(
          'Please enable camera permission to continue',
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.white,
      );
      // openAppSettings();
    }
  }

  getPermissionStorage() async {
    var storagePermission = await Permission.storage.status;
    var managePermission = await Permission.manageExternalStorage.status;
    var mediaPermission = await Permission.accessMediaLocation.status;
    if (storagePermission.isGranted &&
        managePermission.isGranted &&
        mediaPermission.isGranted) {
      makeStorage();
      if (await externaldir.exists()) {
        getImage();
      }
    } else if (storagePermission.isDenied ||
        managePermission.isDenied ||
        mediaPermission.isDenied) {
      await Permission.storage.request();
      await Permission.accessMediaLocation.request();
      await Permission.manageExternalStorage.request();
      if (storagePermission.isGranted && managePermission.isGranted) {
        makeStorage();
        if (await externaldir.exists()) {
          getImage();
        }
      }
    } else {
      SnackBar(
          content: Text(
        'Enable Permission ',
        style: TextStyle(color: Colors.red),
      ));
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
          centerTitle: true,
          elevation: 10,
        ),
        body: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder:
                (BuildContext context, Box<Gallery> imagebox, Widget? child) {
              List key = imagebox.keys.toList();
              // List imagevalues = imagebox.values.toList();
              return key.isEmpty
                  ? Center(child: Text('Add images'))
                  : GridView.builder(
                      itemCount: key.length,
                      // mainAxisSpacing: 10,
                      // crossAxisSpacing: 10,
                      // crossAxisCount: 2,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 300,
                      ),
                      itemBuilder: (context, index) {
                        List<Gallery> images = imagebox.values.toList();
                        return CustomImageTile(
                          imagePath: images[index].imagePath,
                          imageBox: images,
                          index: index,
                        );
                      },
                      // children: [
                      //   if (imagePath != null)
                      //     Padding(
                      //       padding: const EdgeInsets.only(top: 10),
                      //       child: ClipRRect(
                      //         child: Image.file(
                      //           File(imagePath!),
                      //           width: 100,
                      //           height: 100,
                      //         ),
                      //         borderRadius: BorderRadius.circular(20),
                      //       ),
                      //     ),
                      // ],
                    );
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              getPermission();
            },
            child: Icon(Icons.camera_alt)));
  }
}
