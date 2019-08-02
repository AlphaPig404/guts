import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class LocalStorage{
	factory LocalStorage() => _getInstance();
	static LocalStorage get instance => _getInstance();
	static LocalStorage _instance ;
	String dirPath;

	LocalStorage._internal(){

	}

	void init() async {
		dirPath = (await getApplicationDocumentsDirectory()).path;
	}

	static LocalStorage _getInstance(){
		if(_instance == null){
			_instance = new LocalStorage._internal();
		}
		return _instance;
	}

	File setItem(String name, String value){
		File file = File('$dirPath$name');
		file.writeAsStringSync(value);
		return file;
	}

	File getItem(String name){
		File file = File('$dirPath$name');
		file.readAsStringSync();
		return file;
	}

	int removeItem(String name){
		File file = File('$dirPath$name');
		if(file.existsSync()){
			file.deleteSync();
		}
		return 0;
	}
}