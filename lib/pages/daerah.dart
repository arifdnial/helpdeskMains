import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:getwidget/getwidget.dart';
import 'package:latlong2/latlong.dart';
class DaerahPage extends StatefulWidget {
  @override
  _DaerahPageState createState() => _DaerahPageState();
}
class _DaerahPageState extends State<DaerahPage> {
  void _navigateToAdminSelection(String location) async {
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daerah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GFCard(
              titlePosition: GFPosition.start,
              content: Column(
                children: [
                  const Text("Menara Mains"),
                  _buildMap(LatLng(2.7277, 101.9381)), // Coordinates for Menara Mains
                ],
              ),
              buttonBar: GFButtonBar(
                children: <Widget>[
                  GFButton(
                    onPressed: () => _navigateToAdminSelection("Menara Mains"),
                    text: "Select",
                    type: GFButtonType.outline,
                    shape: GFButtonShape.pills,
                    color: GFColors.PRIMARY,
                  ),
                ],
              ),
            ),
            GFCard(
              titlePosition: GFPosition.start,
              content: Column(
                children: [
                  const Text("Senawang"),
                  _buildMap(LatLng(2.7035, 101.9764)), // Coordinates for Senawang
                ],
              ),
              buttonBar: GFButtonBar(
                children: <Widget>[
                  GFButton(
                    onPressed: () => _navigateToAdminSelection("Senawang"),
                    text: "Select",
                    type: GFButtonType.outline,
                    shape: GFButtonShape.pills,
                    color: GFColors.PRIMARY,
                  ),
                ],
              ),
            ),
            GFCard(
              titlePosition: GFPosition.start,
              content: Column(
                children: [
                  const Text("Another Place"),
                  _buildMap(LatLng(2.8161, 101.7977)), // Coordinates for Another Place
                ],
              ),
              buttonBar: GFButtonBar(
                children: <Widget>[
                  GFButton(
                    onPressed: () => _navigateToAdminSelection("Another Place"),
                    text: "Select",
                    type: GFButtonType.outline,
                    shape: GFButtonShape.pills,
                    color: GFColors.PRIMARY,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the map
  Widget _buildMap(LatLng center) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width,
      child: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
    );
  }
}
