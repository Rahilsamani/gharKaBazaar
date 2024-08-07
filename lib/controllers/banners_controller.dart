import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // RxList to hold banner URLs
  final bannerUrls = RxList<String>();

  // Observable to track the current index of the carousel
  final carousalCurrentIndex = 0.obs;

  // Function to update the current banner index
  void updateCurrentBanner(index) {
    carousalCurrentIndex.value = index;
  }

// Stream to get banner data including URLs from Firestore
  Stream<List<Map<String, dynamic>>> getBannerData() {
    return _firestore
        .collection('banners')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> bannerData = {
          'image': doc['image'] as String,
          'category': doc['category'] as String,
          'timestamp': doc['timestamp'] as Timestamp,
        };
        return bannerData;
      }).toList();
    }).handleError((error) {
      print('Error fetching banner data: $error');
    });
  }
}
