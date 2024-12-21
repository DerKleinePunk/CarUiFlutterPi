import 'package:flutter/material.dart';

class OverlayWindowMne extends StatefulWidget {
  const OverlayWindowMne({super.key, required this.top});

  final double top;
  @override
  State<OverlayWindowMne> createState() => _OverlayWindowMne();
}

class _OverlayWindowMne extends State<OverlayWindowMne> {
  bool _exanded = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    String? swipeDirection;
    return Positioned(
        top: widget.top,
        left: size.width - (_exanded ? 100 : 10),
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                _exanded = !_exanded;
              });
            },
            onPanUpdate: (details) {
              swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
            },
            onPanEnd: (details) {
              if (swipeDirection == null) {
                return;
              }
              if (swipeDirection == 'left') {
                //handle swipe left event
                setState(() {
                  _exanded = !_exanded;
                });
              }
              if (swipeDirection == 'right') {
                setState(() {
                  _exanded = !_exanded;
                });
              }
            },
            child: SizedBox(
                height: _exanded ? size.height - 60 : 40,
                width: _exanded ? 100 : 10,
                child: _exanded
                    ? ListView(
                        padding: const EdgeInsets.all(8),
                        children: <Widget>[
                            GestureDetector(
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.amber,
                                ),
                                onTap: () => ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                        SnackBar(content: Text("favorite")))),
                            GestureDetector(
                                child: Icon(Icons.access_alarm,
                                    color: Colors.amber),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("access_alarm")));
                                  setState(() {
                                    _exanded = false;
                                  });
                                })
                          ])
                    : Container(color: Colors.red))));
  }
}
