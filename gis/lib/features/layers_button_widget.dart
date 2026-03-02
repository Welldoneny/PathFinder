import 'package:flutter/material.dart';
import 'package:path_finder/styles.dart/button_style.dart';
import 'package:path_finder/widgets/map_tile_widgeet.dart';

class MapTypeButton extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const MapTypeButton({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 300),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          enabled: false,
          child: SizedBox(
            width: 300,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              children: [
                buildMapTileWidget(
                  context,
                  'OpenStreetMap',
                  'assets/images/openstreetmap.png',
                  'osm',
                ),
                buildMapTileWidget(
                  context,
                  'Landscape',
                  'assets/images/landscape.png',
                  'lds',
                ),
                buildMapTileWidget(
                  context,
                  'Satellite',
                  'assets/images/satelite.png',
                  'sat',
                ),
                buildMapTileWidget(
                  context,
                  'Atlas',
                  'assets/images/atlas.png',
                  'atl',
                ),
                buildMapTileWidget(
                  context,
                  'Outdoors',
                  'assets/images/outdoors.png',
                  'out',
                ),
                buildMapTileWidget(
                  context,
                  'OpenCycleMap',
                  'assets/images/opencyclemap.png',
                  'ocm',
                ),
              ],
            ),
          ),
        ),
      ],
      style: buttonStyle,
      icon: const Icon(Icons.layers, color: Colors.black,),
    );
  }
}
