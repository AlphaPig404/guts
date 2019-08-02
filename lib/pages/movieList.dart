import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gut/pages/videoEdit.dart';
import 'package:gut/utils/common.dart';

class MovieListPage extends StatelessWidget {
  final Directory directory = Common.movieDir;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MovieList'),
        ),
        body: buildBody());
  }

  Widget buildBody() {
    Widget divider = Divider(color: Colors.green);
    List<FileSystemEntity> fileList = directory.listSync().toList();

    if (fileList.isEmpty) {
      return Center(
        child: Text('There is no files'),
      );
    } else {
      return ListView.separated(
        itemCount: fileList.length,
        itemBuilder: (BuildContext context, int index) {
		  File file = fileList[index];
          return ListTile(
            title: Text(file.path),
			subtitle: Text(file.path),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
				  file.deleteSync();
			  },
            ),
			onTap: (){
				Navigator.of(context).pushNamed('/videoEdit', arguments: VideoEditPageAguments(file.path));
			},
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return divider;
        },
      );
    }
  }
}
