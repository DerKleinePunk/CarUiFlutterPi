import 'package:flutter/material.dart';

class OverlayWindowExample extends StatefulWidget {
  const OverlayWindowExample({super.key});

  @override
  State<OverlayWindowExample> createState() => _OverlayWindowExampleState();
}

class _OverlayWindowExampleState extends State<OverlayWindowExample> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  TextStyle textStyle = const TextStyle(fontSize: 20.0);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: key,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              width: size.width,
              color: Colors.transparent,
            ),
          ),
          SizedBox(
            width: 248.0,
            child: Row(
              children: [
                Container(
                  height: size.height,
                  width: 200.0,
                  padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
                  color: Colors.grey[100],
                  child: Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                      style: textStyle),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      height: 48.0,
                      width: size.height,
                      alignment: Alignment.center,
                      color: Colors.grey[400],
                      child: Text("Close", style: textStyle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 200.0,
            padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
            child: Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                style: textStyle),
          ),
          InkWell(
            onTap: () => key.currentState!.openEndDrawer(),
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                height: 48.0,
                width: size.height,
                alignment: Alignment.center,
                color: Colors.grey[400],
                child: Text("Open", style: textStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
