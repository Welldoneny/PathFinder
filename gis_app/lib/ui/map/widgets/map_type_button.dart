import 'package:flutter/material.dart';
import 'package:gis_app/ui/core/widgets/button_style.dart';
import 'package:gis_app/ui/map/widgets/map_tile_widget.dart';

class MapTypeButton extends StatelessWidget {
  const MapTypeButton({
    super.key,
    this.style,
    this.currentType = 'osm',
    required this.onTypeChanged,
  });

  final ButtonStyle? style;
  final String currentType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isPhone = screenWidth < 600;
    return PopupMenuButton<String>(
      constraints: BoxConstraints(
        minWidth: isPhone ? screenWidth * 0.45 : screenWidth * 0.35,
        maxWidth: isPhone ? screenWidth * 0.55 : screenWidth * 0.45,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          enabled: false,
          child: SizedBox(
            width: screenWidth * 0.5,
            child: GridView.count(
              crossAxisCount: screenWidth ~/ 600 + 1, // пока просто 2 колонки
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              children: [
                buildMapTileWidget(
                  context,
                  'OpenStreetMap',
                  'assets/images/openstreetmap.webp',
                  'osm',
                  () {
                    onTypeChanged('osm'); // ← передаём наверх
                    Navigator.pop(context); // ← закрываем меню
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Landscape',
                  'assets/images/landscape.webp',
                  'lds',
                  () {
                    onTypeChanged('lds');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Satellite',
                  'assets/images/satelite.webp',
                  'sat',
                  () {
                    onTypeChanged('sat');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Atlas',
                  'assets/images/atlas.webp',
                  'atl',
                  () {
                    onTypeChanged('atl');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Outdoors',
                  'assets/images/outdoors.webp',
                  'out',
                  () {
                    onTypeChanged('out');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'OpenCycleMap',
                  'assets/images/opencyclemap.webp',
                  'ocm',
                  () {
                    onTypeChanged('ocm');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'OSM topo',
                  'assets/images/osmtopo.webp',
                  'con',
                  () {
                    onTypeChanged('con');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Water',
                  'assets/images/water.webp',
                  'stc',
                  () {
                    onTypeChanged('stc');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Terrain',
                  'assets/images/terrain.webp',
                  'stt',
                  () {
                    onTypeChanged('stt');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Stadia',
                  'assets/images/stamen.webp',
                  'sts',
                  () {
                    onTypeChanged('sts');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Physics Map',
                  'assets/images/physics.webp',
                  'phy',
                  () {
                    onTypeChanged('phy');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Shaded relief',
                  'assets/images/relief.webp',
                  'rel',
                  () {
                    onTypeChanged('rel');
                    Navigator.pop(context);
                  },
                ),
                buildMapTileWidget(
                  context,
                  'Topo map',
                  'assets/images/topo.webp',
                  'top',
                  () {
                    onTypeChanged('top');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
      style: buttonStyle,
      icon: const Icon(Icons.layers, color: Colors.black),
    );
  }
}
