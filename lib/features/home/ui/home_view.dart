import 'package:auto_route/auto_route.dart';
import 'package:slapp/features/auth/ui/account_view.dart';
import 'package:slapp/features/dashboard/ui/dashboard_view.dart';
import 'package:slapp/features/feed/ui/feed_view.dart';
import 'package:slapp/features/home/ui/widgets/home_drawer.dart';
import 'package:slapp/features/update/ui/update_available_dialog.dart';
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
  void initState() {
    super.initState();

    // The first screen, after the first frame, is the only place a dialog can
    // be shown at launch: MainApp is a StatelessWidget and there is no context
    // under a Navigator before this. The call fetches a small JSON and shows
    // nothing on any failure, so it is safe on every launch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        maybeShowUpdateDialog(context);
      }
    });
  }

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
