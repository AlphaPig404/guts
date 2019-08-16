import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as JSON;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gut/utils/api.dart';
import 'package:gut/utils/common.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  @override
  createState() => new LoginState();
}

class LoginState extends State<LoginPage> {
  Widget _buildRigisterRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'New user?',
            style: Theme.of(context).textTheme.body1,
          ),
          SizedBox(
              width: 70.0,
              height: 36,
              child: FlatButton(
                child: Text(
                  'Register',
                  style: Theme.of(context).textTheme.body1,
                ),
                padding: EdgeInsets.all(0),
                onPressed: () => Navigator.of(context).pushNamed('/register'),
              ))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget contentSection = Container(
      alignment: AlignmentDirectional.center,
      height: 400,
      child: Column(
        children: <Widget>[
          Text('WELCOME TO GUT',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title),
          LoginForm(),
          _buildRigisterRow()
        ],
      ),
    );

    return Scaffold(
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/background.png",
                  fit: BoxFit.cover,
                  color: Color.fromARGB(210, 43, 43, 48),
                  colorBlendMode: BlendMode.hardLight,
                  height: MediaQuery.of(context).size.height,
                ),
                contentSection
              ],
            ),
          )),
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  createState() => new LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final storage = new FlutterSecureStorage();
  String _captcha='', _phone='';
  String areaCodes = '';
  String _areaCode = '65';
  bool _isSendCaptcha = false;
  int _countDown = 60;

  @override
  void initState() {
    initAreaCode();
    super.initState();
  }

  void initAreaCode() {
    Future<String> loadString =
        rootBundle.loadString('assets/data/area_code.json');
    loadString.then((String value) {
      setState(() {
        areaCodes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 60.5),
        width: 250,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              buildPhoneTextField(),
              SizedBox(height: 10),
              buildPasswordTextField(context),
              SizedBox(height: 35),
              buildSubmitButton(),
            ],
          ),
        ));
  }

  void _submitValues() async {
    if (_phone.isNotEmpty && _captcha.isNotEmpty) {
      try {
        Response response = await Common.dio.post(Apis.login,
            data: {"area_code": _areaCode, "code": _captcha, "phone": _phone});	
		await storage.write(key: 'user', value: response.toString());
        Navigator.of(context).popAndPushNamed('/home');
      } on DioError catch (e) {
        if (e.response != null) {
		  Toast.show(e.response.data['msg'], context,duration: Toast.LENGTH_LONG);
        } else {
          print(e.request);
          print(e.message);
        }
      }
    }
  }

  void startCountDown() {
    setState(() {
      _isSendCaptcha = true;
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countDown > 0) {
        setState(() {
          _countDown--;
        });
      } else {
        timer.cancel();
        timer = null;
        setState(() {
          _isSendCaptcha = false;
          _countDown = 60;
        });
      }
    });
  }

  Widget buildSubmitButton() {
    return ButtonTheme(
        buttonColor: Color.fromARGB(255, 244, 249, 151),
        textTheme: ButtonTextTheme.normal,
        height: 44,
        minWidth: 250,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: RaisedButton(
            child: Text('Confirm',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            onPressed: _submitValues));
  }

  Widget buildPhoneTextField() {
    List<DropdownMenuItem> generateItemList() {
      List<DropdownMenuItem> items = new List();
      if (areaCodes.isNotEmpty) {
        Map<String, dynamic> area = JSON.jsonDecode(areaCodes);
        List<dynamic> list = new List();
        area.forEach((k, v) {
          list.addAll(v);
        });
        list.sort();
        list.forEach((value) {
          String str = value as String;
          items.add(DropdownMenuItem(
              value: (str.split(',')[1]).substring(1),
              child: Text(str.split(',')[1])));
        });
      }
      return items;
    }

    var container = Container(
        width: 100,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              items: generateItemList(),
              isExpanded: true,
              hint: Text(
                '+65',
                style: Theme.of(context).textTheme.body1,
              ),
              value: _areaCode,
              onChanged: (value) {
                setState(() {
                  _areaCode = value;
                });
              },
            ),
          ),
        ));
    return Container(
        height: 44,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 72, 72, 76),
            border: Border.all(
                width: 1.0, color: Color.fromARGB(51, 255, 255, 255)),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          children: <Widget>[
            container,
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                cursorColor: Colors.white,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(13),
                ],
                decoration: InputDecoration(
                    labelText: 'Phone No.',
                    border: InputBorder.none,
                    hasFloatingPlaceholder: false,
                    contentPadding: EdgeInsets.fromLTRB(12.5, 15, 12.5, 15)),
                onChanged: (String value) {
                  setState(() {
                    _phone = value;
                  });
                },
              ),
            )
          ],
        ));
  }

  Widget buildPasswordTextField(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          height: 44,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 72, 72, 76),
              border: Border.all(
                  width: 1.0, color: Color.fromARGB(51, 255, 255, 255)),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: TextField(
            keyboardType: TextInputType.number,
            cursorColor: Colors.white,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
                labelText: 'Captcha',
                hasFloatingPlaceholder: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(12.5, 15, 12.5, 15)),
            onChanged: (String value) {
              setState(() {
                _captcha = value;
              });
            },
          ),
        )),
        _isSendCaptcha
            ? Container(
                width: 80.0,
                height: 48.0,
                child: Center(
                    child: Text(
                  '$_countDown s',
                )))
            : ButtonTheme(
                minWidth: 50.0,
                child: FlatButton(
                  child: Text(
                    'Send OTP',
                    style: TextStyle(color: Color.fromARGB(255, 255, 210, 0)),
                  ),
                  onPressed: () {
                    if (_phone.isNotEmpty) {
                      startCountDown();
                      Common.dio.post(Apis.getCode, data: {
                        "phone": _phone,
                        "area_code": _areaCode,
                        "user_agent": ''
                      }).then((res) {
                        print('send otp');
                      });
                    }
                  },
                  padding: null,
                ))
      ],
    );
  }
}
