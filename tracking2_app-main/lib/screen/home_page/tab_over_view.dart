import 'package:flutter/material.dart';
import 'package:tracking2_app/screen/home_page/home_tab_screen.dart';

class TabOverView extends StatefulWidget {
  const TabOverView({Key? key}) : super(key: key);

  @override
  _TabOverViewState createState() => _TabOverViewState();
}

class _TabOverViewState extends State<TabOverView>
    with TickerProviderStateMixin {
  TabController? _controller;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      _controller!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    _controller = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: [HomeTabScreen(), Text(''), Text(''), Text('jd')],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rating'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.yellow,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        onTap: onItemClicked,
        currentIndex: selectedIndex,
      ),
    );
  }
}
