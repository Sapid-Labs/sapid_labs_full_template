import 'package:auto_route/auto_route.dart';
import 'package:foolscript/features/home/ui/widgets/home_drawer.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: HomeDrawer(),
      body: ListView()
    );
  }
}
