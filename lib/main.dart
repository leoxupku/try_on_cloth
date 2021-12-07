import 'package:flutter/material.dart';
import 'fitting_room.dart';

void main() => runApp(TryOnClothApp());

class TryOnClothApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState()=>_TryOnClothAppState();
}

class _TryOnClothAppState extends State<TryOnClothApp>{
  @override
  Widget build(BuildContext){
    return MaterialApp(
      title: 'Try On Cloth',
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Center(child: Text('Try On Cloth')),
            ),
            body: TabBarView(
              children: [
                const Center(child: Text('welcome to mall')),
                FittingRoom(),
                const Center(child: Text('welcome to payment')),
              ],
              physics: const NeverScrollableScrollPhysics(),
            ),
            bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                child: Container(
                  height: 50.0,
                  child: TabBar(
                      indicatorColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: const Color(0xFF151026),
                      labelColor: Theme.of(context).primaryColor,
                      tabs: const <Widget>[
                          Tab(icon: Icon(Icons.local_mall),),
                          Tab(icon: Icon(Icons.photo_camera),),
                          Tab(icon: Icon(Icons.shopping_cart),),
                      ]
                  ),
                )
            )
        )
      )
    );
  }
}