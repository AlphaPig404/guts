import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<String> videoList = [];
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    print('build');
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
    return new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        // If you've reached at the end of the available word pairs...
        if (index >= videoList.length) {
          videoList.addAll(['aaa']);
        }
        return _buildRow(tabName, videoList[index]);
      },
    );
  }

  Widget buildTitleSection() {
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
                      color: Colors.green),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text('Easy')
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: buildIcon(Icons.play_arrow, '0:50'),
        ),
        buildIcon(Icons.favorite, '888Point')
      ],
    );
  }

  Widget buildDetailSection(String tabName) {
    final bool isWatcher = tabName == 'Watcher';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Sing in a full resturant',
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 4),
              Text(
                'Wherever you are, please sing in aaaa full resturant',
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
                        : PermissionHandler().requestPermissions([PermissionGroup.camera, PermissionGroup.microphone]).then((permissions){
							final bool allGranted = permissions.values.every((value) => value == PermissionStatus.granted);
							if(allGranted){
								Navigator.of(context).pushNamed('/recordVideo');
							}
						});
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
          width: 84,
          height: 84,
          padding: EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/250?image=9'),
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

  Widget _buildRow(String tabName, video) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          buildTitleSection(),
          SizedBox(height: 20),
          buildDetailSection(tabName),
        ],
      ),
    );
  }
}
