import 'dart:math';

import 'package:flutter/material.dart';

class HoverPage extends StatefulWidget {
  final int index;
  final String title;

  const HoverPage({super.key, required this.index, required this.title});

  @override
  State<HoverPage> createState() => _HoverPageState(index: index, title: title);
}

class _HoverPageState extends State<HoverPage> {
  final int index;
  final String title;
  _HoverPageState({required this.index, required this.title});

  final Color _color =
      Colors.primaries[Random.secure().nextInt(Colors.primaries.length)];
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (f) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (f) {
        setState(() {
          isHover = false;
        });
      },
      child: AnimatedContainer(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 12,
                  spreadRadius: 5,
                  color: isHover
                      ? Colors.purple.withOpacity(0.4)
                      : Colors.transparent),
            ],
            borderRadius: BorderRadius.only(
              topRight: (isHover || index == 0)
                  ? const Radius.circular(60)
                  : const Radius.circular(0),
              topLeft: (isHover || index == 0)
                  ? const Radius.circular(60)
                  : const Radius.circular(0),
              bottomRight: (isHover || index == 0)
                  ? const Radius.circular(60)
                  : const Radius.circular(0),
              bottomLeft: (isHover || index == 0)
                  ? const Radius.circular(60)
                  : const Radius.circular(0),
            )),
        color: _color,
        duration: const Duration(milliseconds: 200),
        width: 500,
        height: isHover ? 120 : 85,
        child: _addElement(),
      ),
    );
  }

  _addElement() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: isHover ? 120 : 85,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isHover ? 55 : 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isHover ? Colors.purple : Colors.teal),
              child: AnimatedDefaultTextStyle(
                style: TextStyle(
                    color: isHover ? Colors.purple : Colors.grey[700]),
                duration: const Duration(milliseconds: 150),
                child: Text(index.toString()),
              ),
            ),
          ),
        )
      ],
    );
  }
}
