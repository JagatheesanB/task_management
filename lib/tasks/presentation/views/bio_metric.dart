import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BioMetric extends StatefulWidget {
  const BioMetric({Key? key}) : super(key: key);

  @override
  State<BioMetric> createState() => _BioMetricState();
}

class _BioMetricState extends State<BioMetric> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: _authButton(),
    );
  }

  Widget _authButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (!_isAuthenticated) {
          final bool canAuth = await _auth.canCheckBiometrics;
          try {
            if (canAuth) {
              final bool didAuth = await _auth.authenticate(
                localizedReason: 'Please Auth using Biometric',
                options: const AuthenticationOptions(
                  biometricOnly: true,
                ),
              );
              setState(() {
                _isAuthenticated = didAuth;
              });
              if (!_isAuthenticated) {
                _showErrorSnackbar('Invalid Biometric');
              }
            }
          } catch (e) {
            _showErrorSnackbar('Error during authentication: $e');
          }
        } else {
          setState(() {
            _isAuthenticated = false;
          });
        }
      },
      child: Icon(_isAuthenticated ? Icons.lock : Icons.lock_open_rounded),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Hello,",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isAuthenticated)
            Text(
              "Jagatheesan Babu",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent.shade700,
              ),
            ),
          if (!_isAuthenticated)
            const Text(
              "******",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
