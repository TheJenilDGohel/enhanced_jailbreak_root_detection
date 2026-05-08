import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:enhanced_jailbreak_root_detection/enhanced_jailbreak_root_detection.dart';

void main() {
  runApp(const SecurityDashboardApp());
}

class SecurityDashboardApp extends StatelessWidget {
  const SecurityDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double _securityScore = 1.0; // 0.0 to 1.0
  List<SecurityCheckResult> _results = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _runDiagnostics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _results = [];
    });
    _controller.repeat();

    final detection = EnhancedJailbreakRootDetection.instance;
    
    // Simulate some delay for "scanning" effect
    await Future.delayed(const Duration(seconds: 2));

    final isJailBroken = await detection.isJailBroken;
    final isRealDevice = await detection.isRealDevice;
    final isDevMode = Platform.isAndroid ? await detection.isDevMode : false;
    final issues = await detection.checkForIssues;
    
    bool isTampered = false;
    if (Platform.isIOS) {
      // In a real app, use your actual bundle ID
      isTampered = await detection.isTampered('com.w3conext.jailbreakRootDetectionExample');
    }

    final isOnExternalStorage = Platform.isAndroid ? await detection.isOnExternalStorage : false;

    List<SecurityCheckResult> tempResults = [
      SecurityCheckResult(
        title: 'Jailbreak / Root',
        subtitle: isJailBroken ? 'Vulnerability Detected' : 'Secure Environment',
        isPassed: !isJailBroken,
        icon: Icons.security_rounded,
      ),
      SecurityCheckResult(
        title: 'Integrity',
        subtitle: isRealDevice ? 'Physical Hardware' : 'Virtual Environment',
        isPassed: isRealDevice,
        icon: Icons.devices_rounded,
      ),
      SecurityCheckResult(
        title: 'Frida / Hooks',
        subtitle: issues.contains(JailbreakIssue.fridaFound) ? 'Instrumentation Detected' : 'No Active Hooks',
        isPassed: !issues.contains(JailbreakIssue.fridaFound),
        icon: Icons.api_rounded,
      ),
    ];

    if (Platform.isAndroid) {
      tempResults.add(SecurityCheckResult(
        title: 'Developer Mode',
        subtitle: isDevMode ? 'Enabled (Warning)' : 'Disabled',
        isPassed: !isDevMode,
        icon: Icons.code_rounded,
      ));
      tempResults.add(SecurityCheckResult(
        title: 'Storage',
        subtitle: isOnExternalStorage ? 'External (Unsafe)' : 'Internal (Secure)',
        isPassed: !isOnExternalStorage,
        icon: Icons.storage_rounded,
      ));
    }

    if (Platform.isIOS) {
      tempResults.add(SecurityCheckResult(
        title: 'Binary Tampering',
        subtitle: isTampered ? 'Signature Modified' : 'Original Binary',
        isPassed: !isTampered,
        icon: Icons.verified_user_rounded,
      ));
    }

    // Calculate score
    int passedCount = tempResults.where((r) => r.isPassed).length;
    _securityScore = tempResults.isEmpty ? 1.0 : passedCount / tempResults.length;

    if (mounted) {
      setState(() {
        _results = tempResults;
        _isLoading = false;
      });
    }
    
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            title: Text(
              'Security Dashboard',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: _isLoading ? null : _runDiagnostics,
                icon: _isLoading 
                  ? RotationTransition(
                      turns: _controller,
                      child: const Icon(Icons.refresh_rounded),
                    )
                  : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreHeader(),
                  const SizedBox(height: 32),
                  Text(
                    'DETAILED DIAGNOSTICS',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (_isLoading) return _buildLoadingCard();
                  final result = _results[index];
                  return _buildResultCard(result);
                },
                childCount: _isLoading ? 4 : _results.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    final color = _securityScore > 0.8 
        ? Colors.greenAccent 
        : (_securityScore > 0.5 ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _isLoading ? null : _securityScore,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                _isLoading ? '--' : '${(_securityScore * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? 'Analyzing System...' : (_securityScore > 0.8 ? 'System Secure' : 'Action Required'),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isLoading ? 'Performing multi-layered checks' : 'Your device passed ${_results.where((r) => r.isPassed).length}/${_results.length} security layers.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(SecurityCheckResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                result.icon,
                color: result.isPassed ? Colors.blueAccent : Colors.redAccent,
                size: 28,
              ),
              Icon(
                result.isPassed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: result.isPassed ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                result.subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
    );
  }
}

class SecurityCheckResult {
  final String title;
  final String subtitle;
  final bool isPassed;
  final IconData icon;

  SecurityCheckResult({
    required this.title,
    required this.subtitle,
    required this.isPassed,
    required this.icon,
  });
}
