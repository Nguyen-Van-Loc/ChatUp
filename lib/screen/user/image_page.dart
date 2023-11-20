import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePickPage extends StatefulWidget {
  const ImagePickPage({Key? key, required this.multiple}) : super(key: key);
  final bool multiple;

  @override
  State<ImagePickPage> createState() => _ImagePickPageState();
}

class _ImagePickPageState extends State<ImagePickPage> {
  List<Widget> imageList = [];
  int curentPage = 0;
  int? lastPage;
  Set<AssetEntity> selectedImages = {};
  final ImageLoader imageLoader = ImageLoader();

  handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent <= 0.33) return;
    if (curentPage == lastPage) return;
    fetchAllImage();
  }

  fetchAllImage() async {
    List<Widget> images = await imageLoader.fetchAllImage(
      curentPage: curentPage,
      lastPage: lastPage,
      selectedImages: selectedImages,
      handleScrollEvent: handleScrollEvent,
      toggleSelection: toggleSelection,
      multiple: widget.multiple
    );
    setState(() {
      imageList.addAll(images);
      curentPage++;
    });
  }

  void toggleSelection(AssetEntity asset) {
    setState(() {
      if (selectedImages.contains(asset)) {
        selectedImages.remove(asset);
      } else {
        selectedImages.add(asset);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllImage();
  }

  Future<Uint8List> convertAssetToUint8List(AssetEntity asset) async {
    final uint8List = await asset.originBytes;
    return Uint8List.fromList(uint8List!);
  }

  void convertSelectedImagesToUint8List() async {
    if (!widget.multiple && selectedImages.isNotEmpty) {
      AssetEntity asset = selectedImages.first;
      Uint8List uint8List = await convertAssetToUint8List(asset);
      Navigator.pop(context, uint8List);
    } else if (widget.multiple) {
      List<Uint8List> selectedImagesUint8List = [];
      for (AssetEntity asset in selectedImages) {
        Uint8List uint8List = await convertAssetToUint8List(asset);
        if (!selectedImagesUint8List.contains(uint8List)) {
          selectedImagesUint8List.add(uint8List);
        }
      }
      Navigator.pop(context, selectedImagesUint8List);
    } else {
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          IconButton(
            onPressed: () {
              convertSelectedImagesToUint8List();
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scroll) {
            handleScrollEvent(scroll);
            return true;
          },
          child: GridView.builder(
            itemCount: imageList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              return imageList[index];
            },
          ),
        ),
      ),
    );
  }
}

class ImageLoader {
  Future<List<Widget>> fetchAllImage({
    required int curentPage,
    required bool multiple,
    required int? lastPage,
    required Set<AssetEntity> selectedImages,
    required Function(ScrollNotification) handleScrollEvent,
    required Function(AssetEntity) toggleSelection,
  }) async {
    lastPage = curentPage;
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return [buildNoPhotosFoundWidget()];

    List<AssetPathEntity> album = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (album.isEmpty) {
      return [buildNoPhotosFoundWidget()];
    } else {
      List<AssetEntity> photos =
          await album[0].getAssetListPaged(page: curentPage, size: 24);
      List<Widget> temp = [];
      for (var asset in photos) {
        temp.add(
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ImageWidget(
                  asset: asset,
                  imageData: snapshot.data as Uint8List,
                  selectedImages: selectedImages,
                  toggleSelection: toggleSelection,
                  multiple: multiple,
                );
              }
              return const SizedBox();
            },
            future: asset.thumbnailDataWithSize(
              const ThumbnailSize(200, 200),
            ),
          ),
        );
      }
      return temp;
    }
  }

  Widget buildNoPhotosFoundWidget() {
    return const Center(
      child: Text(
        'No photos found on this device.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final AssetEntity asset;
  final Uint8List imageData;
  final Set<AssetEntity> selectedImages;
  final Function(AssetEntity) toggleSelection;
  final bool multiple;

  const ImageWidget({
    Key? key,
    required this.asset,
    required this.imageData,
    required this.selectedImages,
    required this.toggleSelection,
    required this.multiple,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedImages.contains(widget.asset);

    // Kiểm tra nếu không phải chọn nhiều ảnh (multiple == false), không hiển thị checkbox
    if (!widget.multiple) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            setState(() {
              widget.toggleSelection(widget.asset);
            });
          },
          borderRadius: BorderRadius.circular(5),
          splashFactory: NoSplash.splashFactory,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2.0,
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: MemoryImage(widget.imageData),
              ),
            ),
          ),
        ),
      );
    } else {
      // Hiển thị checkbox khi chọn nhiều ảnh
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  widget.toggleSelection(widget.asset);
                });
              },
              borderRadius: BorderRadius.circular(5),
              splashFactory: NoSplash.splashFactory,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2.0,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(widget.imageData),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: CustomCheckbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    widget.toggleSelection(widget.asset);
                  });
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({Key? key, required this.value, this.onChanged})
      : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(widget.value);
          setState(() {});
        }
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.value ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.blue, width: 2.0),
        ),
        child: widget.value
            ? const Icon(
                Icons.check,
                size: 20,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
