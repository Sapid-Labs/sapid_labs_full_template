import 'package:auto_route/auto_route.dart';
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
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: HomeDrawer(),
      body: IndexedStack(
        index: index.value,
        children: [
          Text("Home"),
          Text("Chat"),
          Text("RSS"),
          Text("AI")
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        onTap: (value){
          index.value = value;
        },
        items: [
        BottomNavigationBarItem(
          label: "Home",
          icon: Icon(Icons.home_outlined),
        ),
        BottomNavigationBarItem(
          label: "Chat",
          icon: Icon(Icons.chat_bubble_outline),
        ),
         BottomNavigationBarItem(
          label: "RSS",
          icon: Icon(Icons.rss_feed_outlined),
        ),
        BottomNavigationBarItem(
          label: "AI",
          icon: Icon(Icons.android_outlined),
        )
      ]),
    );
  }
}
