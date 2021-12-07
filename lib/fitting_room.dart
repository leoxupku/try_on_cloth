import 'package:flutter/material.dart';
import 'three_screen.dart';

class FittingRoom extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_FittingRoomState();
}

class Commodity{
  String uuid = "0";
  String? iconUrl;
  String? assetUrl;

  Commodity(String _uuid, String _iconUrl, String _assetUrl){
    uuid = _uuid;
    iconUrl = _iconUrl;
    assetUrl = _assetUrl;
  }
}

class CommodityCategory{
  String label = "unknown";
  List<Commodity> commodities = [];
  int activeIndex = -1;

  CommodityCategory(String _label, List<Commodity> _commodities){
    label = _label;
    commodities = _commodities;
  }
}

class _FittingRoomState extends State<FittingRoom> {
  List<CommodityCategory> categories = [
    CommodityCategory('cloth', [
      Commodity('1', '1', '1'),
      Commodity('2', '2', '2'),
    ]),
    CommodityCategory('pants', [
      Commodity('3', '3', '3'),
      Commodity('4', '4', '4'),
    ]),
    CommodityCategory('shoes', [
      Commodity('5', '5', '5'),
      Commodity('6', '6', '6'),
    ]),
  ];
  int _selectedCategory = 0;

  List<Widget> generateGridItem(List<Commodity> commodities){
    Iterable<GridTile> ret = commodities.map((e) => GridTile(
      key: Key(e.uuid),
      footer: Container(
        height: 20,
        child: GridTileBar(
          backgroundColor: const Color(0x44000000),
          title: Center(child: Text(e.uuid)),
        ),
      ),
      child: const Image(image: AssetImage('images/cloth.jpeg'))
    ));
    return ret.toList();
  }

  Widget generateThreeJsScreen(){
    return Text('dfsdf');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: ThreeJsScreen(key: Key('ThreeJsScreen'))),
        const Divider(height: 1, thickness: 1,),
        Container(
          height: 150,
          child: GridView.count(
            crossAxisCount: 4,
            //scrollDirection: Axis.horizontal,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
            children: generateGridItem(categories[_selectedCategory].commodities)
          ),
        ),
        const Divider(height: 1, thickness: 1,),
        BottomNavigationBar(
            items: [
              for(var e in categories)
                BottomNavigationBarItem(
                  label: e.label,
                  backgroundColor: Colors.grey,
                  icon: const Icon(Icons.favorite),
                )
            ],
            currentIndex: _selectedCategory,
            onTap: (int index)=>setState(() {
              _selectedCategory = index;
            }),
            showSelectedLabels: true,
        ),
        const Divider(height: 1, thickness: 1,),
      ],
    );
  }
}