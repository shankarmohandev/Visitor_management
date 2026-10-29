import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/visitor_provider.dart';
import '../theme/app_theme.dart';
import '../utils/qr_code_helper.dart';
import 'visitor_details_screen.dart';

/// Screen 5: QR Scanner View strictly adhering to the assignment requirements:
/// - Device camera preview with scanning area overlay
/// - Extracts visitor ID and retrieves visitor details from API
/// - Displays visitor information and status (via VisitorDetailsScreen)
/// - Validations:
///   - Error for invalid QR code
///   - Error if visitor does not exist
///   - Prevent repeated scanner callbacks (debouncing duplicate actions)
/// - Manual ID lookup option for testing/emulator convenience
class QRScannerScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const QRScannerScreen({super.key, this.onBackToDashboard});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animationController;
  late final Animation<double> _laserAnimation;

  bool _isProcessing = false;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) {
      _showError('Invalid QR code: Empty content');
      return;
    }

    await _processScannedId(rawValue.trim());
  }

  Future<void> _processScannedId(String rawValue) async {
    setState(() => _isProcessing = true);

    try {
      final provider = Provider.of<VisitorProvider>(context, listen: false);
      final visitor = await provider.getVisitorByScannedCode(rawValue);

      if (!mounted) return;

      if (visitor != null) {
        // Haptic feedback
        HapticFeedback.mediumImpact();

        // Successfully retrieved visitor from API -> navigate to details
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
          ),
        );
      } else {
        final extractedId = QRCodeHelper.extractVisitorId(rawValue);
        _showError('Visitor not found with ID: "$extractedId"');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error retrieving visitor details: $e');
      }
    } finally {
      if (mounted) {
        // Pause briefly before allowing another scan to avoid duplicate actions
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Lookup by Visitor ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the Visitor ID (e.g. VIS001, VIS002):',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'VIS001',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(ctx).pop();
              if (text.isNotEmpty) {
                _processScannedId(text);
              }
            },
            child: const Text('Lookup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanWindowSize = screenSize.width * 0.72;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF14120F),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: const Text(
          'Scan Visitor QR Pass',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _torchEnabled ? AppTheme.primaryGold : Colors.white,
            ),
            tooltip: 'Toggle Flash',
            onPressed: () {
              setState(() => _torchEnabled = !_torchEnabled);
              _scannerController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            tooltip: 'Flip Camera',
            onPressed: () => _scannerController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_outlined, color: Colors.white),
            tooltip: 'Manual ID Entry',
            onPressed: _showManualEntryDialog,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 54),
                      const SizedBox(height: 16),
                      Text(
                        'Camera unavailable (${error.errorCode})',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ensure camera permissions are enabled in Android settings, or use manual lookup.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.keyboard_outlined),
                        label: const Text('Enter Visitor ID Manually'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _showManualEntryDialog,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Dark Overlay with Cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Reticle Corners & Animated Laser Line
          Center(
            child: SizedBox(
              width: scanWindowSize,
              height: scanWindowSize,
              child: Stack(
                children: [
                  // Corner Borders
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isProcessing ? AppTheme.primaryGold : Colors.white,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),

                  // Animated Laser
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, _) {
                      return Positioned(
                        top: _laserAnimation.value * (scanWindowSize - 4),
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryGold,
                                Colors.white,
                                AppTheme.primaryGold,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGold.withValues(alpha: 0.8),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Status Guidance Banner
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _isProcessing
                      ? 'Processing QR code...'
                      : 'Align visitor pass QR code inside the frame',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // 5. Bottom Controls (Manual ID Button)
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.keyboard_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Enter ID Manually',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white60, width: 1.2),
                  backgroundColor: Colors.black45,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _showManualEntryDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
