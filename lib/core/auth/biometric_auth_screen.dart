import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/widgets/circuit_background.dart';

class BiometricAuthScreen extends ConsumerStatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() =>
      _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _biometricAvailable = false;
  bool _isAuthenticating = false;
  bool _showPinFallback = false;
  bool _checkingBiometrics = true;

  // PIN state
  final List<String> _pinDigits = [];
  static const int _pinLength = 4;
  // Simple demo PIN – in production this would be stored securely
  static const String _correctPin = '1234';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkBiometrics();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable =
            canCheck && isDeviceSupported && availableBiometrics.isNotEmpty;
        _checkingBiometrics = false;
      });

      // Auto-prompt biometric on load if available
      if (_biometricAvailable) {
        await Future.delayed(const Duration(milliseconds: 500));
        _authenticate();
      }
    } catch (e) {
      setState(() {
        _biometricAvailable = false;
        _checkingBiometrics = false;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access SideWallet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        context.go('/home/dashboard');
      } else {
        _showError('Authentication failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Biometric authentication error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4466),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00FF88),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onPinDigitPressed(String digit) {
    if (_pinDigits.length >= _pinLength) return;

    setState(() {
      _pinDigits.add(digit);
    });

    if (_pinDigits.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onPinBackspace() {
    if (_pinDigits.isEmpty) return;
    setState(() {
      _pinDigits.removeLast();
    });
  }

  void _verifyPin() {
    final enteredPin = _pinDigits.join();
    if (enteredPin == _correctPin) {
      _showSuccess('PIN verified!');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) context.go('/home/dashboard');
      });
    } else {
      _showError('Incorrect PIN. Please try again.');
      setState(() => _pinDigits.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CircuitBackground(
        child: SafeArea(
          child: _checkingBiometrics
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E5FF),
                  ),
                )
              : _showPinFallback
                  ? _buildPinFallback()
                  : _buildBiometricContent(),
        ),
      ),
    );
  }

  Widget _buildBiometricContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.3),
                  width: 2,
                ),
                color: const Color(0xFF00E5FF).withOpacity(0.05),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF00E5FF),
                size: 52,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              'SideWallet',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Authenticate to continue',
              style: TextStyle(
                color: Color(0xFF8A94A6),
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 56),

            // Fingerprint button
            if (_biometricAvailable) ...[
              GestureDetector(
                onTap: _isAuthenticating ? null : _authenticate,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF00E5FF),
                          Color(0xFF0097A7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: _isAuthenticating
                        ? const Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.fingerprint_rounded,
                            color: Colors.white,
                            size: 52,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _isAuthenticating ? 'Authenticating...' : 'Touch to authenticate',
                style: TextStyle(
                  color: const Color(0xFF8A94A6).withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ] else ...[
              // No biometrics available message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4466).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF4466).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFF4466), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Biometric authentication not available on this device.',
                        style: TextStyle(color: Color(0xFFFF4466), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // PIN fallback button
            TextButton.icon(
              onPressed: () => setState(() => _showPinFallback = true),
              icon: const Icon(Icons.pin_outlined,
                  color: Color(0xFFCC44FF), size: 18),
              label: const Text(
                'Use PIN instead',
                style: TextStyle(
                  color: Color(0xFFCC44FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dialpad_rounded,
              color: Color(0xFF00E5FF),
              size: 48,
            ),

            const SizedBox(height: 20),

            const Text(
              'Enter PIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Enter your 4-digit PIN to continue',
              style: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
            ),

            const SizedBox(height: 40),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pinLength,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pinDigits.length
                        ? const Color(0xFF00E5FF)
                        : Colors.transparent,
                    border: Border.all(
                      color: index < _pinDigits.length
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF8A94A6),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Number pad
            _buildNumberPad(),

            const SizedBox(height: 24),

            // Back to biometric
            if (_biometricAvailable)
              TextButton.icon(
                onPressed: () => setState(() {
                  _showPinFallback = false;
                  _pinDigits.clear();
                }),
                icon: const Icon(Icons.fingerprint_rounded,
                    color: Color(0xFF00E5FF), size: 18),
                label: const Text(
                  'Use biometrics instead',
                  style: TextStyle(color: Color(0xFF00E5FF), fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final List<String> keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', 'del',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];

        if (key.isEmpty) return const SizedBox.shrink();

        if (key == 'del') {
          return _buildKeypadButton(
            child: const Icon(Icons.backspace_outlined,
                color: Color(0xFF8A94A6), size: 22),
            onTap: _onPinBackspace,
          );
        }

        return _buildKeypadButton(
          child: Text(
            key,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () => _onPinDigitPressed(key),
        );
      },
    );
  }

  Widget _buildKeypadButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF131929),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF00E5FF).withOpacity(0.15),
        highlightColor: const Color(0xFF00E5FF).withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.1),
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
