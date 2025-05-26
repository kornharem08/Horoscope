import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/fortune_shop.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<FortuneShop> _shops = FortuneShop.getMockShops();
  late WebViewController _webViewController;
  bool _isMapLoaded = false;
  bool _markersLoaded = false;
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isMapLoaded = true;
            });
            // Don't load markers immediately - wait for user to zoom in
          },
        ),
      )
      ..addJavaScriptChannel(
        'onMarkerTap',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final shopName = message.message;
            // Find shop by exact name match
            final shop = _shops.firstWhere(
              (s) => s.name == shopName,
              orElse: () => _shops.first,
            );
            
            // Show shop details modal
            _showShopDetails(shop);
            
            // Also focus the map on this shop
            _webViewController.runJavaScript('''
              focusOnMarker(${shop.longitude}, ${shop.latitude}, 16);
            ''');
          } catch (e) {
            print('Error handling marker tap: $e');
          }
        },
      )
      ..addJavaScriptChannel(
        'onMapMove',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final zoomData = double.parse(message.message);
            setState(() {
              _currentZoom = zoomData;
            });
            // Load markers when zoom level is high enough (user is exploring)
            if (zoomData >= 13.0 && !_markersLoaded) {
              _addMarkersToMap();
              setState(() {
                _markersLoaded = true;
              });
            }
          } catch (e) {
            print('Error handling map move: $e');
          }
        },
      )
      ..loadHtmlString(_getMapHtml());
  }

  String _getMapHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Longdo Map</title>
    <script type="text/javascript" src="https://api.longdo.com/map/?key=cd68cfb7b97c66ab323fb0068847f3f0"></script>
    <style>
        body { margin: 0; padding: 0; }
        #map { width: 100%; height: 100vh; }
        

    </style>
</head>
<body>
    <div id="map"></div>
    <script>
        var map, markers = [];
        
        function initMap() {
            map = new longdo.Map({
                placeholder: document.getElementById('map'),
                language: 'th'
            });
            
            // Hide built-in zoom controls
            map.Ui.Zoombar.visible(false);
            map.Ui.Toolbar.visible(false);
            
            // Set center to Bangkok
            map.location(longdo.LocationMode.GPS);
            map.zoom(12);
            map.location({lon: 100.5018, lat: 13.7563});
            
            // Add event listeners for map movement and zoom
            map.Event.bind('zoom', function() {
                var currentZoom = map.zoom();
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('onMapMove', currentZoom.toString());
                }
            });
            
            map.Event.bind('move', function() {
                var currentZoom = map.zoom();
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('onMapMove', currentZoom.toString());
                }
            });
        }
        
        function addMarker(lon, lat, title, detail, rating, reviewCount, phone) {
            // Create a simple SVG icon with crystal ball emoji
            var svgIcon = `
                <svg width="50" height="50" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
                            <feDropShadow dx="0" dy="2" stdDeviation="3" flood-color="#000000" flood-opacity="0.3"/>
                        </filter>
                    </defs>
                    <!-- Teardrop background -->
                    <path d="M25 5 C35 5, 40 15, 40 22 C40 30, 35 40, 25 40 C15 40, 10 30, 10 22 C10 15, 15 5, 25 5 Z" 
                          fill="#FF6B35" 
                          stroke="#FFFFFF" 
                          stroke-width="2" 
                          filter="url(#shadow)"/>
                    <!-- Crystal ball emoji -->
                    <text x="25" y="28" text-anchor="middle" font-size="18" fill="white">🔮</text>
                </svg>
            `;
            
            var iconUrl = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svgIcon);
            
            var marker = new longdo.Marker({lon: lon, lat: lat}, {
                title: title,
                detail: title + ' ⭐ ' + rating + ' (' + reviewCount + ' รีวิว)',
                icon: {
                    url: iconUrl,
                    offset: {x: 25, y: 40}
                }
            });
            
            map.Overlays.add(marker);
            markers.push(marker);
            
            // Add click event
            marker.onclick = function() {
                // Send shop name to Flutter to find and show details
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('onMarkerTap', title);
                }
            };
        }
        
        function focusOnMarker(lon, lat, zoom) {
            map.location({lon: lon, lat: lat});
            if (zoom) {
                map.zoom(zoom);
            }
        }
        
        function clearMarkers() {
            markers.forEach(function(marker) {
                map.Overlays.remove(marker);
            });
            markers = [];
        }
        
        function zoomIn() {
            var currentZoom = map.zoom();
            map.zoom(currentZoom + 1);
        }
        
        function zoomOut() {
            var currentZoom = map.zoom();
            if (currentZoom > 1) {
                map.zoom(currentZoom - 1);
            }
        }
        
        function getCurrentZoom() {
            return map.zoom();
        }
        
        // Initialize map when page loads
        window.onload = function() {
            initMap();
        };
    </script>
</body>
</html>
    ''';
  }

  void _addMarkersToMap() {
    if (!_markersLoaded) {
      for (FortuneShop shop in _shops) {
        _webViewController.runJavaScript('''
          addMarker(${shop.longitude}, ${shop.latitude}, "${shop.name}", "${shop.description}", ${shop.rating}, ${shop.reviewCount}, "${shop.phone}");
        ''');
      }
      setState(() {
        _markersLoaded = true;
      });
    }
  }

  void _forceLoadMarkers() {
    if (!_markersLoaded) {
      _addMarkersToMap();
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Map (extends behind bottom nav)
          Positioned.fill(
            child: WebViewWidget(controller: _webViewController),
          ),
          
          // Loading Overlay
          if (!_isMapLoaded)
            Positioned.fill(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFFFF6B35),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'กำลังโหลดแผนที่...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Markers Loading Indicator
          if (_isMapLoaded && !_markersLoaded && _currentZoom >= 13.0)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'กำลังโหลดร้านค้า...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Zoom to see shops message
          if (_isMapLoaded && !_markersLoaded && _currentZoom < 13.0)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.zoom_in,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ซูมเข้าเพื่อดูร้านดูดวง',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Search Header (Compact)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ค้นหาร้านดูดวง...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.my_location,
                      color: const Color(0xFFFF6B35),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Control Buttons
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              children: [
                // Zoom In Button
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      _webViewController.runJavaScript('zoomIn();');
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6B35),
                    elevation: 4,
                    child: const Icon(Icons.add, size: 20),
                  ),
                ),
                // Zoom Out Button
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      _webViewController.runJavaScript('zoomOut();');
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6B35),
                    elevation: 4,
                    child: const Icon(Icons.remove, size: 20),
                  ),
                ),
                // Shop List Button
                FloatingActionButton.extended(
                  onPressed: () {
                    _forceLoadMarkers();
                    _showShopList();
                  },
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.store, size: 20),
                  label: const Text(
                    'ร้านค้าแนะนำ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  elevation: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShopList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.store,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ร้านดูดวงแนะนำ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            
            // Shop List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _shops.length,
                itemBuilder: (context, index) {
                  final shop = _shops[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _forceLoadMarkers();
                        _showShopDetails(shop);
                        // Focus map on selected shop
                        _webViewController.runJavaScript('''
                          focusOnMarker(${shop.longitude}, ${shop.latitude}, 15);
                        ''');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.store,
                                color: Color(0xFFFF6B35),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${shop.rating}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        ' (${shop.reviewCount} รีวิว)',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shop.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.directions,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '1.2 กม.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShopDetails(FortuneShop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Shop info with transparent background icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🔮',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${shop.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                ' (${shop.reviewCount})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.green[600],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                shop.openHours,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Description
              Text(
                shop.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Address
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        shop.address,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone, size: 18),
                      label: Text(shop.phone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6B35),
                        side: const BorderSide(color: Color(0xFFFF6B35)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                                             onPressed: () {
                         // Focus map on this shop and close modal
                         Navigator.pop(context);
                         _webViewController.runJavaScript('''
                           focusOnMarker(${shop.longitude}, ${shop.latitude}, 16);
                         ''');
                       },
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('นำทาง'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Reviews Section
              Row(
                children: [
                  const Text(
                    'รีวิวจากลูกค้า',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Reviews List
              ...shop.reviews.take(3).map((review) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '🔮',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ลูกค้า ${shop.reviews.indexOf(review) + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) => 
                                    Icon(
                                      Icons.star,
                                      color: index < 4 ? Colors.amber : Colors.grey[300],
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"$review"',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // View all reviews button
              if (shop.reviews.length > 3)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Could implement a full reviews page here
                    },
                    icon: const Icon(
                      Icons.reviews,
                      size: 18,
                      color: Color(0xFFFF6B35),
                    ),
                    label: Text(
                      'ดูรีวิวทั้งหมด (${shop.reviews.length})',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 