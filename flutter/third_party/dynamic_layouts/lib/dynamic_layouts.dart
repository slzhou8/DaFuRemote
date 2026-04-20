library dynamic_layouts;

import 'package:flutter/material.dart';

class SliverGridDelegateWithWrapping {
  const SliverGridDelegateWithWrapping({
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.padding = EdgeInsets.zero,
  });

  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry padding;
}

class DynamicGridView extends StatelessWidget {
  const DynamicGridView.builder({
    super.key,
    required this.gridDelegate,
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = false,
  });

  final SliverGridDelegateWithWrapping gridDelegate;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final children = List<Widget>.generate(
      itemCount,
      (index) => itemBuilder(context, index),
      growable: false,
    );

    final wrap = Padding(
      padding: gridDelegate.padding,
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: gridDelegate.crossAxisSpacing,
          runSpacing: gridDelegate.mainAxisSpacing,
          children: children,
        ),
      ),
    );

    if (shrinkWrap) {
      return SingleChildScrollView(
        child: wrap,
      );
    }

    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: wrap,
        ),
      ),
    );
  }
}
