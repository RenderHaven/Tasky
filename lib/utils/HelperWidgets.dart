import 'package:flutter/material.dart';

class AnimatedProgressIndicator extends StatefulWidget {
  final double targetProgress;

  const AnimatedProgressIndicator({super.key, required this.targetProgress});

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    animateProgress(from: 0.0, to: widget.targetProgress);
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetProgress != oldWidget.targetProgress) {
      _progress = 0.0; // Reset progress to 0 when target changes
      animateProgress(from: _progress, to: widget.targetProgress);
    }
  }

  void animateProgress({required double from, required double to}) async {
    _progress = from;
    const duration = Duration(milliseconds: 10);
    while (_progress < to) {
      await Future.delayed(duration);
      if (!mounted) return;
      setState(() {
        _progress += 0.01;
        if (_progress > to) {
          _progress = to;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white24,
            color: Colors.amber,
          ),
        ),
        Text(
          '${(_progress * 100).round()}%',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class CustomToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static void showToast({required BuildContext context,required String message,Duration duration = const Duration(seconds: 2),Color color = Colors.black}) {
    if (_isVisible) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
    _isVisible = true;

    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
    });
  }
}


class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({Key? key, required this.controller}) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isHide,
      controller: widget.controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.lock, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isHide ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              isHide = !isHide;
            });
          },
        ),
      ),
    );
  }
}

class OverlayLoader {
  static Future<void> show(
    BuildContext context,
    Future<void> Function() asyncFunction, {
    String gifAssets="assets/icons/Loading.gif",
  }) async {
    final overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Image.asset(gifAssets, width: 150, height: 150),
          ),
        ],
      ),
    );

    final overlayState = Overlay.of(context);
    overlayState.insert(overlay);

    try {
      await asyncFunction();
    } finally {
      overlay.remove();
    }
  }
}

void showUserProfileDialog(BuildContext context,{required String name,required String email,required VoidCallback onLogout}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Color(0xFF1F2A40),
        contentPadding: EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle Avatar with First Character
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.amber,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 30, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            // User Name
            Text(
              name,
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            // Email
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            // Logout Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // close popup
                onLogout(); // trigger logout function
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: Icon(Icons.logout,color: Colors.white,),
              label: Text("Logout",style: TextStyle(color: Colors.white),),
            )
          ],
        ),
      );
    },
  );
}

