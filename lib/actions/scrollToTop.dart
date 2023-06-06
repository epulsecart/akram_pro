import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ScrollToTop {
  final ScrollController scrollController = ScrollController();

  returnTheVariable () {
    return scrollController;
  }

  buttonLayout () {
    return Container(
        height: 30,
        width: 30,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(
                  scrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn);
            },
            child: Icon(Icons.assistant_navigation, size: 50),
            backgroundColor: HexColor("#F65D12"),
          ),
        )
    );
  }
}