import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPhotoNotifier extends ChangeNotifier {
  List<AssetEntity> _allAssets = [];

  List<AssetEntity> get allAssets => _allAssets;

  set allAssets(List<AssetEntity> allAssets) {
    _allAssets = allAssets;
    notifyListeners();
  }

  Future<List<AssetEntity>> getListPhoto() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      final albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
      if (albums.isNotEmpty) {
        List<AssetEntity> allAssets = [];
        for (var item in albums) {
          var assets = await item.getAssetListRange(
            start: 0,
            end: item.assetCount,
          );
          _allAssets.addAll(assets);
        }
        print('allAssets ${allAssets.length}');
        return allAssets;
      }
    }
    return [];
  }
}
