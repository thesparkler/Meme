import 'package:Meme/models/post.dart';
import 'package:Meme/providers/meme_provider.dart';
import 'package:Meme/theme_data.dart';
import 'package:Meme/widgets/swiper_view/CopyButton.dart';
import 'package:Meme/widgets/swiper_view/bg_change_button.dart';
import 'package:Meme/widgets/swiper_view/download_button.dart';
import 'package:Meme/widgets/swiper_view/share_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class SingleSwiperView extends StatefulWidget {
  final PostProvider mp;
  final int index;
  const SingleSwiperView({Key key, this.mp, this.index}) : super(key: key);

  static route(context, int idx, PostProvider mp) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleSwiperView(
          index: idx,
          mp: mp,
        ),
      ),
    );
  }

  @override
  _SingleSwiperViewState createState() => _SingleSwiperViewState();
}

class _SingleSwiperViewState extends State<SingleSwiperView> {
  PageController _ctrl;

  @override
  void initState() {
    _ctrl = PageController(initialPage: this.widget.index);
    _ctrl.addListener(() {
      int page = _ctrl.page.round();
      int total = widget.mp.items.length;
      if ((total - page) == 2) {
        widget.mp.nextPage();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.mp,
      child: Scaffold(
        body: Consumer<PostProvider>(builder: (context, mp, child) {
          return Stack(
            children: [
              PageView.builder(
                  controller: _ctrl,
                  scrollDirection: Axis.vertical,
                  itemCount: mp.items.length,
                  itemBuilder: (context, index) {
                    Post item = mp.items[index];
                    return item.renderType == "image"
                        ? SinglePostWidget(item: item)
                        : SingleTextPostWidget(item: item);
                  }),
              Positioned(
                child: SafeArea(
                  child: BackButton(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class SinglePostWidget extends StatelessWidget {
  const SinglePostWidget({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Post item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Image.network(item.image),
          ),
        ),
        Positioned(
            left: 5,
            bottom: 10,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                MdiIcons.heartOutline,
                color: Colors.white,
              ),
            )),
        Positioned(
          right: 5,
          bottom: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DownlaodButton(item: item),
              ShareButton(item: item),
            ],
          ),
        )
      ],
    );
  }
}

class SingleTextPostWidget extends StatefulWidget {
  SingleTextPostWidget({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Post item;

  @override
  _SingleTextPostWidgetState createState() => _SingleTextPostWidgetState();
}

class _SingleTextPostWidgetState extends State<SingleTextPostWidget> {
  final GlobalKey _key = new GlobalKey();
  var bg;
  @override
  Widget build(BuildContext context) {
    if (bg == null) bg = widget.item.bg;
    return Stack(
      children: [
        RepaintBoundary(
          key: _key,
          child: Container(
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              color: bg,
              child: Center(
                child: Text(
                  widget.item.caption,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            left: 5,
            bottom: 10,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                MdiIcons.heartOutline,
                color: Colors.white,
              ),
            )),
        Positioned(
          right: 5,
          bottom: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.item.canChangeBackgroundColor()
                  ? BGChangeButton(
                      item: widget.item,
                      onChange: (v) {
                        print(v);
                        setState(() {
                          bg = v;
                        });
                      })
                  : CustomTheme.placeHolder,
              widget.item.canCopyText()
                  ? CopyButton(item: widget.item)
                  : CustomTheme.placeHolder,
              DownlaodButton(item: widget.item, rKey: _key),
              ShareButton(item: widget.item, rKey: _key),
            ],
          ),
        )
      ],
    );
  }
}
