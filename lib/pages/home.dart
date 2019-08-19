import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gut/model/challenge.dart';
import 'package:gut/utils/common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gut/utils/api.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as JSON;

import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Challenge> playerChallengeList = [];
  List<Challenge> watcherChallengeList = [];
  TabController _tabController;
  int selectTabIndex = 0;
  List<String> tabList = ['Player', 'Watcher'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabList.length)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          print(selectTabIndex);
        } else {
          setState(() {
            selectTabIndex = _tabController.index;
          });
        }
      });
    getChallengeList('player');
    getChallengeList('watcher');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getChallengeList(String tabName) async {
    final int uid = Common.user.uid;
    if (tabName == 'player') {
      Response response =
          await Common.dio.get('${Apis.getChallengeList}?role=0&uid=$uid');
      List _challengeList = response.data;
      setState(() {
        playerChallengeList = _challengeList
            .map((challenge) => Challenge.fromJson(challenge))
            .toList();
      });
    } else if (tabName == 'watcher') {
      Response response =
          await Common.dio.get('${Apis.getChallengeList}?role=1&uid=$uid');
      List _challengeList = response.data;
      setState(() {
        watcherChallengeList = _challengeList
            .map((challenge) => Challenge.fromJson(challenge))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: tabList.map((tabName) {
              return _buildSuggestions(tabName);
            }).toList(),
          ),
        ));
  }

  Widget _buildAppBar() {
    final Color selecedTabColor = Color.fromARGB(255, 99, 99, 102);
    print('build home');
    List<Widget> _buildTabButtons() {
      List<Widget> tabs = [];
      Widget tab;
      tabList.asMap().forEach((index, value) {
        tab = Container(
            width: 90.0,
            height: 28,
            child: Tab(text: value),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: selectTabIndex == index
                  ? selecedTabColor
                  : Colors.transparent,
            ));
        tabs.add(tab);
      });
      return tabs;
    }

    return AppBar(
      title: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Color.fromARGB(255, 28, 28, 31),
        ),
        child: TabBar(
          labelPadding: EdgeInsets.all(0),
          indicatorWeight: 0.1,
          isScrollable: true,
          labelStyle: TextStyle(color: Colors.red),
          tabs: _buildTabButtons(),
          controller: _tabController,
        ),
      ),
      leading: Container(
        padding: EdgeInsets.fromLTRB(14.5, 16, 0, 0),
        child: Text(
          'GUT',
          style: Theme.of(context).textTheme.title,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed('/movieList');
          },
        )
      ],
    );
  }

  Widget _buildSuggestions(String tabName) {
    if (tabName == 'player') {
      return buildPlayerChanlenge(tabName, playerChallengeList);
    } else {
      return buildPlayerChanlenge(tabName, watcherChallengeList);
    }
  }

  Widget buildPlayerChanlenge(tabName, challengeList) {
    return new ListView.separated(
      padding: const EdgeInsets.all(10.0),
      itemCount: challengeList.length,
      itemBuilder: (context, i) {
        return _buildRow(tabName, challengeList[i]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

  Widget buildTitleSection(Challenge challenge) {
    final Map<String, Color> _levelColors = {
      'EASY': Colors.green,
      'HARD': Colors.yellow,
      'CRAZY': Colors.red
    };
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: _levelColors[challenge.level]),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text(challenge.level)
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: buildIcon(Icons.play_arrow, '0:50'),
        ),
        buildIcon(Icons.favorite, '${challenge.point} Point')
      ],
    );
  }

  void acceptChallenge(Challenge chanllenge) async {
    //   acceptChallenge
    Response response = await Common.dio.post(Apis.acceptChallenge,
        data: {"challenge_id": chanllenge.id, "uid": Common.user.uid});
    print(response.data);
    PermissionHandler().requestPermissions([
      PermissionGroup.camera,
      PermissionGroup.microphone
    ]).then((permissions) {
      final bool allGranted = permissions.values
          .every((value) => value == PermissionStatus.granted);
      if (allGranted) {
        Navigator.of(context).pushNamed('/recordVideo', arguments: chanllenge);
      }
    });
  }

  Widget buildDetailSection(String tabName, Challenge challenge) {
    final bool isWatcher = tabName == 'Watcher';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                challenge.title,
                softWrap: true,
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 4),
              Text(
                challenge.description,
                style: TextStyle(color: Color.fromARGB(255, 132, 132, 132)),
                softWrap: true,
              ),
              SizedBox(height: 20),
              Container(
                width: 74.5,
                height: 28,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Text(
                    isWatcher ? 'Watch' : 'Accept',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () {
                    isWatcher
                        ? Navigator.of(context).pushNamed('/watchRoom')
                        : acceptChallenge(challenge);
                  },
                  color: Color.fromARGB(25, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(60))),
                  textColor: isWatcher ? Colors.blue : Colors.yellow,
                ),
              )
            ],
          ),
        ),
        Container(
          width: 92,
          height: 92,
          padding: EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              image: DecorationImage(
                image: NetworkImage(challenge.cover),
                fit: BoxFit.cover,
              )),
        )
      ],
    );
  }

  Widget buildIcon(IconData icon, String label) {
    return Container(
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _buildRow(String tabName, Challenge challenge) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          buildTitleSection(challenge),
          SizedBox(height: 20),
          buildDetailSection(tabName, challenge),
        ],
      ),
    );
  }
}
