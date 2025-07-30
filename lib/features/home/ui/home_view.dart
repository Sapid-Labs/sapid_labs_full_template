import 'package:auto_route/auto_route.dart';
import 'package:slapp/features/auth/ui/account_view.dart';
import 'package:slapp/features/dashboard/ui/dashboard_view.dart';
import 'package:slapp/features/feed/ui/feed_view.dart';
import 'package:slapp/features/home/ui/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SignalsMixin {
  late final index = createSignal<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index.value,
          children: [
            DashboardView(),
            FeedView(),
            AccountView(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        showUnselectedLabels: false,
        onTap: (value) {
          index.value = value;
        },
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            label: "Feed",
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem(
            label: "Settings",
            icon: Icon(Icons.settings),
          )
        ],
      ),
    );
  }
}
