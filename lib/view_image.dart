import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_app/gallery.dart';

class ImageView extends StatelessWidget {
  final List<Gallery> data;
  final int index;

  const ImageView({Key? key, required this.data, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: GestureDetector(
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete'),
                        content: Text('Do you want to delete this image?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('NO')),
                          TextButton(
                              onPressed: () {
                                data[index].delete();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Yes'))
                        ],
                      );
                    });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(
                  File(data[index].imagePath),
                  height: 500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
