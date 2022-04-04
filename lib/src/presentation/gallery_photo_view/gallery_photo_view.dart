import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/presentation/utils/constants/item_type.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

typedef FuncPickImage = Function(String? pathImage);

class GalleryPhotoView extends StatefulWidget {
  static const ROUTE_NAME = 'GalleryPhotoView';

  final ScrollNotifier scrollNotifier;
  final ControlNotifier controlNotifier;
  final DraggableWidgetNotifier draggableWidgetNotifier;
  final int? galleryThumbnailQuality;
  final Color? editorBackgroundColor;

  const GalleryPhotoView({
    Key? key,
    required this.scrollNotifier,
    required this.galleryThumbnailQuality,
    required this.draggableWidgetNotifier,
    required this.controlNotifier,
    this.editorBackgroundColor,
  }) : super(key: key);

  @override
  _GalleryPhotoViewState createState() => _GalleryPhotoViewState();
}

class _GalleryPhotoViewState extends State<GalleryPhotoView> {
  static const TAG = 'GalleryPhotoView';
  final _picker = ImagePicker();
  late ScrollController _scrollController;
  late ScrollNotifier _scrollNotifier;
  late ControlNotifier _controlNotifier;
  late DraggableWidgetNotifier _draggableWidgetNotifier;
  int? _galleryThumbnailQuality;
  Color? _editorBackgroundColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollNotifier = widget.scrollNotifier;
    _controlNotifier = widget.controlNotifier;
    _draggableWidgetNotifier = widget.draggableWidgetNotifier;
    _galleryThumbnailQuality = widget.galleryThumbnailQuality;
    _editorBackgroundColor = widget.editorBackgroundColor;
  }

  @override
  void didUpdateWidget(covariant GalleryPhotoView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _scrollNotifier = widget.scrollNotifier;
    _controlNotifier = widget.controlNotifier;
    _draggableWidgetNotifier = widget.draggableWidgetNotifier;
    _galleryThumbnailQuality = widget.galleryThumbnailQuality;
    _editorBackgroundColor = widget.editorBackgroundColor;
  }

  Future<void> _imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      _handlerPickImage(pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  _handlerPickImage(String path) {
    _controlNotifier.mediaPath = path;
    if (_controlNotifier.mediaPath.isNotEmpty) {
      _draggableWidgetNotifier.draggableWidget.insert(
          0,
          EditableItem()
            ..type = ItemType.image
            ..position = const Offset(0.0, 0));
    }
    _scrollNotifier.pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GalleryMediaPicker(
          gridViewController: _scrollNotifier.gridController,
          thumbnailQuality: _galleryThumbnailQuality,
          singlePick: true,
          onlyImages: true,
          appBarColor: _editorBackgroundColor ?? Colors.black,
          gridViewPhysics: _draggableWidgetNotifier.draggableWidget.isEmpty
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          pathList: (path) => _handlerPickImage(path[0]['path']),
          childAspectRatio: 1,
          appBarHeight: 0,
          appBarLeadingWidget: Padding(
            padding: const EdgeInsets.only(bottom: 15, right: 15),
            child: Align(
              alignment: Alignment.bottomRight,
              child: AnimatedOnTapButton(
                onTap: () {
                  _scrollNotifier.pageController
                      .animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                      )),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _imgFromCamera(),
        backgroundColor: Colors.black,
        child: const ImageIcon(
          AssetImage('assets/icons/camera.png', package: 'stories_editor'),
        ),
      ),
    );
  }
}
