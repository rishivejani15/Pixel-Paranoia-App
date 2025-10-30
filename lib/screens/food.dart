import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/food_provider.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});
  @override
  FoodScreenState createState() => FoodScreenState();
}

class FoodScreenState extends State<FoodScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? _cameraController;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
    Future.microtask(() => Provider.of<UserProvider>(context, listen: false).clearSingleUser());
  }

  void _initializeCamera() async {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      autoStart: true,
    );
    // Give camera time to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_cameraController == null) return;
    
    switch (state) {
      case AppLifecycleState.resumed:
        _cameraController?.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _cameraController?.stop();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _onScan(BuildContext ctx, String content) async {
    final foodProvider = Provider.of<FoodProvider>(ctx, listen: false);
    if (foodProvider.processing || content == foodProvider.lastScannedQr) return;
    foodProvider.setProcessing(true);
    foodProvider.setLastScannedQr(content);
    final parts = content.split('|');
    if (parts.length < 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Invalid QR format')),
      );
      foodProvider.setProcessing(false);
      foodProvider.setLastScannedQr(null);
      return;
    }
    final qrId = parts.last;
    final userProvider = Provider.of<UserProvider>(ctx, listen: false);
    
    // Only pass context if still mounted to prevent SnackBar on wrong screen
    await userProvider.markFood(qrId, context: mounted ? ctx : null);
    if (!mounted) return;
    
    // Clear immediately after backend upload completes
    foodProvider.setProcessing(false);
    foodProvider.setLastScannedQr(null);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FoodProvider>(
      create: (_) => FoodProvider(),
      child: Consumer<FoodProvider>(
        builder: (ctx, foodProvider, _) {
          final userProvider = Provider.of<UserProvider>(ctx);
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D1B47),
              elevation: 8,
              shadowColor: Colors.deepPurple.withOpacity(0.5),
              title: const Text(
                '🍽️ Mark Food',
                style: TextStyle(
                  fontFamily: 'Creepster',
                  fontSize: 24,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.deepOrange,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.orange),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final fullW = constraints.maxWidth;
                final fullH = constraints.maxHeight;
                final cutOutW = fullW * 0.78;
                final cutOutH = cutOutW;
                final left = (fullW - cutOutW) / 2;
                final top = (fullH - cutOutH) / 2;
                const double innerPadding = 8.0;
                const double lineHeight = 3.0;
                final travelHeight = (cutOutH - innerPadding * 2 - lineHeight).clamp(0.0, double.infinity);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: _cameraController == null
                          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                          : MobileScanner(
                              controller: _cameraController!,
                              fit: BoxFit.cover,
                              onDetect: (capture) {
                                if (capture.barcodes.isNotEmpty) {
                                  final raw = capture.barcodes.first.rawValue ?? '';
                                  if (raw.isNotEmpty) _onScan(ctx, raw);
                                }
                              },
                            ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ScannerOverlay(
                          borderRadius: 20,
                          overlayColor: const Color(0xAA0B001A),
                          cutOutWidth: cutOutW,
                          cutOutHeight: cutOutH,
                          cornerColor: const Color(0xFF9B59FF),
                          cornerLength: 32,
                          cornerThickness: 4,
                        ),
                      ),
                    ),
                    Positioned(
                      left: left + innerPadding,
                      width: cutOutW - innerPadding * 2,
                      top: top + innerPadding,
                      height: cutOutH - innerPadding * 2,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _scanController,
                          builder: (context, child) {
                            final t = _scanController.value;
                            final y = travelHeight * t;
                            return Stack(
                              children: [
                                Positioned(
                                  top: y,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: lineHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.transparent,
                                          Colors.purpleAccent.withOpacity(0.95),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purpleAccent.withOpacity(0.6),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: top + cutOutH + 16,
                      child: Column(
                        children: const [
                          Text(
                            'Place the QR code inside the frame',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Scans automatically',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (foodProvider.processing || userProvider.loading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/* ---------- ScannerOverlay and painters ---------- */
class ScannerOverlay extends StatelessWidget {
  final double borderRadius;
  final Color overlayColor;
  final double cutOutWidth;
  final double cutOutHeight;
  final Color cornerColor;
  final double cornerLength;
  final double cornerThickness;

  const ScannerOverlay({
    super.key,
    this.borderRadius = 24,
    this.overlayColor = const Color(0x99000000),
    this.cutOutWidth = 300,
    this.cutOutHeight = 300,
    this.cornerColor = Colors.purpleAccent,
    this.cornerLength = 28,
    this.cornerThickness = 4,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to compute positions relative to the overlay's actual size,
    // ensuring the cutout square is perfectly centered on the screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;
        final left = (screenW - cutOutWidth) / 2;
        final top = (screenH - cutOutHeight) / 2;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  cutOutRect: Rect.fromLTWH(
                    left,
                    top,
                    cutOutWidth,
                    cutOutHeight,
                  ),
                  borderRadius: borderRadius,
                  overlayColor: overlayColor,
                ),
              ),
            ),
            // corners positioned relative to the centered cutout
            Positioned(
              left: left - (cornerThickness / 2),
              top: top - (cornerThickness / 2),
              child: _Corner(
                length: cornerLength,
                thickness: cornerThickness,
                color: cornerColor,
              ),
            ),
            Positioned(
              left: left + cutOutWidth - cornerLength + (cornerThickness / 2),
              top: top - (cornerThickness / 2),
              child: Transform.rotate(
                angle: 1.5708,
                child: _Corner(
                  length: cornerLength,
                  thickness: cornerThickness,
                  color: cornerColor,
                ),
              ),
            ),
            Positioned(
              left: left - (cornerThickness / 2),
              top: top + cutOutHeight - cornerLength + (cornerThickness / 2),
              child: Transform.rotate(
                angle: -1.5708,
                child: _Corner(
                  length: cornerLength,
                  thickness: cornerThickness,
                  color: cornerColor,
                ),
              ),
            ),
            Positioned(
              left: left + cutOutWidth - cornerLength + (cornerThickness / 2),
              top: top + cutOutHeight - cornerLength + (cornerThickness / 2),
              child: Transform.rotate(
                angle: 3.14159,
                child: _Corner(
                  length: cornerLength,
                  thickness: cornerThickness,
                  color: cornerColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Corner extends StatelessWidget {
  final double length;
  final double thickness;
  final Color color;
  const _Corner({
    required this.length,
    required this.thickness,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: length,
      child: CustomPaint(
        painter: _CornerPainter(color: color, thickness: thickness),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  _CornerPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height), Offset(0, 0), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}

class _OverlayPainter extends CustomPainter {
  final Rect cutOutRect;
  final double borderRadius;
  final Color overlayColor;

  _OverlayPainter({
    required this.cutOutRect,
    this.borderRadius = 24,
    this.overlayColor = const Color(0x99000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(0),
    );
    final cutOut = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    final path =
        Path()
          ..addRRect(outer)
          ..addRRect(cutOut)
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => false;
}
