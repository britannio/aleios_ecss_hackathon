import 'package:aleios_hack/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  MapWidget() : super(key: mapKey);

  static final GlobalKey<MapWidgetState> mapKey = GlobalKey<MapWidgetState>();

  static const maxZoom = 18.4;

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  @override
  void initState() {
    super.initState();
    mapController.mapEventStream.listen((event) {});
  }

  void animateTo(
    LatLng latLng, {
    double? destZoom,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    destZoom ??= mapController.zoom;
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: latLng.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: latLng.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        // Disable rotation
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        zoom: 18,
        maxZoom: MapWidget.maxZoom,
        center: LatLng(50.935742, -1.3988268),
      ),
      children: [
        // TileLayer(
        //   urlTemplate: 'data/tiles/2017.mbtiles',
        //   tileProvider: AssetTileProvider(),
        // ),
        TileLayer(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/britannio/$kMapBoxStyleId/tiles/512/{z}/{x}/{y}@2x?access_token=$kMapBoxToken",
          additionalOptions: {
            "access_token": kMapBoxToken,
          },
          userAgentPackageName: 'com.example.app',
        ),

        PolygonLayer(
          polygons: [
            // for (var x
            // in buildingData.values.where((element) => element.isNotEmpty))
            for (var b in buildings)
              Polygon(
                points: b.polygon,
                color: b.capacityStatus.color,
                borderStrokeWidth: 2,
                borderColor: b.capacityStatus.color,
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            for (var building in buildings)
              Marker(
                point: building.location,
                width: 40,
                height: 40,
                builder: (context) => BuildingMarker(
                  building: building,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// TODO add token
const kMapBoxToken = '';

const kMapBoxStyleId = 'cle051s5v000k01pb8fv6cx0d';

class BuildingMarker extends StatelessWidget {
  const BuildingMarker({super.key, required this.building});
  final Building building;

  @override
  Widget build(BuildContext context) {
    final Color color = building.capacityStatus.color;
    return Container(
      // width: 48,
      // height: 48,
      // padding: EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            side: BorderSide(
              // color: Colors.grey.shade800,
              color: color,

              width: 2,
            ),
            borderRadius: BorderRadius.circular(8)),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          // Container(
          //   width: 4,
          //   height: double.infinity,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.rectangle,
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(6),
          //       bottomLeft: Radius.circular(6),
          //     ),
          //     color: color,
          //   ),
          // ),
          Text(
            building.shortName,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
