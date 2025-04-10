import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Dock(
            items: const [
              Icons.home,
              Icons.person,
              Icons.search,
              Icons.camera,
              Icons.message,
              Icons.settings,
            ],
            builder: (icon) {
              return DockItem(icon: icon);
            },
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.builder, this.items = const []});
  final List<IconData> items;
  final Widget Function(IconData) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> with SingleTickerProviderStateMixin {
  late List<IconData> items;
  int? hoveringIndex;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
    hoveringIndex = null;
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white30,
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            return buildDraggableItem(index);
          }),
        ),
      ),
    );
  }

  Widget buildDraggableItem(int index) {
    return GestureDetector(
      onTap: () {
        controller.forward();
      },
      child: Draggable<int>(
        data: index,
        onDragStarted: () {
          controller.forward();
        },
        onDragEnd: (_) {
          controller.reverse();
        },
        feedback: ScaleTransition(
          scale: animation,
          child: widget.builder(items[index]),
        ),
        childWhenDragging: const SizedBox(),
        onDragCompleted: () {
          setState(() {
            hoveringIndex = null;
          });
        },
        onDraggableCanceled: (_, __) {
          setState(() {
            hoveringIndex = null;
          });
        },
        child: DragTarget<int>(
          onAcceptWithDetails: (details) {
            setState(() {
              final oldIndex = details.data;
              if (oldIndex != index) {
                final item = items.removeAt(oldIndex);
                items.insert(index > oldIndex ? index - 1 : index, item);
              }
              hoveringIndex = null;
            });
          },
          onWillAcceptWithDetails: (details) {
            setState(() {
              hoveringIndex = index;
            });
            return true;
          },
          onLeave: (_) {
            setState(() {
              hoveringIndex = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = hoveringIndex == index;
            final double gapPadding = isHovering ? 32.0 : 0.0;
            return AnimatedPadding(
              padding: EdgeInsets.only(left: gapPadding),
              duration: const Duration(milliseconds: 200),
              child: widget.builder(items[index]),
            );
          },
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  const DockItem({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 48,
      width: 48,
      margin: const EdgeInsets.all(8),
      child: Icon(icon),
    );
  }
}
