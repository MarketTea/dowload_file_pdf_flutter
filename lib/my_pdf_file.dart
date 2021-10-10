// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';

class MyPdf extends StatefulWidget {
  const MyPdf({Key? key}) : super(key: key);

  @override
  _MyPdfState createState() => _MyPdfState();
}

class _MyPdfState extends State<MyPdf> {
  @override
  Widget build(BuildContext context) {
    const urlBook = "http://www.africau.edu/images/default/sample.pdf";
    var dio = Dio();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dowload file PDF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  String path =
                  await ExtStorage.getExternalStoragePublicDirectory(
                      ExtStorage.DIRECTORY_DOWNLOADS);
                  String fullPath = '$path/new_task.pdf';
                  downloadBook(dio, urlBook, fullPath);
                },
                child: const Text('Download PDF'))
          ],
        ),
      ),
    );
  }

  @override
  // ignore: must_call_super
  void initState() {
    getPermission();
  }

  void getPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  Future downloadBook(Dio dio, String urlBook, String savePath) async {
    try {
      Response response = await dio.get(
        urlBook,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }
        ),
      );

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if(total != 1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }
}
