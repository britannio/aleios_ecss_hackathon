import 'dart:math';
import 'dart:ui';

import 'package:aleios_hack/data.dart';
import 'package:aleios_hack/map.dart';
import 'package:async_builder/async_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

final instanceId = Uuid().v4();

final dbRef = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://aleios-default-rtdb.europe-west1.firebasedatabase.app/',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // await Firebase.initializeApp(
  // options: DefaultFirebaseOptions.currentPlatform,
  // );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Firebase project was deleted
  // await setupPersistence();

  runApp(const MyApp());
}

Future<void> setupPersistence() async {
  final connectedRef = dbRef.ref(".info/connected");
  final connnectionsRef = dbRef.ref("connections");
  connectedRef.onValue.listen((event) {
    final connected = event.snapshot.value as bool? ?? false;
    if (connected) {
      final con = connnectionsRef.child(instanceId);

      // When this device disconnects, remove it.
      con.onDisconnect().remove();

      // When I disconnect, update the last time I was seen online.
      // lastOnlineRef.onDisconnect().set(ServerValue.timestamp);

      // Add this device to my connections list.
      // This value could contain info about the device or a timestamp too.
      con.set(true);
    }
  });
}

Stream<int> _currentConnections() async* {
  yield Random().nextInt(20);
  /*
  final connnectionsRef = dbRef.ref("connections");
  yield* connnectionsRef.onValue.map((event) {
    final value = event.snapshot.value;
    return 'true'.allMatches(value.toString()).length;
  });
  */
}

class ConnectionsBuilder extends StatefulWidget {
  const ConnectionsBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, int connections) builder;

  @override
  State<ConnectionsBuilder> createState() => _ConnectionsBuilderState();
}

class _ConnectionsBuilderState extends State<ConnectionsBuilder> {
  final stream = _currentConnections();
  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      stream: stream,
      builder: (context, snapshot) {
        return widget.builder(context, snapshot ?? 0);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aleios Hack App',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.green,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          inputDecoratorRadius: 40.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: BasePage(),
    );
  }
}

class BasePage extends StatefulWidget {
  BasePage() : super(key: basePageKey);

  static final GlobalKey<BasePageState> basePageKey = GlobalKey();

  @override
  State<BasePage> createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  final dragSheetController = DraggableScrollableController();

  void minimiseSheet() {
    dragSheetController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          MapWidget(),
          DraggableScrollableSheet(
            controller: dragSheetController,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Material(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                elevation: 16,
                clipBehavior: Clip.antiAlias,
                color: Color(0xFFFEFEFE).withOpacity(0.4),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 5,
                          width: 80,
                          decoration: ShapeDecoration(
                            shape: StadiumBorder(),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Text(
                        'Recommendations',
                        style: TextStyle(
                          fontFamily: GoogleFonts.bungee().fontFamily,
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      ConnectionsBuilder(
                        builder: (context, count) {
                          return CustomCard(
                            onTap: null,
                            borderColor: Colors.grey.shade800,
                            child: Text(
                              'You are in B16 with ${max(0, count - 1)} other people',
                            ),
                          );
                        },
                      ),
                      Divider(),
                      const SizedBox(height: 16),
                      for (var bldg in buildings) BuildingCard(building: bldg)
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MapBox extends StatelessWidget {
  const MapBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Box(
      title: 'Map',
      child: Column(
        children: [],
      ),
    );
  }
}

class BuildingCard extends StatelessWidget {
  const BuildingCard({super.key, required this.building});
  final Building building;

  Widget capacityIndicator() {
    return ListTile(
      trailing: building.icon,
      title: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Text(
            '${building.percentFull}%',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            ' full',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO work on this!
    return CustomCard(
      onTap: () {
        MapWidget.mapKey.currentState!.animateTo(
          building.location,
          destZoom: MapWidget.maxZoom,
        );
        BasePage.basePageKey.currentState!.minimiseSheet();
      },
      borderColor: building.capacityStatus.color,
      child: ListTile(
        trailing: building.icon,
        title: Text(building.name),
        subtitle: Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              '${building.percentFull}%',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              ' full',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      // child: Column(
      //   children: [
      //     ListTile(
      //       title: Text(building.name),
      //       // subtitle: Text(building.shortName),
      //     ),
      //     Divider(color: Colors.grey.shade600),
      //     capacityIndicator(),
      //   ],
      // ),
    );
  }
}

class Box extends StatelessWidget {
  const Box({
    super.key,
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: GoogleFonts.bungee().fontFamily,
              fontSize: 28,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          child
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.borderRadius = 16,
    this.borderColor,
    this.elevation = 0,
  });
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final double borderRadius;
  final Color? borderColor;
  final double elevation;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        // elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        // color: Colors.grey.shade300.withOpacity(0.5),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
