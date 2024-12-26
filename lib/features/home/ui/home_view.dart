import 'package:auto_route/auto_route.dart';
import 'package:fools_app_template/features/home/ui/widgets/home_drawer.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: HomeDrawer(),
      body: Center(
        child: selectedIndex == 0 ? Text('Hot') : Text('Cold'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatshot),
              label: 'One',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.snowing),
              label: 'Two',
            ),
          ]),
    );
  }
}
