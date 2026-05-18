import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:domora/core/theme/app_theme.dart';

class MapAddressPicker extends StatefulWidget {
  final LatLng? initialPosition;
  final ValueChanged<LatLng> onPositionChanged;

  const MapAddressPicker({
    super.key,
    this.initialPosition,
    required this.onPositionChanged,
  });

  @override
  State<MapAddressPicker> createState() => _MapAddressPickerState();
}

class _MapAddressPickerState extends State<MapAddressPicker> {
  late LatLng _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Posición por defecto: Cali, Colombia
    _currentPosition = widget.initialPosition ?? const LatLng(3.4516, -76.5320);
  }

  @override
  void didUpdateWidget(MapAddressPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPos = widget.initialPosition;
    if (newPos != null && newPos != oldWidget.initialPosition) {
      setState(() => _currentPosition = newPos);
      _mapController.move(newPos, 16.0);
    }
  }

  void _onTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _currentPosition = latLng;
    });
    widget.onPositionChanged(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 14.0,
            onTap: _onTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.domora.app',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.error,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
