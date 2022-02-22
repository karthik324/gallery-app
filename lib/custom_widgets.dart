import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_app/gallery.dart';
import 'package:gallery_app/view_image.dart';

class CustomImageTile extends StatelessWidget {
  final dynamic imagePath;
  final List<Gallery> imageBox;
  final int index;

  const CustomImageTile({
    Key? key,
    required this.imagePath,
    required this.imageBox,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ImageView(
                    data: imageBox,
                    index: index,
                  )));
        },
        child: Container(
          padding: EdgeInsets.all(30),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Image.file(
                File(imagePath),
                height: 450,
                width: 450,
              )),
        ),
      ),
    );
  }
}
