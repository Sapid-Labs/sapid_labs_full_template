import 'package:auto_route/auto_route.dart';
import 'package:cotr_flutter_app/features/home/ui/widgets/home_drawer.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: HomeDrawer(),
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
