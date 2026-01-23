import 'package:flutter/material.dart';
import 'dart:async';

/// PTZ Direction enum
enum PtzDirection {
  up,
  down,
  left,
  right,
  zoomIn,
  zoomOut,
}

/// Callback for PTZ movement
typedef PtzMoveCallback = void Function(PtzDirection direction, double speed);
typedef PtzStopCallback = void Function();

/// D-Pad Controller for PTZ camera control
/// Features: Show/hide toggle, speed control, directional buttons
/// Responsive layout for portrait and landscape modes
class PtzDpadController extends StatefulWidget {
  final PtzMoveCallback? onMove;
  final PtzStopCallback? onStop;
  final bool initiallyVisible;
  final double initialSpeed;

  const PtzDpadController({
    super.key,
    this.onMove,
    this.onStop,
    this.initiallyVisible = true,
    this.initialSpeed = 0.5,
  });

  @override
  State<PtzDpadController> createState() => _PtzDpadControllerState();
}

class _PtzDpadControllerState extends State<PtzDpadController>
    with SingleTickerProviderStateMixin {
  late bool _isVisible;
  late double _speed;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _moveTimer;
  PtzDirection? _activeDirection;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.initiallyVisible;
    _speed = widget.initialSpeed;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isVisible) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onDirectionStart(PtzDirection direction) {
    setState(() {
      _activeDirection = direction;
    });
    widget.onMove?.call(direction, _speed);
    
    // Continuous movement while holding
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      widget.onMove?.call(direction, _speed);
    });
  }

  void _onDirectionEnd() {
    _moveTimer?.cancel();
    _moveTimer = null;
    setState(() {
      _activeDirection = null;
    });
    widget.onStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final bottomPadding = mediaQuery.padding.bottom;
    final rightPadding = mediaQuery.padding.right;
    final leftPadding = mediaQuery.padding.left;
    
    if (isLandscape) {
      return _buildLandscapeLayout(bottomPadding, rightPadding, leftPadding);
    } else {
      return _buildPortraitLayout(bottomPadding);
    }
  }

  Widget _buildPortraitLayout(double bottomPadding) {
    return Stack(
      children: [
        // Toggle button - always visible
        Positioned(
          bottom: 16 + bottomPadding,
          right: 16,
          child: _buildToggleButton(),
        ),
        
        // D-Pad controls
        Positioned(
          bottom: 80 + bottomPadding,
          right: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _isVisible
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Speed control
                      _buildSpeedControlCompact(),
                      const SizedBox(height: 12),
                      // Zoom controls
                      _buildZoomControls(),
                      const SizedBox(height: 12),
                      // D-Pad
                      _buildDpad(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double bottomPadding, double rightPadding, double leftPadding) {
    return Stack(
      children: [
        // Toggle button - bottom right
        Positioned(
          bottom: 12 + bottomPadding,
          right: 12 + rightPadding,
          child: _buildToggleButton(size: 40),
        ),
        
        // Controls - horizontal layout at bottom
        Positioned(
          bottom: 12 + bottomPadding,
          left: 12 + leftPadding,
          right: 70 + rightPadding,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _isVisible
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // D-Pad on the left
                      _buildDpadCompact(),
                      const SizedBox(width: 16),
                      // Speed + Zoom in the middle
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSpeedControlHorizontal(),
                          const SizedBox(height: 8),
                          _buildZoomControlsCompact(),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({double size = 48}) {
    return GestureDetector(
      onTap: _toggleVisibility,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _isVisible
              ? const Color(0xFF3B82F6)
              : const Color(0xFF1F2937).withOpacity(0.9),
          borderRadius: BorderRadius.circular(size / 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isVisible ? Icons.gamepad : Icons.gamepad_outlined,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildSpeedControlCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.speed,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Tốc độ: ${(_speed * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: _buildSlider(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedControlHorizontal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.speed,
            color: Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '${(_speed * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 100,
            child: _buildSlider(height: 3, thumbRadius: 6),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({double height = 4, double thumbRadius = 8}) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: height,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
        overlayShape: RoundSliderOverlayShape(overlayRadius: thumbRadius + 6),
        activeTrackColor: const Color(0xFF3B82F6),
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
      ),
      child: Slider(
        value: _speed,
        min: 0.1,
        max: 1.0,
        divisions: 9,
        onChanged: (value) {
          setState(() {
            _speed = value;
          });
        },
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(
            icon: Icons.remove,
            direction: PtzDirection.zoomOut,
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: Colors.white24,
          ),
          const Icon(
            Icons.zoom_in,
            color: Colors.white54,
            size: 18,
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: Colors.white24,
          ),
          _buildZoomButton(
            icon: Icons.add,
            direction: PtzDirection.zoomIn,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControlsCompact() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(
            icon: Icons.remove,
            direction: PtzDirection.zoomOut,
            size: 32,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.zoom_in,
              color: Colors.white54,
              size: 16,
            ),
          ),
          _buildZoomButton(
            icon: Icons.add,
            direction: PtzDirection.zoomIn,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required PtzDirection direction,
    double size = 36,
  }) {
    final isActive = _activeDirection == direction;
    return GestureDetector(
      onTapDown: (_) => _onDirectionStart(direction),
      onTapUp: (_) => _onDirectionEnd(),
      onTapCancel: _onDirectionEnd,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B82F6)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(size / 4.5),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.55,
        ),
      ),
    );
  }

  Widget _buildDpad() {
    return Container(
      width: 160,
      height: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.9),
        borderRadius: BorderRadius.circular(80),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Center circle
          Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white24,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.control_camera,
                color: Colors.white54,
                size: 24,
              ),
            ),
          ),
          // Up button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_up,
                direction: PtzDirection.up,
              ),
            ),
          ),
          // Down button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_down,
                direction: PtzDirection.down,
              ),
            ),
          ),
          // Left button
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_left,
                direction: PtzDirection.left,
              ),
            ),
          ),
          // Right button
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_right,
                direction: PtzDirection.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpadCompact() {
    const double size = 120;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.9),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Center circle
          Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white24,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.control_camera,
                color: Colors.white54,
                size: 18,
              ),
            ),
          ),
          // Up button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_up,
                direction: PtzDirection.up,
                size: 32,
              ),
            ),
          ),
          // Down button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_down,
                direction: PtzDirection.down,
                size: 32,
              ),
            ),
          ),
          // Left button
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_left,
                direction: PtzDirection.left,
                size: 32,
              ),
            ),
          ),
          // Right button
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildDirectionButton(
                icon: Icons.keyboard_arrow_right,
                direction: PtzDirection.right,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required PtzDirection direction,
    double size = 44,
  }) {
    final isActive = _activeDirection == direction;
    return GestureDetector(
      onTapDown: (_) => _onDirectionStart(direction),
      onTapUp: (_) => _onDirectionEnd(),
      onTapCancel: _onDirectionEnd,
      onLongPressStart: (_) => _onDirectionStart(direction),
      onLongPressEnd: (_) => _onDirectionEnd(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B82F6)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: isActive ? const Color(0xFF60A5FA) : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.65,
        ),
      ),
    );
  }
}
