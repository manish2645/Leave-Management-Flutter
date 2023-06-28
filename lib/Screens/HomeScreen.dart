import 'package:flutter/material.dart' show AppBar, BuildContext, DefaultTabController, Scaffold, StatelessWidget, Tab, TabBar, TabBarView, Text, Widget;
import 'LeaveFormScreen.dart' show MyForm;
import 'ViewTableScreen.dart' show ViewTablePage;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Leave Management'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Leave Form'),
                Tab(text: 'Applied Leaves'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              MyForm(),
              ViewTablePage(),
            ],
          ),
        ),
      ),
    );
  }
}